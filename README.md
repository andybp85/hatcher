# STATUS

Just getting started!

Working on getting the tokenizer and grammer creating a proper-looking struct.

* * *

# Hatcher

A JSON Schema generator.

## Goals

JSON Schema is extremely verbose and repetative, which makes writing it by hand cumbersome, error-prone, and trying (at best) for a human. Hatcher aims to make it... well, at least bearable. It is implemented in [Racket](https://docs.racket-lang.org/).

Hatcher's design is guided by the following principles:

1.  Abstraction - Why write a nested block when one (or no) word will do.
2.  Inheritance - DRY it out.
3.  Organization - Trivially import pieces of schema into each other.
4.  Completeness - Support all features of [JSON Schema 7.0.](https://json-schema.org/understanding-json-schema/reference/index.html)

<!-- Future: generate Typescript types
 -->

## README Formatting

-   _Italics_ indicate a word that is a concept in the language, but isn't a keyword.
-   `Code` indicates a language keyword or example.
-   _`Italic code`_ indicates JSON Schema (except in blocks, which are labeled). See the docs linked above if needed.

## Language

### Defintions

The basic form is the _defintion_, which consists of a name and key: value _fields_. The name must start with a capital letter.

```yaml
 SomeDefinition
    properties:
        field: "value"
```

A basic _defintion_ can have any _fields_ legal in  JSON Schema, and can be imported into any other _definition_ of the same _type_. _Definitions_ in the same file must be seperated by a blank line.

Also important to note, _`additionalProperties`_ and _`additionalItems`_ are set to _`false`_ by default, but can be enabled by specifically setting them to _`true`_.

### Qualifiers

_Qualifiers_ can be used to create _qualified defintions_. A _qualified defintion_ may have specific required _fields_, or may render a certain way. They start with a lower-case letter and are written before the name in a definition: `main ConfigSchema`. These _qualifiers_ are included:

#### `main`

 An _`object`_  that defines the top-level configuration. There must be exactly one `main` _defintion_, and all imports must be relative to and either next to or below it in the file structure. These _fields_ are required, all of which correspond to JSON Schema:

-   _`$id`_
-   _`$schema`_
-   _`title`_
-   _`properties`_

#### `category`

 _Categories_ will turn into groups of the things extending them in the schema using _`anyOf`_. These can be any _type_ and contain any _fields_. _Definitions_ in a category will inherit all _fields_ from the category and can override any of them. Nested overrides will be merged with the child's fields overriding anything in the parent's.

 We haven't seen _inheritance_ yet, but this should be pretty clear:

```yaml
 category Address
     properties:
         street:
             type: "string"

 HomeAddress /Addresses
     addressType: "home"
```

 JSON Schema:

```json
{
    "definitions": {
         "Address": {
             "anyOf": [
                 {
                     "$ref": "#/definitions/HomeAddress"
                 }
             ]
         },
         "HomeAddress": {
             "additionalProperties": false,
             "properties": {
                 "addressType": {
                     "const": "home"
                 },
                 "street": {
                     "type": "string"
                 }
             },
             "type": "object"
         }
    }
}
```

### Types

A _defintion_ must have a _type_ that matches with the [types in JSON Schema](https://json-schema.org/understanding-json-schema/reference/type.html). _Types_ are written after the _qualifier_, if present, and before the _defintion_ name. The _type_ can be ommitted if it is _`object`_.

```yaml
array ToDoItems
    items:
        type: "string"
```

JSON Schema:

```json
{
    "definitions": {
        "ToDoItems": {
            "additionalItems": false,
            "items": {
                "type": "string"
            },
            "type": "array",
        }
    }
}
```

### Fields

_Fields_ in a _definition_ are seperated by new lines, and indentation is used to defined nesting. _Field values_ that are _strings_ must be `"double quoted"`.

### Attributes

_Fields_ can have one or more of the following _attributes_ that denote something specific about the field. These are written after the field name and bfore the colon: `field*: value`.

-   `*`: _required_
-   `!`: _immutable_
    -   any _definitions_ that inhert this field cannot change it.
-   `+`: _abstract_
    -   These take a JSON-Schema like type _field_ describing the _field_.
    -   _Abstract fields_ must be implemented on any _definitions_ that inherit them.
    -   See example at the end.

### Paths

 _Paths_ all begin with a `/`, `.`, or `..`. _Path components_ beginning with lowercase letters indicate subfolders or files relative to the current file, and components with capitals letters indicate _definitions_. Dots are required for imports from other files. _Paths_ starting with a slash indicate imports in the same file. _Paths_ to imports in other files must specify the file and the _definition_, e.g. `../file/Parent`.

### Inheritance

_Inheritance_ is accomplishe by putting one or more _paths_ after the name, e.g. `SomeDefinition: ../file/Parent`. The only restriction on _Inheritance_ is that a _defintion_ may only inherit from another with the same _type_.

### Full Example

**./main**

```yaml
main Schema
    properties:
        $id: "http://hatcher-example.com/schema.json"
        $schema: "http://json-schema.org/draft-07/schema#"
        title: "Hatcher Example Schema"
        patternProperties: {
            /^.+$/: ./address/Address
```

**./address**

```yaml
category Address
    properties:
        addressType+:
            enum: [
                "business"
                "home"
            ]
        zipCode: 55555
```

**./homeAddress**

```yaml
HomeAddress ./address/Address
    properties:
        AddressType: "home"
        street:
            type: "string"
        owners: /Owners

array Owners
    items:
        type: "string"
```

**JSON Schema:**

```json
{
    "$id": "http://hatcher-example.com/schema.json",
    "$schema": "http://json-schema.org/draft-07/schema#",
    "additionalProperties": false,
    "patternProperties": {
        "^.+$": {
            "$ref": "/definitions/Address"
        }
    },
    "definitions": {
         "Address": {
             "anyOf": [
                 {
                     "$ref": "#/definitions/HomeAddress"
                 }
             ]
         },
         "HomeAddress": {
             "additionalProperties": false,
             "properties": {
                 "addressType": "home",
                 "street": {
                     "type": "string"
                 },
                 "owners": {
                     "$ref": "#/definitions/Owners"
                 },
                 "zipCode": 55555
             },
             "type": "object"
         },
         "Owners": {
             "additionalItems": false,
             "items": {
                 "type": "string"
             },
             "type": "array"
         }
    },
    "title": "Hatcher Example Schema"
}
```
