//
//  FirmwareUpdate.swift
//  Mockingjay
//
//  Created by Zachary Potoskie on 5/21/22.
//

import CoreBluetooth
import iOSDFULibrary

class FirmwareUpdate: Operation {

    /// The peripheral this operation will be performed.
    var peripheral: CBPeripheral

    /// The queue this operation belongs to.
    var queue: Queue?

    /// The state of this operation.
    var state: QueueableState

    /// The manager responsible for this operation.
    private let manager: CBCentralManager

    /// The delegate that receives DFU callbacks
    private weak var delegate: Bluejay?

    // stuff
    private var firmware: DFUFirmware?
    private var dfuController: DFUServiceController!

    private var currentProgress: FirmwareUpdateProgress

    private var partsCompleted: Int = 0
    private var currentFirmwarePartsCompleted: Int = 0
    private var firstPartRatio: Float = 1.0

    private var timer: Timer!
    private var startTime: Date!

    /// The progress update callback.
    private let progress: (FirmwareUpdateProgress) -> Void

    /// The stopped callback. Called when stopped normally as well, not just when there is an error.
    private let stopped: (FirmwareUpdateProgress, Error?) -> Void

    init(peripheral: CBPeripheral,
         progress: @escaping (FirmwareUpdateProgress) -> Void,
         stopped: @escaping (FirmwareUpdateProgress, Error?) -> Void,
         delegate: Bluejay,
         manager: CBCentralManager) {

        self.state = .notStarted
        self.currentProgress = FirmwareUpdateProgress()

        self.peripheral = peripheral
        self.progress = progress
        self.stopped = stopped
        self.manager = manager
        self.delegate = delegate

    }

    func start() {
        state = .running
        firmware = getFirmwareFile()
        guard let firmware = firmware else {
            print("No firmware found. Check your URL")
            // MARK: - Throw an error (add parameter for firmware URL to bluejay class)
            return
        }
        currentProgress = FirmwareUpdateProgress(part: 1, total: firmware.parts, prog: 1, currentSpeed: 0, avgSpeed: 0)

        startTime = Date()

        // Calculate the first part ratio. It will be used to estimate the step progress view state.
        if firmware.parts > 1 {
            firstPartRatio = Float(firmware.size.softdevice + firmware.size.bootloader) /
                Float(firmware.size.softdevice + firmware.size.bootloader + firmware.size.application)
        } else {
            firstPartRatio = 1.0
        }

        print("first part ratio: \(firstPartRatio)")

        // Update counters
        currentFirmwarePartsCompleted = 0

        // Create DFU initiator with some default configuration
        let dfuInitiator = DFUServiceInitiator(queue: DispatchQueue(label: "Other"))
        dfuInitiator.delegate = delegate
        dfuInitiator.progressDelegate = delegate
        dfuInitiator.dataObjectPreparationDelay = 0.4 // sec
        dfuInitiator.disableResume = true

        if #available(iOS 11.0, macOS 10.13, *) {
            dfuInitiator.packetReceiptNotificationParameter = 0
        }

        dfuController = dfuInitiator.with(firmware: firmware).start(target: peripheral)

        debugLog("DFU started.")
    }

//    - connecting:      Service is connecting to the DFU target.
//    - starting:        DFU Service is initializing DFU operation.
//    - enablingDfuMode: Service is switching the device to DFU mode.
//    - uploading:       Service is uploading the firmware.
//    - validating:      The DFU target is validating the firmware.
//    - disconnecting:   The iDevice is disconnecting or waiting for disconnection.
//    - completed:       DFU operation is completed and successful.
//    - aborted:         DFU Operation was aborted.

    func process(event: Event) {
        if case .didUpdateDFUProgress(let progressABC) = event {
            currentProgress = progressABC
            progress(currentProgress)
        } else if case .didUpdateDFUState(let stateABC) = event {
            switch stateABC {
            case .completed:
                stop()
            case .aborted, .disconnecting:
                // change this to something
                fail(BluejayError.stopped)
            default:
                print("State changed to: \(stateABC.description())")
            }
        } else {
            preconditionFailure("Unexpected event response: \(event)")
        }

        // MARK: Add a process for recieving the error before the change of state?
    }

    func stop() {
        state = .completed
        stopFirmwareUpdate(error: nil)
    }

    func fail(_ error: Error) {
        state = .failed(error)
        stopFirmwareUpdate(error: error)
    }

    private func getFirmwareFile() -> DFUFirmware? {
        let url = Bundle.main.url(forResource: "app_dfu_package2", withExtension: "zip", subdirectory: "")
        guard url != nil else {
            print("invalid URL")
            return nil
        }
        let firmware = DFUFirmware(urlToZipFile: url!, type: .application)
        guard firmware != nil else {
            print("invalid Firmware")
            return nil
        }
        return firmware!
    }

    private func stopFirmwareUpdate(error: Error?) {

        dfuController = nil
        delegate = nil

        if let error = error {
            debugLog("Scanning stopped with error: \(error.localizedDescription)")
        } else {
            debugLog("Scanning stopped.")
        }

        stopped(currentProgress, error)

        // swiftlint:disable:next notification_center_detachment
        NotificationCenter.default.removeObserver(self)

        updateQueue()
    }

    func debugLog(_ string: String) {
        queue?.debugLog(string)
    }
}
