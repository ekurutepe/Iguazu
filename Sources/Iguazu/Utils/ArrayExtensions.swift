//
//  ArrayExtensions.swift
//  SolarKit
//
//  Created by Engin Kurutepe on 22.11.19.
//  Copyright © 2019 Fifteen Jugglers Software. All rights reserved.
//

import Foundation

// Adapted from https://talk.objc.io/episodes/S01E90-concurrent-map?t=524
public extension Collection {
    func concurrentMap<B>(_ transform: @escaping (Element) -> B) -> [B] {
        let result = ThreadSafe(Array<B?>(repeating: nil, count: count))
        let startIndex = self.startIndex
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let index = self.index(startIndex, offsetBy: idx)
            let element = self[index]
            let transformed = transform(element)
            result.atomically {
                $0[idx] = transformed
            }
        }
        return result.value.map { $0! }
    }
    
    func concurrentFilter( _ condition: @escaping (Element) -> Bool ) -> [Element] {
        let result = ThreadSafe(Array<Element?>(repeating: nil, count: count))
        let startIndex = self.startIndex
        DispatchQueue.concurrentPerform(iterations: count) { idx in
            let index = self.index(startIndex, offsetBy: idx)
            let element = self[index]
            let transformed = condition(element) ? element : nil
            result.atomically {
                $0[idx] = transformed
            }
        }
        return result.value.compactMap { $0 }
    }
}

