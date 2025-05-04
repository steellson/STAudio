//
//  String+.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import Foundation

public extension String {
    /// Make first character of string uppercased
    /// `some word` >>> `Some word`
    var capitalizedFirstLetter: String {
        guard let first else { return self }

        let range = startIndex ..< index(after: startIndex)
        let character = String(first).uppercased()
        return replacingCharacters(in: range, with: character)
    }

    /// Transformed string from camel case to common sentence
    /// `somethingWentWrong` >>> `Something went wrong`
    var removingCamelCase: String {
        var chars = compactMap { String($0) }

        enumerated().forEach {
            let char = String($1)
            let lower = char.lowercased()
            guard char != lower else { return }

            chars[$0] = " \(lower)"
        }

        return chars.joined().capitalizedFirstLetter
    }
}
