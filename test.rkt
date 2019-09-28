#lang hatcher

main SomeDefinition
  patternProperties:
    /^.+$/: /OtherDefinition

OtherDefinition
  properties:
    afield: "value"
  anotherProp: 2.2