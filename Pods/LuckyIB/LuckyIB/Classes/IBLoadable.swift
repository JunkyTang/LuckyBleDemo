//
//  XibLoadable.swift
//  LuckyIB
//
//  Created by junky on 2024/5/25.
//

import Foundation
import UIKit


public protocol IBLoadable: UIView {}

public extension IBLoadable {
    
    typealias S = Self
        
    static func loadFromXib(_ xibName: String? = nil) -> S {
        
        let bundle = Bundle(for: S.self)
        let name = xibName ?? String(describing: self)
        if let instance = bundle.loadNibNamed(name, owner: nil)?.first,
           let view = instance as? Self {
            return view
        }
        return S()
    }
}
