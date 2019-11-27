//
//  SequenceHelper.swift
//  
//
//  Created by RedPanda on 27-Nov-19.
//

import Foundation

func forever<A>(_ a:A) -> AnySequence<A> {
        return AnySequence { () -> AnyIterator<A> in
            return AnyIterator {
                a
            }
        }
    }
