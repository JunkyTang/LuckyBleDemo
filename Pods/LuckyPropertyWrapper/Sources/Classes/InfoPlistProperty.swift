//
//  InfoPlistProperty.swift
//  LuckyPropertyWrapper
//
//  Created by junky on 2025/2/17.
//

import Foundation


@propertyWrapper
public struct InfoPlistProperty<T: Codable> {
    
    public var wrappedValue: T {
        get {
            (bundle.object(forInfoDictionaryKey: key) as? T) ?? defaultValue
        }
        set {
            print("InfoPlistProperty cant not write")
        }
    }
    
    let bundle: Bundle
    
    let key: String
    
    let defaultValue: T
    
    public init(bundle: Bundle? = nil, key: String, defaultValue: T) {
        self.bundle = bundle ?? .main
        self.key = key
        self.defaultValue = defaultValue
    }
}
