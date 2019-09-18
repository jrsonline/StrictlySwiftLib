//
//  StringHelper.swift
//  StrictlySwift
//
//  Created by RedPanda on 11-May-19.
//

import Foundation
import XCTest

public extension String {
    /// Returns the portion of the string following the parameter.
    /// For example `"LOG=a,b,c".suffix(after:"LOG=")` is `"a,b,c"`.
    /// If the parameter is not found in the string, the substring is empty.
    ///
    /// - Parameter after: Suffix of the string _after_ this are returned
    /// - Returns: The substring with the initial string removed.
    func suffix<S:StringProtocol>(after str: S) -> Substring {
        if let strRange = self.range(of: str) {
            return self.suffix(from: strRange.upperBound)
        } else {
            return self.suffix(0)
        }
    }
}

public extension String {
    /// Opens a file, and returns a sequence of lines (\n terminated) in the file.
    /// Once the sequence goes out of scope, the file  is closed.
    ///
    /// - Parameters:
    ///   - file: Path to file
    ///   - encoding: String encoding, defaults to UTF8
    /// - Returns: Sequence of lines
    static func readLines(fromFile file: String,
                          encoding: String.Encoding = .utf8,
                          delimiter: Character = "\n") -> FileLinesSequence? {
        return FileLinesSequence(fromFile: file, encoding: encoding, delimiter: delimiter)
    }
}

