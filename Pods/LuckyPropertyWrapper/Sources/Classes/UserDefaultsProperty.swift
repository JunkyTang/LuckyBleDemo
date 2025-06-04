//
//  UserDefaultsProperty.swift
//  LuckyPropertyWrapper
//
//  Created by junky on 2024/10/12.
//

import Foundation

@propertyWrapper
public struct UserDefaultsProperty<T: Codable> {
    
    public var wrappedValue: T {
        get {
            
            let ud = UserDefaults(suiteName: suitName) ?? .standard
            guard let data = ud.data(forKey: key) else {
                return defaultValue
            }
            let decoder = JSONDecoder()
            guard let decodedValue = try? decoder.decode(T.self, from: data) else {
                return defaultValue
            }
            return decodedValue
        }
        set {
            let ud = UserDefaults(suiteName: suitName) ?? .standard
            let encoder = JSONEncoder()
            if let encodedValue = try? encoder.encode(newValue) {
                ud.set(encodedValue, forKey: key)
                ud.synchronize()
            }
        }
    }
    
    let suitName: String?
    
    let key: String
    
    let defaultValue: T
    
    public init(suitName: String? = nil, key: String, defaultValue: T) {
        self.suitName = suitName
        self.key = key
        self.defaultValue = defaultValue
    }
}
