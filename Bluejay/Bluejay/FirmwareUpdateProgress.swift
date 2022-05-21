//
//  FirmwareUpdateProgress.swift
//  Bluejay
//
//  Created by Zachary Potoskie on 5/21/22.
//  Copyright © 2022 Steamclock Software. All rights reserved.
//

import CoreBluetooth
import Foundation

/// A model capturing what is found from a firmware progress update callback.
public struct FirmwareUpdateProgress {
    public let part: Int
    public let totalParts: Int
    public let progress: Int
    public let currentSpeedBytesPerSecond: Double
    public let avgSpeedBytesPerSecond: Double
    
    init(part: Int, total: Int, prog: Int, currentSpeed: Double, avgSpeed: Double) {
        self.part = part
        self.totalParts = total
        self.progress = prog
        self.currentSpeedBytesPerSecond = currentSpeed
        self.avgSpeedBytesPerSecond = avgSpeed
    }
    
    init() {
        self.part = 0
        self.totalParts = 0
        self.progress = 0
        self.currentSpeedBytesPerSecond = 0
        self.avgSpeedBytesPerSecond = 0
    }
}
