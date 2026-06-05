//
//  TrailPulseApp.swift
//  TrailPulse — iOS app entry point
//

import SwiftUI

@main
struct TrailPulseApp: App {
    // Course 1 Session 3: replace with @StateObject for Core Data controller.
    @StateObject private var sessionStore = SessionStore()
    @StateObject private var locationManager = LocationManager()
    @StateObject private var motionManager = MotionManager()

    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(sessionStore)
                .environmentObject(locationManager)
                .environmentObject(motionManager)
        }
    }
}
