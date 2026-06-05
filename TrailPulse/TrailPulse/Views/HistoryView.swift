//
//  HistoryView.swift
//  TrailPulse
//
//  Course 1 Session 3 onward. Lists saved RunSessions.
//  Tapping one drills into SummaryView (Session 4).
//

import SwiftUI

struct HistoryView: View {
    @EnvironmentObject var store: SessionStore

    var body: some View {
        NavigationStack {
            if store.sessions.isEmpty {
                ContentUnavailableView(
                    "No runs yet",
                    systemImage: "figure.run.circle",
                    description: Text("Your first session will appear here.")
                )
            } else {
                List(store.sessions) { session in
                    NavigationLink {
                        SummaryView(session: session)
                    } label: {
                        row(for: session)
                    }
                }
                .navigationTitle("History")
            }
        }
    }

    private func row(for session: RunSession) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(session.startedAt, style: .date)
                .font(.headline)
            HStack(spacing: 12) {
                Label(String(format: "%.2f km", session.distanceMeters / 1000),
                      systemImage: "map")
                Label(durationString(session.duration),
                      systemImage: "clock")
            }
            .font(.subheadline)
            .foregroundStyle(.secondary)
        }
        .padding(.vertical, 4)
    }

    private func durationString(_ seconds: TimeInterval) -> String {
        let m = Int(seconds) / 60
        let s = Int(seconds) % 60
        return String(format: "%d:%02d", m, s)
    }
}

#Preview {
    HistoryView()
        .environmentObject(SessionStore())
}
