//
//  OptionalHelper.swift
//  StrictlySwift
//
//  Created by strictlyswift on 19-Feb-19.
//

import Foundation

public extension Optional {

    /// Convert an optional value to a Result, where nil is converted to the `withNil` value ; and non-nil is wrapped as **success**
    ///
    /// - Parameter withNil: "Failure" to return if the optional is nil.
    /// - Returns: Optional value wrapped as above.
    func toResult<Failure>(withNil: Failure) -> Result<Wrapped,Failure> {
        if let value = self {
            return .success(value)
        } else {
            return .failure(withNil)
        }
    }
    
    /// True if this optional value is "nil"
    func isNonNil() -> Bool {
        if case .none = self { return false }
        return true
    }
    
    /// True iff the optional value is NOT nil
    func isNil() -> Bool {
        return !isNonNil()
    }
    
    /// If both are nil, return nil. If A is nil, return f(B!).  If B is nil, return f(A!). If A and B are both non-nil, return g(A,B)
    func combine<T,S>( a: T?, b: T?, f:(T)->S, g:(T,T)->S) -> S? {
        if a == nil && b == nil { return nil }
        if a == nil && b != nil { return f(b!) }
        if b == nil && a != nil { return f(a!) }
        return g(a!,b!)
    }
}

infix operator !!
public extension Optional {
    /// With code like   `try returnsOptional() !! MyError("Bad")`
    /// if the left-hand side contains a value, the value is returned;
    /// else the error on the right hand side is thrown.
    ///
    static func !!(left:Optional<Wrapped>, right:@autoclosure () -> Error) throws -> Wrapped {
        switch left {
            case .some(let s): return s
            case .none: throw right()
        }
    }
}
