//
//  DictionaryHelper.swift
//  StrictlySwift
//
//  Created by RedPanda on 26-Feb-19.
//
//
import Foundation

public extension Dictionary where Key:Comparable {
    func toSortedArray() -> [(Key,Value)] {
        return Array(self).sorted { $0.0 < $1.0 }
    }
    
    func append(_ other: Dictionary<Key,Value>, uniquingKeysWith f:(Value,Value) -> Value = { $1 }) -> Dictionary<Key,Value> {
        let arr1 = Array(self)
        let arr2 = Array(other)
        return Dictionary(arr1 + arr2, uniquingKeysWith: f)
    }
}
