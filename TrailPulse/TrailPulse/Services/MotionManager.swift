//
//  MotionManager.swift
//  TrailPulse
//
//  Course 1, Session 2: Core Motion — pedometer + altitude.
//
//  Teaching notes:
//    • CMPedometer is the easy win — students see steps/pace updating live
//      within minutes. Great motivator before the heavier sensors arrive.
//    • CMAltimeter requires NSMotionUsageDescription in Info.plist.
//    • Mention that CMAltimeter is RELATIVE — it reports change since the
//      first reading, not absolute altitude. Combine with GPS altitude in
//      Course 3 for a smarter ascent calculation.
//

import Foundation
import CoreMotion
import Combine

final class MotionManager: ObservableObject {

    @Published var stepsThisSession: Int = 0
    @Published var currentPaceMinPerKm: Double?    // from CMPedometer
    @Published var cadenceStepsPerMin: Double?
    @Published var relativeAltitudeMeters: Double = 0

    private let pedometer = CMPedometer()
    private let altimeter = CMAltimeter()
    private var sessionStart: Date?

    func startUpdates() {
        sessionStart = Date()
        startPedometer()
        startAltimeter()
    }

    func stopUpdates() {
        pedometer.stopUpdates()
        altimeter.stopRelativeAltitudeUpdates()
        sessionStart = nil
    }

    private func startPedometer() {
        guard CMPedometer.isStepCountingAvailable() else { return }
        guard let start = sessionStart else { return }
        pedometer.startUpdates(from: start) { [weak self] data, _ in
            guard let self, let data else { return }
            DispatchQueue.main.async {
                self.stepsThisSession = data.numberOfSteps.intValue
                if let pace = data.currentPace?.doubleValue {
                    // currentPace is seconds per metre → convert to min/km
                    self.currentPaceMinPerKm = (pace * 1000.0) / 60.0
                }
                if let cadence = data.currentCadence?.doubleValue {
                    // cadence is steps/second
                    self.cadenceStepsPerMin = cadence * 60.0
                }
            }
        }
    }

    private func startAltimeter() {
        guard CMAltimeter.isRelativeAltitudeAvailable() else { return }
        altimeter.startRelativeAltitudeUpdates(to: .main) { [weak self] data, _ in
            guard let self, let data else { return }
            self.relativeAltitudeMeters = data.relativeAltitude.doubleValue
        }
    }
}
