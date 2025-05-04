//
//  Worker.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import Foundation

/// Service or process with progress in time
public class Worker<T: RawRepresentable>: Chroner<TimeInterval> {
    public func start() throws { reset() }
    public func stop() throws {}
}

public extension Worker {
    /// Logger with levels, can parse enum logs
    /// - Parameters:
    ///   - task: Some case from enum which conformed String
    ///   - additional: Payload if needed
    ///   - type: Log level
    func log(
        _ task: T,
        _ additional: String = "",
        _ type: Log.UseCase = .debug
    ) where T.RawValue == String {
        let msg = task.rawValue.removingCamelCase
        let log = msg + " " + additional

        Log.send(log, type: type)
    }
}
