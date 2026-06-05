//
//  InsightsView.swift
//  TrailPulse
//
//  Course 3 Session 11: weekly stats, HealthKit historical queries,
//  trend charts. Until then the tab is a placeholder.
//

import SwiftUI

struct InsightsView: View {
    @EnvironmentObject var store: SessionStore

    var body: some View {
        NavigationStack {
            VStack(spacing: 12) {
                Text("Coming in Course 3, Session 11")
                    .font(.headline)
                Text("Weekly distance · HR trends · resting HR · VO₂ max")
                    .font(.subheadline)
                    .foregroundStyle(.secondary)
                    .multilineTextAlignment(.center)
            }
            .padding()
            .navigationTitle("Insights")
        }
    }
}

#Preview {
    InsightsView()
        .environmentObject(SessionStore())
}
