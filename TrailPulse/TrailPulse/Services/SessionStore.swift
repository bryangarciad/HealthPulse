//
//  SessionStore.swift
//  TrailPulse
//
//  Sessions 1–2: in-memory store (good enough to demo end-to-end).
//  Session 3: swap the backing array for an NSPersistentContainer +
//             RunSessionEntity. Keep the public API the same so Views
//             written in earlier sessions don't change.
//

import Foundation
import Combine

@MainActor
final class SessionStore: ObservableObject {
    @Published private(set) var sessions: [RunSession] = []

    // MARK: - CRUD

    func save(_ session: RunSession) {
        if let idx = sessions.firstIndex(where: { $0.id == session.id }) {
            sessions[idx] = session
        } else {
            sessions.append(session)
        }
        sessions.sort { $0.startedAt > $1.startedAt }
    }

    func delete(id: UUID) {
        sessions.removeAll { $0.id == id }
    }

    // MARK: - Stats (used by Insights tab in Course 3)

    var totalDistanceMeters: Double {
        sessions.reduce(0) { $0 + $1.distanceMeters }
    }

    var totalSessions: Int { sessions.count }
}
