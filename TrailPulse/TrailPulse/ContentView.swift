//
//  ContentView.swift
//  TrailPulse
//
//  Root tab structure. The three tabs are not arbitrary — they match the
//  arc of the curriculum:
//    • Run      → built in Course 1, enriched throughout
//    • History  → built in Course 1 session 3 (Core Data) onward
//    • Insights → built in Course 3 session 11 (HealthKit trends)
//

import SwiftUI

struct ContentView: View {
    var body: some View {
        TabView {
            RunView()
                .tabItem {
                    Label("Run", systemImage: "figure.run")
                }

            HistoryView()
                .tabItem {
                    Label("History", systemImage: "list.bullet")
                }

            InsightsView()
                .tabItem {
                    Label("Insights", systemImage: "chart.line.uptrend.xyaxis")
                }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(SessionStore())
        .environmentObject(LocationManager())
        .environmentObject(MotionManager())
}
