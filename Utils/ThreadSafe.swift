//
//  ThreadSafe.swift
//  SolarKit
//
//  Created by Engin Kurutepe on 22.11.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

// Adapted from https://talk.objc.io/episodes/S01E90-concurrent-map?t=524
public final class ThreadSafe<A> {
    public init(_ value: A) {
        self._value = value
    }
    
    public var value: A {
        return queue.sync { _value }
    }
    
    public func atomically(_ transform: (inout A) -> ()) {
        queue.sync {
            transform(&self._value)
        }
    }
    
    private var _value: A
    private let queue = DispatchQueue(label: "ThreadSafe-\(A.self)")
}

