//
//  KeychainProperty.swift
//  LuckyPropertyWrapper
//
//  Created by junky on 2025/2/10.
//

import Foundation
import Security

@propertyWrapper
public struct KeychainProperty<T: Codable> {
    
    public var wrappedValue: T {
        get {
            var query: [String: Any] = [
                kSecClass as String: kSecClassGenericPassword,
                kSecAttrAccount as String: key,
                kSecReturnData as String: kCFBooleanTrue!,
                kSecMatchLimit as String: kSecMatchLimitOne
            ]
            
            if let group = group {
                query[kSecAttrAccessGroup as String] = group
            }
            
            var dataTypeRef: AnyObject?
            let status = SecItemCopyMatching(query as CFDictionary, &dataTypeRef)

            if status == errSecSuccess, let retrievedData = dataTypeRef as? Data {
                guard let res = try? JSONDecoder().decode(T.self, from: retrievedData) else {
                    return defaultValue
                }
                return res
            }else{
                print("Keychain read error: \(key) \(status)")
            }
            return defaultValue
        }
        set {
            
            let encoder = JSONEncoder()
            if let encodedValue = try? encoder.encode(newValue) {
                var query: [String: Any] = [
                    kSecClass as String: kSecClassGenericPassword,
                    kSecAttrAccount as String: key
                ]
                if let group = group {
                    query[kSecAttrAccessGroup as String] = group
                }
                SecItemDelete(query as CFDictionary)
                query[kSecValueData as String] = encodedValue
                query[kSecAttrAccessible as String] = kSecAttrAccessibleWhenUnlocked
                SecItemAdd(query as CFDictionary, nil)
            }
        }
    }
    
    let group: String?
    
    let key: String
    
    let defaultValue: T
    
    public init(group: String? = nil, key: String, defaultValue: T) {
        self.group = group
        self.key = key
        self.defaultValue = defaultValue
    }
}
