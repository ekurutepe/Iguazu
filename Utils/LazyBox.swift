//
//  LazyBox.swift
//  Pods
//
//  Created by Engin Kurutepe on 16.01.20.
//

import Foundation

// based on https://oleb.net/blog/2015/12/lazy-properties-in-structs-swift/
final class LazyBox<Input, Result> {
  init(computation: @escaping (Input) -> Result) {
    _value = .notYetComputed(computation)
  }
  
  func value(input: Input) -> Result {
    var returnValue: Result? = nil
    queue.sync {
      switch self._value {
      case .notYetComputed(let computation):
        let result = computation(input)
        self._value = .computed(result)
        returnValue = result
      case .computed(let result):
        returnValue = result
      }
    }
    assert(returnValue != nil)
    return returnValue!
  }
  
  private var _value: LazyValue<Input, Result>
  /// All reads and writes of `_value` must happen on this queue.
  private let queue = DispatchQueue(label: "LazyBox._value")

}

private enum LazyValue<Input, Value> {
  case notYetComputed((Input) -> Value)
  case computed(Value)
}
