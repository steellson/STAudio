//
//  Worker.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import Foundation

/// ** Abstract service **
public class Worker<T: RawRepresentable>: Chroner<TimeInterval> where T.RawValue == String {
    public func start() throws { reset() }
    public func stop() throws {}
}

public extension Worker {
    func log(_ task: T, _ additional: String = "") {
        let main = task.rawValue.removingCamelCase
        Log.debug(main + " " + additional)
    }
}
