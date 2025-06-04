//
//  SafeArea+.swift
//  LuckyPop
//
//  Created by junky on 2024/5/27.
//

import Foundation

public extension UIApplication {
    
    var currentWindow: UIWindow? {
        guard let delegate = UIApplication.shared.delegate,
              let window = delegate.window,
              let window = window
        else { return nil }
        return window
    }
    
    var safeAreaInset: UIEdgeInsets {
        guard let window = currentWindow else { return .zero }
        return window.safeAreaInsets
    }
    
}

