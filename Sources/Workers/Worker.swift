//
//  Worker.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import Foundation

public class Worker<T: RawRepresentable> where T.RawValue == String {
    public var time: Int = .zero

    public func start() throws {}
    public func stop() throws {}
}

public extension Worker {
    func autoStop() throws {
        guard time != .zero else { return }

        let seconds = UInt32(time)
        sleep(seconds)

        try stop()
    }

    func log(_ task: T, _ additional: String = "") {
        let main = task.rawValue.removingCamelCase
        Log.debug(main + " " + additional)
    }
}
