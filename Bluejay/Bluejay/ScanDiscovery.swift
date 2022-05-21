//
//  ScanDiscovery.swift
//  Bluejay
//
//  Created by Jeremy Chiang on 2017-02-27.
//  Copyright © 2017 Steamclock Software. All rights reserved.
//

import CoreBluetooth
import Foundation

/// A model capturing what is found from a scan callback.
public struct ScanDiscovery {
    /// The unique, persistent identifier associated with the peer.
    public let peripheralIdentifier: PeripheralIdentifier

    /// The advertisement packet the discovered peripheral is sending.
    public let advertisementPacket: [String: Any]

    /// The signal strength of the peripheral discovered.
    public let rssi: Int

    /// Parse through the advertising packet of the discovered peripheral then extract, decode, and return the device's serial number
    public func getSerialNum() -> String {
        if let manufacturerData = advertisementPacket["kCBAdvDataManufacturerData"] as? Data {
            if manufacturerData.count >= 2 {
                let dataRange: Range<Int> = 2..<10
                let data = manufacturerData.subdata(in: dataRange)
                let serialNum = String(data: data, encoding: .utf8) //54
                if serialNum != nil {
                    return serialNum!
                }
            }
        }
        return "UnknownAhh"
    }
}
