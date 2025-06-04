//
//  PassthroughSubjectProperty.swift
//  LuckyPropertyWrapper
//
//  Created by junky on 2024/8/26.
//

import Foundation
import Combine

@propertyWrapper
public struct PassthroughSubjectProperty<T> {
    
    public var wrappedValue: T {
        set {
            value = newValue
        }
        get {
            value
        }
    }

    public var projectedValue: PassthroughSubject<T, Never>
    
    var value: T {
        didSet {
            projectedValue.send(value)
        }
    }
    
    
    public init(wrappedValue: T) {
        self.value = wrappedValue
        self.projectedValue = PassthroughSubject<T, Never>()
    }
}
