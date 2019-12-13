//
//  CombineHelper.swift
//
//  Created by strictlyswift on 15-Jun-19.
//

import Foundation
import Combine

@available(iOS 13.0, macOS 15.0, *)
public extension Publisher {
    func toBlockingResult(timeout: Int) -> Result<[Self.Output],BlockingError> {
        var result : Result<[Self.Output],BlockingError>?
        let semaphore = DispatchSemaphore(value: 0)
        
        let sub = self
            .collect()
            .mapError { error in BlockingError.otherError(error) }
            .timeout(
                .seconds(timeout),
                scheduler: DispatchQueue.main,
                customError: { BlockingError.timeoutError(timeout) }
            )
            .sink(
                receiveCompletion: { compl in
                    switch compl {
                    case .finished: break
                    case .failure( let f ): result = .failure(f)
                    }
                    semaphore.signal()
            },
                receiveValue: { value in
                    result = .success(value)
                    semaphore.signal()
            }
        )
        
        // Wait for a result, or time out
        if semaphore.wait(timeout: .now() + .seconds(timeout)) == .timedOut {
            sub.cancel()
            return .failure(BlockingError.timeoutError(timeout))
        } else {
            return result ?? .success([])
        }
    }
}


struct NSLoggerStream : TextOutputStream {
    mutating func write(_ string: String) {
        guard string.count > 0 && string != "\n" else { return }
        NSLog(string)
    }
}

public struct TestError : Error {}
public enum BlockingError : Error {
    case timeoutError(Int)
    case otherError(Error)
    
    public func asOtherError() -> Error? {
        if case .otherError(let e) = self { return e } else { return nil }
    }
        
    public func timeoutError() -> Int? {
        if case .timeoutError(let t) = self { return t } else { return nil }
    }
}


extension DispatchTime : Strideable {
    public typealias Stride = Int64
    
    public func distance(to other: DispatchTime) -> Int64 {
        Int64(other.rawValue) - Int64(self.rawValue)
    }
    
    public func advanced(by n: Int64) -> DispatchTime {
        self + Double(n)   // warning of overflows here!
    }
    
}

extension Int64 : SchedulerTimeIntervalConvertible {
    public static func seconds(_ s: Int) -> Int64 {
        return Int64(s * 1_000_000_000)
    }
    
    public static func seconds(_ s: Double) -> Int64 {
        return Int64(s * 1_000_000_000)
    }
    
    public static func milliseconds(_ ms: Int) -> Int64 {
        return Int64(ms * 1_000_000)
    }
    
    public static func microseconds(_ us: Int) -> Int64 {
        Int64(us * 1_000)
    }
    
    public static func nanoseconds(_ ns: Int) -> Int64 {
        return Int64(ns)
    }
}

struct FutureScheduledAction : Cancellable {
    var workItem : DispatchWorkItem
    
    init(_ action: @escaping () -> Void, at: DispatchTime) {
        workItem = DispatchWorkItem {
            action()
        }
        DispatchQueue.global().asyncAfter(deadline: at, execute: workItem)
    }
    
    func cancel() {
        workItem.cancel()
    }
    
}

@available(iOS 13.0, macOS 15.0, *)
struct FutureScheduler : Scheduler {
    var now: DispatchTime { get { return DispatchTime.now() }}
    var minimumTolerance: Int64 = 1
    
    func schedule(after date: DispatchTime, tolerance: Int64, options: Never?, _ action: @escaping () -> Void) {
        _ = self.schedule(after: date, interval: .seconds(0), tolerance: tolerance, options: nil, action)
    }
    
    func schedule(after date: DispatchTime, interval: Int64, tolerance: Int64, options: Never?, _ action: @escaping () -> Void) -> Cancellable {
        FutureScheduledAction( action, at: date)
    }
    
    func schedule(options: Never?, _ action: @escaping () -> Void) {
        _ = self.schedule(after: now, interval: .seconds(0), tolerance: minimumTolerance, options: nil, action)
    }
}


@available(OSX 10.15, *)
extension Publisher {
    /// logs events to NSLog
    func log(_ amLogging: Bool, prefix: String = "Publisher", log: @escaping (Output) -> String) -> Publishers.HandleEvents<Self> {
        if amLogging {
            return self.handleEvents( receiveOutput: { output in NSLog("\(prefix): \(log(output))") },
                                      receiveCompletion: {c in NSLog("\(prefix): Completed \(c)")},
                                      receiveCancel: { NSLog("\(prefix): <cancel>")}
                                      )
        } else {
            return self.handleEvents()
        }
    }
}
