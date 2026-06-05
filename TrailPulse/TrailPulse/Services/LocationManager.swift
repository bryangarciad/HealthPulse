//
//  LocationManager.swift
//  TrailPulse
//
//  Course 1, Session 1: GPS tracking.
//
//  Teaching notes:
//    • Show requestWhenInUseAuthorization first, then escalate to always
//      authorization in Session 2 once we explain background updates.
//    • Distance filter of 5m keeps battery sane while still drawing a
//      smooth path on the map.
//    • Set allowsBackgroundLocationUpdates = true ONLY after demonstrating
//      Info.plist NSLocationAlwaysAndWhenInUseUsageDescription.
//

import Foundation
import CoreLocation
import Combine

final class LocationManager: NSObject, ObservableObject {

    @Published var currentLocation: CLLocation?
    @Published var authorizationStatus: CLAuthorizationStatus = .notDetermined
    @Published var isTracking: Bool = false
    @Published private(set) var recordedPoints: [LocationPoint] = []

    private let manager = CLLocationManager()

    override init() {
        super.init()
        manager.delegate = self
        manager.desiredAccuracy = kCLLocationAccuracyBest
        manager.distanceFilter = 5         // metres
        manager.activityType = .fitness
        authorizationStatus = manager.authorizationStatus
    }

    func requestPermission() {
        manager.requestWhenInUseAuthorization()
    }

    func startTracking() {
        recordedPoints.removeAll()
        manager.startUpdatingLocation()
        isTracking = true
    }

    func stopTracking() {
        manager.stopUpdatingLocation()
        isTracking = false
    }

    /// Total distance walked along the recorded path, in metres.
    var totalDistanceMeters: Double {
        guard recordedPoints.count > 1 else { return 0 }
        var total: Double = 0
        for i in 1..<recordedPoints.count {
            let a = CLLocation(latitude: recordedPoints[i-1].latitude,
                               longitude: recordedPoints[i-1].longitude)
            let b = CLLocation(latitude: recordedPoints[i].latitude,
                               longitude: recordedPoints[i].longitude)
            total += b.distance(from: a)
        }
        return total
    }
}

// MARK: - CLLocationManagerDelegate

extension LocationManager: CLLocationManagerDelegate {
    func locationManagerDidChangeAuthorization(_ manager: CLLocationManager) {
        authorizationStatus = manager.authorizationStatus
    }

    func locationManager(_ manager: CLLocationManager,
                         didUpdateLocations locations: [CLLocation]) {
        for location in locations
        where location.horizontalAccuracy >= 0 && location.horizontalAccuracy < 50 {
            currentLocation = location
            if isTracking {
                recordedPoints.append(LocationPoint(from: location))
            }
        }
    }

    func locationManager(_ manager: CLLocationManager,
                         didFailWithError error: Error) {
        // Course 1: just log. Course 3: surface to user via notification.
        print("Location error: \(error.localizedDescription)")
    }
}
