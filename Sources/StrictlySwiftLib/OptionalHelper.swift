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
    
    /// If self and B are nil, return nil. If self is nil, return f(B!).  If B is nil, return f(self!). If self and B are both non-nil, return g(self,B)
    func combine<S>( b: Wrapped?, f:(Wrapped)->S, g:(Wrapped,Wrapped)->S) -> S? {
        switch (self, b) {
        case (.none, .none): return nil
        case (.none, .some(let bb)): return f(bb)
        case (.some(let aa), .none): return f(aa)
        case (.some(let aa), .some(let bb)): return g(aa,bb)
        }
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
