//
//  UIView+.swift
//  LuckyCombine
//
//  Created by junky on 2024/12/24.
//

import UIKit
import Combine


public extension UIView {
    
    func publisher(gestureRecognizer: UIGestureRecognizer) -> Publishers.UIGestureRecognizerPublisher {
        addGestureRecognizer(gestureRecognizer)
        return gestureRecognizer.publisher()
    }
    
}
