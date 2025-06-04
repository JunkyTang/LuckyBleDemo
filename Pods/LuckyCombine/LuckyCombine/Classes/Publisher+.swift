//
//  Combine+.swift
//  LuckyCombine
//
//  Created by junky on 2024/8/22.
//

import Foundation
import Combine


extension Publisher where Self.Failure == Never {
    
    public func bindTo<T: AnyObject>(object: T, keyPath: WritableKeyPath<T, Output>) -> AnyCancellable {
        sink { [weak object] newValue in
            object?[keyPath: keyPath] = newValue
        }
    }
    
    public func bindTo<T: AnyObject>(object: T, keyPath: WritableKeyPath<T, Output?>) -> AnyCancellable {
        sink { [weak object] newValue in
            object?[keyPath: keyPath] = newValue
        }
    }

}



extension Publisher where Self.Failure == Never {
    
    public func linkTo(subject:any Subject<Output, Never>) -> AnyCancellable {
        sink { [weak subject] new in
            guard let subject = subject
            else { return }
            subject.send(new)
        }
    }
    
}




extension Publisher where Self.Failure == Never {

    
    public func trySink(throwable: @escaping (Output) throws -> Void) -> AnyCancellable {
        sink { out in
            do {
                try throwable(out)
            } catch {
                Config.exceptionHandler(error)
            }
        }
    }
    
    public func asyncSink(asyncable: @escaping (Output) async -> Void) -> AnyCancellable {
        sink { out in
            Task {
                await asyncable(out)
            }
        }
    }
    
    public func tryAsyncSink(receiveValue: @escaping (Output) async throws -> Void) -> AnyCancellable {
        sink { out in
            Task {
                do {
                    try await receiveValue(out)
                } catch {
                    Config.exceptionHandler(error)
                }
            }
        }
    }
    
    
    
    
    
    
}
