//
//  StringExtensions.swift
//  Yakom
//
//  Created by Vysag K on 04/10/23.
//

import Foundation

extension String{
    var validFilename: String {
      guard !isEmpty else { return "emptyFilename" }
      return addingPercentEncoding(withAllowedCharacters: .alphanumerics) ?? "emptyFilename"
    }
    var localized: String {
      localize()
    }
    func localize(comment: String = "") -> String {
      NSLocalizedString(self, comment: comment)
    }
}
extension String {

    func applyPatternOnNumbers(pattern: String, replacmentCharacter: Character) -> String {
        var pureNumber = self.replacingOccurrences( of: "[^0-9]", with: "", options: .regularExpression)
        for index in 0 ..< pattern.count {
            guard index < pureNumber.count else { return pureNumber }
            let stringIndex = String.Index(utf16Offset: index, in: self)
            let patternCharacter = pattern[stringIndex]
            guard patternCharacter != replacmentCharacter else { continue }
            pureNumber.insert(patternCharacter, at: stringIndex)
        }
        return pureNumber
    }
}
