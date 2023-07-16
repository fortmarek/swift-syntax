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

@_spi(RawSyntax) import SwiftSyntax

/// A type that can be used in place of a `while true` loop.
/// See `evaluate` for more detail.
struct LoopProgressCondition {
  var currentToken: Lexer.Lexeme?

  init() {}

  /// Check that the loop has made progress since `evaluate` was called the last time.
  /// In assert builds, this traps if the loop has not made any parser progress in between two iterations,
  /// ie. it checks if the parser's `currentToken` has changed in between two calls to `evaluate`.
  /// In non-assert builds, `evaluate()` returns `false` if the loop has not made progress, thus aborting the loop.
  @inline(__always)
  mutating func evaluate(_ parser: Parser) -> Bool {
    return evaluate(parser.currentToken)
  }

  /// Check that the loop has made progress since `evaluate` was called the last time.
  /// In assert builds, this traps if the loop has not made any parser progress in between two iterations,
  /// ie. it checks if the parser's `currentToken` has changed in between two calls to `evaluate`.
  /// In non-assert builds, `evaluate()` returns `false` if the loop has not made progress, thus aborting the loop.
  @inline(__always)
  mutating func evaluate(_ parser: Parser.Lookahead) -> Bool {
    return evaluate(parser.currentToken)
  }

  /// Implementation of the above `evaluate` methods.
  private mutating func evaluate(_ currentToken: Lexer.Lexeme) -> Bool {
    defer {
      self.currentToken = currentToken
    }

    guard let previousToken = self.currentToken else {
      return true
    }
    // The loop has made progress if either
    //  - the parser is now pointing at a different location in the source file
    //  - the parser is still pointing at the same position in the source file
    //     but now has a different token kind (and thus consumed a zero-length
    //     token like an empty string interpolation
    let hasMadeProgress =
      previousToken.tokenText.baseAddress != currentToken.tokenText.baseAddress
      || (previousToken.byteLength == 0 && previousToken.rawTokenKind != currentToken.rawTokenKind)
    assert(hasMadeProgress, "Loop should always make progress")
    return hasMadeProgress
  }
}
