//
//  Chroner.swift
//  STAudio
//
//  Created by Andrew Steellson on 03.05.2025.
//

import Foundation

open class Chroner<T: Numeric> {
    private var finished: Bool {
        remaining == .zero || elapsed == duration
    }

    var elapsed:   T = .zero
    var remaining: T = .zero
    var duration:  T = .zero

    func step() {
        sleep(1)
        elapsed += 1
        remaining -= 1
    }

    func reset() {
        elapsed = .zero
        remaining = duration
    }

    func autoStop(_ action: () throws -> Void) throws {
        if finished { try action() }
    }
}
