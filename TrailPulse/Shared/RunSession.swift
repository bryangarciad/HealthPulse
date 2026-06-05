//
//  RunSession.swift
//  TrailPulse — shared between iOS and watchOS targets
//
//  Represents a single recorded run/hike. Grows in capability across the
//  three courses, but the shape stays stable so students never have to
//  refactor earlier work.
//

import Foundation
import CoreLocation

/// A single recorded outdoor session.
///
/// Course 1: GPS path, motion stats, persistence (Core Data mirror is generated from this).
/// Course 2: heart-rate samples + media items + HealthKit workout ID get added.
/// Course 3: notification-event log + complication snapshot get added.
struct RunSession: Identifiable, Codable {
    let id: UUID
    var startedAt: Date
    var endedAt: Date?

    // Course 1 — basic telemetry
    var path: [LocationPoint]          // GPS samples
    var steps: Int                     // pedometer total
    var distanceMeters: Double         // running total
    var ascentMeters: Double           // from CMAltimeter

    // Course 2 — health + media (start as empty arrays; populate later)
    var heartRateSamples: [HeartRateSample] = []
    var mediaItems: [MediaItem] = []
    var healthKitWorkoutUUID: UUID?    // populated when HKWorkout is saved

    // Course 3 — alerts + analysis
    var alerts: [RunAlert] = []

    init(id: UUID = UUID(),
         startedAt: Date = Date(),
         endedAt: Date? = nil,
         path: [LocationPoint] = [],
         steps: Int = 0,
         distanceMeters: Double = 0,
         ascentMeters: Double = 0) {
        self.id = id
        self.startedAt = startedAt
        self.endedAt = endedAt
        self.path = path
        self.steps = steps
        self.distanceMeters = distanceMeters
        self.ascentMeters = ascentMeters
    }

    var duration: TimeInterval {
        (endedAt ?? Date()).timeIntervalSince(startedAt)
    }

    /// Average pace in minutes per kilometre (nil if not enough data).
    var paceMinPerKm: Double? {
        guard distanceMeters > 50 else { return nil }
        let km = distanceMeters / 1000.0
        let minutes = duration / 60.0
        return minutes / km
    }
}

// MARK: - GPS

struct LocationPoint: Codable, Equatable {
    let timestamp: Date
    let latitude: Double
    let longitude: Double
    let altitude: Double
    let horizontalAccuracy: Double

    var coordinate: CLLocationCoordinate2D {
        CLLocationCoordinate2D(latitude: latitude, longitude: longitude)
    }

    init(from location: CLLocation) {
        self.timestamp = location.timestamp
        self.latitude = location.coordinate.latitude
        self.longitude = location.coordinate.longitude
        self.altitude = location.altitude
        self.horizontalAccuracy = location.horizontalAccuracy
    }
}

// MARK: - Health (Course 2)

struct HeartRateSample: Codable, Equatable {
    let timestamp: Date
    let bpm: Double
}

// MARK: - Media (Course 2)

struct MediaItem: Identifiable, Codable, Equatable {
    enum Kind: String, Codable { case photo, voiceMemo }

    let id: UUID
    let kind: Kind
    let capturedAt: Date
    let fileURL: URL              // local file URL inside the app's container
    let latitude: Double?         // GPS-tagged at capture time
    let longitude: Double?
}

// MARK: - Alerts (Course 3)

struct RunAlert: Codable, Equatable {
    enum Kind: String, Codable {
        case heartRateZoneHigh
        case heartRateZoneLow
        case paceTooSlow
        case paceTooFast
        case lowBatteryWarning
    }
    let timestamp: Date
    let kind: Kind
    let message: String
}
