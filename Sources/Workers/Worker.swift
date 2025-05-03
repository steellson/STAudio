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

        sleep(UInt32(time))
        try stop()
    }

    func log(_ info: T, _ additional: String = "") {
        let main = info.rawValue.removingCamelCase
        Log.debug(main + " " + additional)
    }
}
