//
//  Copyright © 2018 Gnosis Ltd. All rights reserved.
//

import Foundation
import IdentityAccessApplication

/// Implementation of a Clock interface with actual system Timer.
public final class SystemClockService: Clock {

    public init() {}

    public var currentTime: Date {
        return Date()
    }

    public func countdown(from period: TimeInterval, tick: @escaping (TimeInterval) -> Void) {
        var timeLeft = period
        let step: TimeInterval = 1
        Timer.scheduledTimer(withTimeInterval: step, repeats: true) { timer in
            timeLeft -= step
            tick(timeLeft)
            if timeLeft == 0 {
                timer.invalidate()
            }
        }
        tick(timeLeft)
    }

}
