//
//  String+Markdown.swift
//  StyleGenerator
//
//  Created by Denis on 10.03.17.
//  Copyright © 2017 DenRee. All rights reserved.
//
import Foundation

private let defaultIndentation = 2 // Based on default indentation for Swift

/// Used to generate code for switch/enum case
/// Common rule: you set part of code as String,
/// To generate example of code:
/// ...
/// case <your pattern>:
///  <your code>
/// ...
/// create this -> SwitchCase("your pattern", "your code")
/// the same for EnumCase
typealias SwitchCase = (pattern: CasePattern, code: String)
typealias EnumCase = (name: CasePattern, caseValue: String?)
typealias CasePattern = String

fileprivate extension CasePattern {
  var formatted: String {
    let systemPatterns = ["default"]
    if systemPatterns.contains(self) {
      return "`\(self)`"
    } else {
      return self
    }
  }
}

extension String {

  // MARK: - Nested

  enum CodeSymbols {
    case header
    case newLine
    case line(string: String)
    case mark(title: String)
    case snippet(type: SnippetType, for: String, nestedSymbols: [CodeSymbols])
    case `enum`(name: String, cases: [EnumCase])
    case `switch`(value: String, cases: [SwitchCase])
    case function(title: String, body: [CodeSymbols])
    case forCycle(iteratorTitle: String, nestedSymbols: [CodeSymbols])
    case property(fullName: String, nestedSymbols: [CodeSymbols]?)

    // swiftlint:disable:next nesting
    enum SnippetType: String {
      case `extension`
      case `protocol`
      case `class`
      case `struct`
      case `enum`
    }
  }

  // MARK: - Public

  static func += (lhs: inout String, rhs: CodeSymbols) {
    lhs += rhs.value
  }

  func addIndentation(_ count: Int = defaultIndentation) -> String {

    let indent = makeIndent(count: count)
    var result = replacingOccurrences(of: "\n", with: "\n" + indent)
    if result.hasSuffix(indent) {
      let startIndex = result.index(result.startIndex, offsetBy: result.characters.count - count)
      let endIndex = result.index(result.startIndex, offsetBy: result.characters.count)
      result.replaceSubrange(startIndex ..< endIndex, with: "")
    }
    result.insert(contentsOf: indent.characters, at: result.startIndex)
    return result
  }

  // MARK: - Private

  fileprivate func makeIndent(count: Int) -> String {
    var result = ""
    for _ in 0 ..< count {
      result += String.InputSymbols.space.rawValue
    }
    return result
  }
}

// MARK: - Utilities

extension String {

  var capitalFirst: String {
    guard characters.count > 0 else { return self }

    let firstChar = String(characters.prefix(1)).uppercased()
    let remainChars = String(characters.dropFirst())

    return firstChar + remainChars
  }
}

// MARK: - CodeSymbols

extension String.CodeSymbols {

  // MARK: - Public

  var value: String {
    switch self {
      // Header
    case .header:
      var result = ""
      result += "//\n"
      result += "// Autogenerated by StyleGenerator - Generator\n"
      result += "// by CocoaHeads Team https://github.com/azimin/CocoaHeadsMeetupApp\n"
      result += "//\n\n"
      return result

      // New line symbol
    case .newLine:
      return "\n"

      // Line symbol
    case let .line(string):
      return string + "\n"

      // Mark symbol
    case let .mark(title):
      return "// MARK: - \(title)\n\n"

      // Snippet symbol
    case let .snippet(type, target, nested):
      guard nested.count > 0 else {
        return "\(type.rawValue) \(target) {}"
      }
      var result = "\(type.rawValue) \(target) {\n"
      for nestedSymbol in nested {
        if nestedSymbol.value == String.CodeSymbols.newLine.value {
          result += nestedSymbol
        } else {
          result += nestedSymbol.addIndentation()
        }
      }
      result += .line(string: "}")
      return result

      // Enum symbol
    case let .enum(name, cases):

      guard cases.count > 0 else {
        return "enum \(name) {}"
      }

      var result = "enum \(name) {\n"

      var casesString = ""
      for enumCase in cases {
        if let value = enumCase.caseValue {
          casesString += "case \(enumCase.name.formatted) = \(value)\n"
        } else {
          casesString += "case \(enumCase.name.formatted)\n"
        }
      }

      result += casesString.addIndentation()
      result += .line(string: "}")
      return result

      // Switch symbol
    case let .switch(value, cases):
      var result = ""
      result += .line(string: "switch \(value) {")
      for caseItem in cases {
        result += .line(string: "case .\(caseItem.pattern.formatted):")
        result += .line(string: caseItem.code.addIndentation())
      }
      result += .line(string: "}")
      return result

      // Function symbol
    case let .function(title, body):
      var result = ""
      result += .line(string: title + " {")
      for item in body {
        result += item.addIndentation()
      }
      result += .line(string: "}")
      return result

      // For symbol
    case let .forCycle(iteratorTitle, nestedSymbols):
      var result = "for \(iteratorTitle) {\n"
      for nestedSymbol in nestedSymbols {
        if nestedSymbol.value == String.CodeSymbols.newLine.value {
          result += nestedSymbol
        } else {
          result += nestedSymbol.addIndentation()
        }
      }
      result += String.CodeSymbols.line(string: "}")
      return result

    case let .property(fullName, nestedSymbols):
      guard let nestedSymbols = nestedSymbols, nestedSymbols.count > 0 else {
        return "\(fullName)\n"
      }

      var result = fullName + " {\n"
      for nestedSymbol in nestedSymbols {
        if nestedSymbol.value == String.CodeSymbols.newLine.value {
          result += nestedSymbol
        } else {
          result += nestedSymbol.addIndentation()
        }
      }
      result += "}"
      return result
    }
  }

  func addIndentation(_ count: Int = defaultIndentation) -> String {
    return value.addIndentation(count)
  }
}
