//
//  SummaryView.swift
//  TrailPulse
//
//  Course 1 Session 4: per-run summary with map snapshot + stats.
//  Course 2 Session 6: add HR chart from heartRateSamples.
//  Course 2 Session 8: add photo strip + voice-memo playback.
//
//  TODO students: replace this placeholder with the real layout in Session 4.
//

import SwiftUI
import MapKit
import Charts

struct SummaryView: View {
    let session: RunSession

    var body: some View {
        ScrollView {
            VStack(alignment: .leading, spacing: 24) {
                mapPreview
                statsGrid

                // Session 4: replace with `Chart(...)` showing pace over time
                // Session 6: extend with heart-rate overlay
                Text("Pace + HR chart goes here in Session 4 / 6")
                    .font(.footnote)
                    .foregroundStyle(.secondary)
                    .frame(maxWidth: .infinity, alignment: .center)
                    .padding()
                    .background(Color(.systemGray6))
                    .clipShape(RoundedRectangle(cornerRadius: 12))
            }
            .padding()
        }
        .navigationTitle(session.startedAt.formatted(date: .abbreviated, time: .shortened))
    }

    @ViewBuilder
    private var mapPreview: some View {
        if !session.path.isEmpty {
            Map {
                MapPolyline(coordinates: session.path.map(\.coordinate))
                    .stroke(.orange, lineWidth: 4)
            }
            .frame(height: 220)
            .clipShape(RoundedRectangle(cornerRadius: 12))
            .allowsHitTesting(false)
        }
    }

    private var statsGrid: some View {
        LazyVGrid(columns: [GridItem(.flexible()), GridItem(.flexible())],
                  spacing: 12) {
            statTile("Distance",
                     String(format: "%.2f km", session.distanceMeters / 1000))
            statTile("Duration", durationString(session.duration))
            statTile("Steps", "\(session.steps)")
            statTile("Ascent", String(format: "%.0f m", session.ascentMeters))
        }
    }

    private func statTile(_ label: String, _ value: String) -> some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
            Text(value)
                .font(.title3.monospacedDigit())
                .fontWeight(.semibold)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding()
        .background(Color(.systemGray6))
        .clipShape(RoundedRectangle(cornerRadius: 12))
    }

    private func durationString(_ seconds: TimeInterval) -> String {
        let h = Int(seconds) / 3600
        let m = (Int(seconds) % 3600) / 60
        let s = Int(seconds) % 60
        return h > 0
            ? String(format: "%d:%02d:%02d", h, m, s)
            : String(format: "%d:%02d", m, s)
    }
}
