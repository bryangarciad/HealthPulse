# TrailPulse

A trail-running companion app built across three iOS development courses.
Each session adds a feature; nothing gets thrown away.

## Prerequisites

- macOS 14+ with Xcode 16+
- Apple Developer account (free tier is fine for device testing)
- iPhone running iOS 17+ for full sensor testing
- Apple Watch (Series 4+) running watchOS 10+ — needed from Course 2 onward
- Paired physical devices for GPS, motion, HealthKit testing
  (simulators don't surface real sensors)

## Setting up the project (Session 1, ~10 minutes)

1. Open Xcode → File → New → Project → iOS → App
2. Product name: **TrailPulse**, Interface: **SwiftUI**, Language: **Swift**,
   Bundle identifier: `com.<yourorg>.TrailPulse`
3. Quit Xcode, drop the contents of this folder into your project folder,
   re-open. Drag the `Shared` and `Views` groups into the navigator.
4. Add the following keys to `Info.plist`:

| Key | Value |
|-----|-------|
| `NSLocationWhenInUseUsageDescription` | "Tracks your run on the map." |
| `NSLocationAlwaysAndWhenInUseUsageDescription` | "Records your run while the screen is off." |
| `NSMotionUsageDescription` | "Counts your steps and altitude change." |
| `NSPhotoLibraryAddUsageDescription` | "Saves waypoint photos to your library." (Course 2 Session 7) |
| `NSCameraUsageDescription` | "Takes waypoint photos during a run." (Course 2 Session 7) |
| `NSMicrophoneUsageDescription` | "Records voice memos during a run." (Course 2 Session 8) |
| `NSHealthShareUsageDescription` | "Reads your workout history." (Course 2 Session 6) |
| `NSHealthUpdateUsageDescription` | "Saves your runs to Apple Health." (Course 2 Session 6) |

5. In Signing & Capabilities, add:
   - **Background Modes** → Location updates, Audio (added in Session 8)
   - **HealthKit** (added in Course 2 Session 6)

## Folder layout

```
TrailPulse/
├── TrailPulse/                  iOS target source
│   ├── TrailPulseApp.swift      app entry
│   ├── ContentView.swift        root tabs
│   ├── Views/
│   ├── Models/                  (empty — uses Shared/)
│   └── Services/                LocationManager, MotionManager, SessionStore
├── TrailPulseWatch Watch App/   watchOS target (added in Course 2)
│   ├── TrailPulseWatchApp.swift
│   ├── Views/
│   └── Services/
└── Shared/                      types used by both targets
    └── RunSession.swift
```

The `Shared` folder is added to **both** targets via the file inspector's
Target Membership checkboxes — same source, two compiles.

## Working with the curriculum

Each session has TODO markers in the relevant file (search "Course X Session Y").
The MVP path produces a shippable app in 12 sessions; the **Extensions**
section of `TEACHING_GUIDE.md` is the come-back-later backlog.
