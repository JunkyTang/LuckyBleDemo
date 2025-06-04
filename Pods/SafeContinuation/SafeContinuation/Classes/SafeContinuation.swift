//
//  SafeContinuation.swift
//  SafeContinuation
//
//  Created by junky on 2025/5/12.
//

import Foundation

public enum ContinuationError: Error {
    case some
    case timeout
}

/// SafeContinuation 是一个安全的封装，确保 `resume` 只被调用一次。
public actor SafeContinuation<T> {
    private var didResume = false
    private let continuation: CheckedContinuation<T, Error>
    private var timeout: TimeInterval
    private var task: Task<Void, Never>?
    
    internal init(_ continuation: CheckedContinuation<T, Error>, timeout: TimeInterval) {
        self.continuation = continuation
        self.timeout = timeout
    }
    
//    deinit {
//        print("✅ SafeContinuation has been deinitialized")
//    }
    
    public func startTimer() {
        task = Task {
            try? await Task.sleep(nanoseconds: UInt64(timeout * 1_000_000_000))
            timeoutIfNeeded()
        }
    }
    
    /// 超时逻辑
    public func timeoutIfNeeded() {
        guard !didResume else { return }
        didResume = true
        task?.cancel()
        continuation.resume(throwing: ContinuationError.timeout)
    }
    
    /// 正常 resume
    public func resume(returning value: T) {
        guard !didResume else { return }
        didResume = true
        task?.cancel()
        continuation.resume(returning: value)
    }
    
    /// 正常 resume 错误
    public func resume(throwing error: Error) {
        guard !didResume else { return }
        didResume = true
        task?.cancel()
        continuation.resume(throwing: error)
    }
}


public func withTimeout<T>(
    seconds: TimeInterval,
    _ operation: @escaping (SafeContinuation<T>) async -> Void
) async throws -> T {
    try await withCheckedThrowingContinuation { raw in
        let safe = SafeContinuation(raw, timeout: seconds)
        Task {
            await safe.startTimer()
            await operation(safe)
        }
         
    }
}


