//===----------------------------------------------------------------------===//
//
// This source file is part of the Swift.org open source project
//
// Copyright (c) 2014 - 2023 Apple Inc. and the Swift project authors
// Licensed under Apache License v2.0 with Runtime Library Exception
//
// See https://swift.org/LICENSE.txt for license information
// See https://swift.org/CONTRIBUTORS.txt for the list of Swift project authors
//
//===----------------------------------------------------------------------===//

public let GENERIC_NODES: [Node] = [
  // conformance-requirement -> type-identifier : type-identifier
  Node(
    kind: .conformanceRequirement,
    base: .syntax,
    nameForDiagnostics: "conformance requirement",
    children: [
      Child(
        name: "LeftType",
        deprecatedName: "LeftTypeIdentifier",
        kind: .node(kind: .type)
      ),
      Child(
        name: "Colon",
        kind: .token(choices: [.token(.colon)])
      ),
      Child(
        name: "RightType",
        deprecatedName: "RightTypeIdentifier",
        kind: .node(kind: .type)
      ),
    ]
  ),

  // generic-parameter-clause -> '<' generic-parameter-list generic-where-clause? '>'
  Node(
    kind: .genericParameterClause,
    base: .syntax,
    nameForDiagnostics: "generic parameter clause",
    documentation: "The parameter clause that defines the generic parameters.",
    parserFunction: "parseGenericParameters",
    children: [
      Child(
        name: "LeftAngle",
        deprecatedName: "LeftAngleBracket",
        kind: .token(choices: [.token(.leftAngle)]),
        documentation: "The opening angle bracket (`<`) of the generic parameter clause."
      ),
      Child(
        name: "Parameters",
        deprecatedName: "GenericParameterList",
        kind: .collection(kind: .genericParameterList, collectionElementName: "Parameter", deprecatedCollectionElementName: "GenericParameter"),
        documentation: "The list of generic parameters in the clause."
      ),
      Child(
        name: "GenericWhereClause",
        kind: .node(kind: .genericWhereClause),
        documentation: "A `where` clause that places additional constraints on generic parameters like `where Element: Hashable`.",
        isOptional: true
      ),
      Child(
        name: "RightAngle",
        deprecatedName: "RightAngleBracket",
        kind: .token(choices: [.token(.rightAngle)]),
        documentation: "The closing angle bracket (`>`) of the generic parameter clause."
      ),
    ]
  ),

  Node(
    kind: .genericParameterList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.genericParameter]
  ),

  // generic-parameter -> type-name
  //                    | type-name : type-identifier
  //                    | type-name : protocol-composition-type
  Node(
    kind: .genericParameter,
    base: .syntax,
    nameForDiagnostics: "generic parameter",
    traits: [
      "WithTrailingComma",
      "WithAttributes",
    ],
    children: [
      Child(
        name: "Attributes",
        kind: .collection(kind: .attributeList, collectionElementName: "Attribute", defaultsToEmpty: true)
      ),
      Child(
        name: "EachKeyword",
        deprecatedName: "Each",
        kind: .token(choices: [.keyword(text: "each")]),
        nameForDiagnostics: "parameter pack specifier",
        isOptional: true
      ),
      Child(
        name: "Name",
        kind: .token(choices: [.token(.identifier)]),
        nameForDiagnostics: "name"
      ),
      Child(
        name: "Colon",
        kind: .token(choices: [.token(.colon)]),
        isOptional: true
      ),
      Child(
        name: "InheritedType",
        kind: .node(kind: .type),
        nameForDiagnostics: "inherited type",
        isOptional: true
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(.comma)]),
        isOptional: true
      ),
    ]
  ),

  Node(
    kind: .genericRequirementList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.genericRequirement]
  ),

  // generic-requirement ->
  //     (same-type-requirement|conformance-requirement|layout-requirement) ','?
  Node(
    kind: .genericRequirement,
    base: .syntax,
    nameForDiagnostics: nil,
    traits: [
      "WithTrailingComma"
    ],
    children: [
      Child(
        name: "Requirement",
        deprecatedName: "Body",
        kind: .nodeChoices(choices: [
          Child(
            name: "SameTypeRequirement",
            kind: .node(kind: .sameTypeRequirement)
          ),
          Child(
            name: "ConformanceRequirement",
            kind: .node(kind: .conformanceRequirement)
          ),
          Child(
            name: "LayoutRequirement",
            kind: .node(kind: .layoutRequirement)
          ),
        ])
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(.comma)]),
        isOptional: true
      ),
    ]
  ),

  // generic-where-clause -> 'where' requirement-list
  Node(
    kind: .genericWhereClause,
    base: .syntax,
    nameForDiagnostics: "'where' clause",
    documentation: "A `where` clause that places additional constraints on generic parameters like `where Element: Hashable`.",
    children: [
      Child(
        name: "WhereKeyword",
        kind: .token(choices: [.keyword(text: "where")]),
        documentation: "The `where` keyword in the clause."
      ),
      Child(
        name: "Requirements",
        deprecatedName: "RequirementList",
        kind: .collection(kind: .genericRequirementList, collectionElementName: "Requirement"),
        documentation: "The list of requirements in the clause."
      ),
    ]
  ),

  // layout-requirement -> type-name : layout-constraint
  // layout-constraint -> identifier '('? integer-literal? ','? integer-literal? ')'?
  Node(
    kind: .layoutRequirement,
    base: .syntax,
    nameForDiagnostics: "layout requirement",
    children: [
      Child(
        name: "Type",
        deprecatedName: "TypeIdentifier",
        kind: .node(kind: .type),
        nameForDiagnostics: "constrained type"
      ),
      Child(
        name: "Colon",
        kind: .token(choices: [.token(.colon)])
      ),
      Child(
        name: "LayoutSpecifier",
        deprecatedName: "LayoutConstraint",
        kind: .token(choices: [
          .keyword(text: "_Trivial"),
          .keyword(text: "_TrivialAtMost"),
          .keyword(text: "_UnknownLayout"),
          .keyword(text: "_RefCountedObject"),
          .keyword(text: "_NativeRefCountedObject"),
          .keyword(text: "_Class"),
          .keyword(text: "_NativeClass"),
        ])
      ),
      Child(
        name: "LeftParen",
        kind: .token(choices: [.token(.leftParen)]),
        isOptional: true
      ),
      Child(
        name: "Size",
        kind: .token(choices: [.token(.integerLiteral)]),
        nameForDiagnostics: "size",
        isOptional: true
      ),
      Child(
        name: "Comma",
        kind: .token(choices: [.token(.comma)]),
        isOptional: true
      ),
      Child(
        name: "Alignment",
        kind: .token(choices: [.token(.integerLiteral)]),
        nameForDiagnostics: "alignment",
        isOptional: true
      ),
      Child(
        name: "RightParen",
        kind: .token(choices: [.token(.rightParen)]),
        isOptional: true
      ),
    ]
  ),

  // primary-associated-type-clause -> '<' primary-associated-type-list '>'
  Node(
    kind: .primaryAssociatedTypeClause,
    base: .syntax,
    nameForDiagnostics: "primary associated type clause",
    children: [
      Child(
        name: "LeftAngle",
        deprecatedName: "LeftAngleBracket",
        kind: .token(choices: [.token(.leftAngle)])
      ),
      Child(
        name: "PrimaryAssociatedTypes",
        deprecatedName: "PrimaryAssociatedTypeList",
        kind: .collection(kind: .primaryAssociatedTypeList, collectionElementName: "PrimaryAssociatedType")
      ),
      Child(
        name: "RightAngle",
        deprecatedName: "RightAngleBracket",
        kind: .token(choices: [.token(.rightAngle)])
      ),
    ]
  ),

  Node(
    kind: .primaryAssociatedTypeList,
    base: .syntaxCollection,
    nameForDiagnostics: nil,
    elementChoices: [.primaryAssociatedType]
  ),

  // primary-associated-type -> type-name ','?
  Node(
    kind: .primaryAssociatedType,
    base: .syntax,
    nameForDiagnostics: nil,
    traits: [
      "WithTrailingComma"
    ],
    children: [
      Child(
        name: "Name",
        kind: .token(choices: [.token(.identifier)]),
        nameForDiagnostics: "name"
      ),
      Child(
        name: "TrailingComma",
        kind: .token(choices: [.token(.comma)]),
        isOptional: true
      ),
    ]
  ),

  // same-type-requirement -> type-identifier == type
  Node(
    kind: .sameTypeRequirement,
    base: .syntax,
    nameForDiagnostics: "same type requirement",
    children: [
      Child(
        name: "LeftType",
        deprecatedName: "LeftTypeIdentifier",
        kind: .node(kind: .type),
        nameForDiagnostics: "left-hand type"
      ),
      Child(
        name: "Equal",
        deprecatedName: "EqualityToken",
        kind: .token(choices: [.token(.binaryOperator), .token(.prefixOperator), .token(.postfixOperator)])
      ),
      Child(
        name: "RightType",
        deprecatedName: "RightTypeIdentifier",
        kind: .node(kind: .type),
        nameForDiagnostics: "right-hand type"
      ),
    ]
  ),

]
