//
//  XCTHelper.swift
//
//  Created by strictlyswift on 27-May-19.
//

import Foundation
import XCTest

public func XCTAssertEqualArrays<T>(_ first: [T],
                                    _ second: [T],
                                    file: StaticString = #file,
                                    line: UInt = #line)
    where T: Equatable {
        XCTAssertEqual(first.count, second.count)
        XCTAssert( zip(first,second).allSatisfy { $0.0 == $0.1 }, "Arrays do not match", file: file, line: line )
}


/// Compares two dictionaries of form [String:X]. X can be a further nested dictionary, or a String
/// or an Int.
public func XCTAssertEqualDictionaries(item:[String:Any],
                                       refDict:[String:Any],
                                       file: StaticString = #file,
                                       line: UInt = #line) {
    
    // Check if the number of keys in 'item' matches
    XCTAssertEqual(Set(refDict.keys), Set(item.keys), "Fields in item don't match reference", file: file, line: line)
    
    for field in item.keys {
        switch (item[field], refDict[field]) {
        case let (fieldDict, refSubDict) as ([String:Any], [String:Any]):
            XCTAssertEqualDictionaries(item: fieldDict, refDict: refSubDict, file: file, line:line)
            
        case let (fieldStr, refStr) as (String, String):
            XCTAssertEqual(fieldStr, refStr, "Item's field '\(field)' has value '\(fieldStr)', but reference '\(field)' has '\(refStr)'" , file: file, line: line)
            
        case let (fieldStr, refStr) as (Int, Int):
            XCTAssertEqual(fieldStr, refStr, "Item's field '\(field)' has value '\(fieldStr)', but reference '\(field)' has '\(refStr)'" , file: file, line: line)
            
        default:
            XCTFail("Could not compare \(item[field] ?? "nil") and \(refDict[field] ?? "nil")", file: file, line: line)
        }
    }
}

/// Get around lack of resource management in SPM
public func getTestResourceDirectory(file: StaticString = #file) -> URL {
    let fileName = file.withUTF8Buffer {
        String(decoding: $0, as: UTF8.self)
    }

    let thisSourceFile = URL(fileURLWithPath: fileName  )
    return thisSourceFile
        .deletingLastPathComponent()
        .deletingLastPathComponent()
        .appendingPathComponent("Resources")
}


