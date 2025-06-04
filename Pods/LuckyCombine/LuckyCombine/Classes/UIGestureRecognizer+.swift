//
//  UIGestureRecognizer+.swift
//  LuckyCombine
//
//  Created by junky on 2024/12/24.
//

import UIKit
import Combine



public extension Subscribers {
    
    class UIGestureRecognizerSubscription<S: Subscriber, G: UIGestureRecognizer>: Subscription where S.Input == G, S.Failure == Never {
        
        var subscriber: S?
        var gestureRecognizer: G
        
        public init(subscriber: S? = nil, gestureRecognizer: G) {
            self.subscriber = subscriber
            self.gestureRecognizer = gestureRecognizer
            gestureRecognizer.addTarget(self, action: #selector(eventHandler(sender:)))
        }
        
        deinit {
            print("UIGestureRecognizerSubscription -deinit")
        }
        
        @objc func eventHandler(sender: UIGestureRecognizer) {
            guard let g = sender as? G else { return }
            _ = subscriber?.receive(g)
        }
        
        public func request(_ demand: Subscribers.Demand) {
            
        }
        
        public func cancel() {
            subscriber = nil
        }
        
        
    }
}


public extension Publishers {
    
    
    struct UIGestureRecognizerPublisher: Publisher {
        
        public typealias Output = UIGestureRecognizer
        public typealias Failure = Never
        
        private var gestureRecognizer: Output
        
        public init(gestureRecognizer: Output) {
            self.gestureRecognizer = gestureRecognizer
        }
        
        public func receive<S>(subscriber: S) where S : Subscriber, Never == S.Failure, UIGestureRecognizer == S.Input {
            let subscription = Subscribers.UIGestureRecognizerSubscription(subscriber: subscriber, gestureRecognizer: gestureRecognizer)
            subscriber.receive(subscription: subscription)
        }
    }
    
    
}



public extension UIGestureRecognizer {
    
    func publisher() -> Publishers.UIGestureRecognizerPublisher {
        return Publishers.UIGestureRecognizerPublisher(gestureRecognizer: self)
    }
}
