//
//  WatchConnector.swift
//  TrailPulseWatch Watch App
//
//  Course 2 Session 5: WatchConnectivity glue. Same class lives on the
//  iOS side too, so most of the body is shared via #if os(watchOS) blocks.
//
//  Teaching note: keep the wire format dirt-simple — a [String: Any]
//  dictionary with a "command" key. Students should not be wrestling
//  with Codable + WCSession in their first watchOS session.
//

import Foundation
import WatchConnectivity

final class WatchConnector: NSObject, ObservableObject {
    @Published var lastHeartRate: Double?
    @Published var lastPace: String?
    @Published var lastDistance: String?

    override init() {
        super.init()
        if WCSession.isSupported() {
            WCSession.default.delegate = self
            WCSession.default.activate()
        }
    }

    func send(command: String) {
        guard WCSession.default.activationState == .activated else { return }
        let payload: [String: Any] = ["command": command, "ts": Date().timeIntervalSince1970]
        WCSession.default.sendMessage(payload, replyHandler: nil) { error in
            print("WC send error: \(error)")
        }
    }
}

extension WatchConnector: WCSessionDelegate {
    func session(_ session: WCSession,
                 activationDidCompleteWith state: WCSessionActivationState,
                 error: Error?) { }

    #if os(iOS)
    func sessionDidBecomeInactive(_ session: WCSession) { }
    func sessionDidDeactivate(_ session: WCSession) { WCSession.default.activate() }
    #endif

    func session(_ session: WCSession,
                 didReceiveMessage message: [String: Any]) {
        DispatchQueue.main.async {
            if let hr = message["hr"] as? Double { self.lastHeartRate = hr }
            if let p  = message["pace"] as? String { self.lastPace = p }
            if let d  = message["distance"] as? String { self.lastDistance = d }
        }
    }
}
