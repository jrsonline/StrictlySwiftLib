//
//  CodableHelper.swift
//  
//
//  Created by RedPanda on 12-Dec-19.
//

import Foundation

extension KeyedDecodingContainer {
    func mapIfContains<D>(_ key:K, f:(K) throws -> D) rethrows -> D?  {
        if self.contains(key) {
            return try f(key)
        } else {
            return nil
        }
    }
}
