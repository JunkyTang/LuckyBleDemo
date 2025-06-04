//
//  CurrentValueSubjectProperty.swift
//  LuckyPropertyWrapper
//
//  Created by junky on 2024/8/26.
//

import Foundation
import Combine


@propertyWrapper
public struct CurrentValueSubjectProperty<T> {
    
    public var wrappedValue: T {
        set {
            value = newValue
        }
        get {
            value
        }
    }
    
    public var projectedValue: CurrentValueSubject<T, Never>
    
    private var value: T {
        didSet {
            projectedValue.send(value)
        }
    }
    
    public init(wrappedValue: T) {
        self.value = wrappedValue
        self.projectedValue = CurrentValueSubject<T, Never>(wrappedValue)
    }
    
}
