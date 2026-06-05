//
//  RunView.swift
//  TrailPulse
//
//  The "Run" screen. This is the view students will keep enriching
//  throughout all 12 sessions:
//
//    Course 1 Session 1: start/stop + map with GPS path
//    Course 1 Session 2: live stats row (steps, pace, distance)
//    Course 1 Session 4: haptic feedback on each kilometre
//    Course 2 Session 5: WatchConnectivity bridge (watch can start runs)
//    Course 2 Session 6: HR display from watch
//    Course 2 Session 7: "Capture photo" button → MediaItem
//    Course 3 Session 9: visual indicator when alerts fire
//
//  Keep this file the spine of the lesson sequence.
//

import SwiftUI
import MapKit

struct RunView: View {

    @EnvironmentObject var locationManager: LocationManager
    @EnvironmentObject var motionManager: MotionManager
    @EnvironmentObject var sessionStore: SessionStore

    @State private var isRunning = false
    @State private var currentSession: RunSession?
    @State private var cameraPosition: MapCameraPosition = .userLocation(
        fallback: .automatic
    )

    var body: some View {
        NavigationStack {
            VStack(spacing: 0) {
                mapView
                statsBar
                controlButton
            }
            .navigationTitle("TrailPulse")
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                if locationManager.authorizationStatus == .notDetermined {
                    locationManager.requestPermission()
                }
            }
        }
    }

    // MARK: - Map

    @ViewBuilder
    private var mapView: some View {
        Map(position: $cameraPosition) {
            UserAnnotation()

            if !locationManager.recordedPoints.isEmpty {
                MapPolyline(coordinates: locationManager.recordedPoints.map(\.coordinate))
                    .stroke(.orange, lineWidth: 4)
            }
        }
        .mapControls {
            MapUserLocationButton()
            MapCompass()
        }
    }

    // MARK: - Stats row

    private var statsBar: some View {
        HStack {
            stat(label: "Distance",
                 value: distanceString(locationManager.totalDistanceMeters))
            Divider()
            stat(label: "Steps",
                 value: "\(motionManager.stepsThisSession)")
            Divider()
            stat(label: "Pace",
                 value: paceString(motionManager.currentPaceMinPerKm))
        }
        .padding(.vertical, 12)
        .background(Color(.systemGray6))
    }

    private func stat(label: String, value: String) -> some View {
        VStack(spacing: 4) {
            Text(value)
                .font(.title3.monospacedDigit())
                .fontWeight(.semibold)
            Text(label)
                .font(.caption)
                .foregroundStyle(.secondary)
        }
        .frame(maxWidth: .infinity)
    }

    // MARK: - Big button

    private var controlButton: some View {
        Button {
            isRunning ? endRun() : startRun()
        } label: {
            Text(isRunning ? "Stop" : "Start run")
                .font(.title2.bold())
                .foregroundStyle(.white)
                .frame(maxWidth: .infinity, minHeight: 60)
                .background(isRunning ? Color.red : Color.green)
                .clipShape(RoundedRectangle(cornerRadius: 16))
        }
        .padding()
    }

    // MARK: - Run lifecycle

    private func startRun() {
        currentSession = RunSession()
        locationManager.startTracking()
        motionManager.startUpdates()
        isRunning = true
    }

    private func endRun() {
        locationManager.stopTracking()
        motionManager.stopUpdates()
        isRunning = false

        guard var session = currentSession else { return }
        session.endedAt = Date()
        session.path = locationManager.recordedPoints
        session.steps = motionManager.stepsThisSession
        session.distanceMeters = locationManager.totalDistanceMeters
        // ascent = best-effort from the relative altimeter for now
        session.ascentMeters = max(0, motionManager.relativeAltitudeMeters)

        sessionStore.save(session)
        currentSession = nil
    }

    // MARK: - Formatting

    private func distanceString(_ meters: Double) -> String {
        if meters < 1000 {
            return String(format: "%.0f m", meters)
        } else {
            return String(format: "%.2f km", meters / 1000.0)
        }
    }

    private func paceString(_ minPerKm: Double?) -> String {
        guard let p = minPerKm, p.isFinite else { return "—" }
        let mins = Int(p)
        let secs = Int((p - Double(mins)) * 60)
        return String(format: "%d:%02d", mins, secs)
    }
}

#Preview {
    RunView()
        .environmentObject(LocationManager())
        .environmentObject(MotionManager())
        .environmentObject(SessionStore())
}
