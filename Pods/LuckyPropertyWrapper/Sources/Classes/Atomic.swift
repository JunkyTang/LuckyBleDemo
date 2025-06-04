//
//  Atomic.swift
//  LuckyPropertyWrapper
//
//  Created by junky on 2024/8/26.
//

import Foundation


@propertyWrapper
struct Atomic<Value> {
    private var value: Value
    private let lock = NSLock()

    init(wrappedValue: Value) {
        self.value = wrappedValue
    }

    var wrappedValue: Value {
        get {
            lock.lock()
            defer { lock.unlock() }
            return value
        }
        set {
            lock.lock()
            defer { lock.unlock() }
            value = newValue
        }
    }

    mutating func modify(_ modifier: (inout Value) -> Void) {
        lock.lock()
        defer { lock.unlock() }
        modifier(&value)
    }
}

