//
//  WatchRunView.swift
//  TrailPulseWatch Watch App
//
//  Course 2 Session 5: control surface on the watch — start/stop button +
//                      live pace mirrored from the phone.
//  Course 2 Session 6: replace mock HR with real HKWorkoutSession data.
//  Course 3 Session 10: add tap-to-capture-waypoint and complication wiring.
//

import SwiftUI

struct WatchRunView: View {
    @EnvironmentObject var connector: WatchConnector
    @State private var isRunning = false

    var body: some View {
        VStack(spacing: 10) {
            metric("HR",       connector.lastHeartRate.map { "\(Int($0))" } ?? "—")
            metric("Pace",     connector.lastPace ?? "—")
            metric("Distance", connector.lastDistance ?? "—")

            Button {
                isRunning.toggle()
                connector.send(command: isRunning ? "start" : "stop")
            } label: {
                Text(isRunning ? "Stop" : "Start")
                    .frame(maxWidth: .infinity)
            }
            .tint(isRunning ? .red : .green)
        }
        .padding()
    }

    private func metric(_ label: String, _ value: String) -> some View {
        HStack {
            Text(label).foregroundStyle(.secondary)
            Spacer()
            Text(value).monospacedDigit().fontWeight(.semibold)
        }
        .font(.callout)
    }
}
