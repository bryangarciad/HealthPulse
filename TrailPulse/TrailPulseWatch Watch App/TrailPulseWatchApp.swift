//
//  TrailPulseWatchApp.swift
//  TrailPulseWatch Watch App
//
//  Course 2 Session 5: students add the watchOS target and this file.
//

import SwiftUI

@main
struct TrailPulseWatchApp: App {
    @StateObject private var watchConnector = WatchConnector()

    var body: some Scene {
        WindowGroup {
            WatchRunView()
                .environmentObject(watchConnector)
        }
    }
}
