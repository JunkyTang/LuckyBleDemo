//
//  Logger.swift
//  LuckyLogger
//
//  Created by Lucky on 2025/4/8.
//

import Foundation

public class Logger {
    
    public var logHandler: (String) -> Void
    
    public init(logHandler: @escaping (String) -> Void = { _ in }) {
        self.logHandler = logHandler
    }
    
    public func print(_ items: Any..., separator: String = " ", terminator: String = "\n") {
        let message = items.map { "\($0)" }.joined(separator: separator) + terminator
        logHandler(message)
    }
}
