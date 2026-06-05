# TrailPulse — Teaching Guide

A 12-session iOS + watchOS curriculum where students build one real,
sensor-driven outdoor app from start to finish. Every session ships a
visible feature. Nothing is throwaway code.

---

## How to use this guide

For each session you'll find:

- **Learning objectives** — what the student should be able to do after the session.
- **Key APIs** — the Apple frameworks/classes introduced.
- **MVP deliverable** — the minimum required to pass the session and unblock the next one. If you're behind, build only this.
- **Extensions** — features to add when there's time, or to revisit in a later course. Treat them as a backlog.
- **Common pitfalls** — things students will get wrong; pre-empt them in lecture.

---

## The MVP rule

> If a session falls behind, **drop extensions, never the MVP**. Each MVP feeds the next session. Extensions are isolated and can be added in any later session without breaking earlier work.

A summary table is at the bottom of this guide — print it for the wall.

---

# Course 1 — iOS sensors (4 sessions)

The student leaves Course 1 with a working **phone-only** run tracker that records GPS + steps + altitude and saves sessions locally.

## Session 1 — Project setup, GPS, map

**Learning objectives**
- Create a SwiftUI iOS project, configure Info.plist privacy strings.
- Request and handle `CLLocationManager` authorization (when-in-use).
- Draw the user's location and a live path polyline on `Map`.

**Key APIs**
`CLLocationManager`, `CLLocationManagerDelegate`, `MapKit` (`Map`, `MapPolyline`, `UserAnnotation`, `MapCameraPosition`).

**MVP deliverable**
A `RunView` with a map showing the user's location, a "Start run" button that begins recording GPS samples, and a "Stop" button that ends recording. The path appears as an orange line as the user moves. State is in-memory only — that's fine for now.

**Extensions**
- Tap-to-recenter map button.
- Show horizontal accuracy radius around the user.
- Persist the last camera position across launches.
- Toggle between standard/satellite/hybrid map styles.

**Common pitfalls**
- Forgetting `NSLocationWhenInUseUsageDescription` → app silently fails to ask for permission.
- Setting `desiredAccuracy` and `distanceFilter` to the defaults (battery drain in the simulator goes unnoticed, but on device it's brutal).
- Calling `startUpdatingLocation()` before the user grants permission.

---

## Session 2 — Motion sensors

**Learning objectives**
- Read step count and cadence with `CMPedometer`.
- Read relative altitude changes with `CMAltimeter`.
- Compute live pace (min/km) and display in a stats HUD.
- Understand the difference between *absolute* (GPS altitude) and *relative* (altimeter) measurements.

**Key APIs**
`CMPedometer`, `CMAltimeter`, `CMMotionActivity`.

**MVP deliverable**
The `RunView` shows a live stats row: **Distance · Steps · Pace**. Numbers update during a run. Stop the run → numbers freeze.

**Extensions**
- Add cadence (steps/min) — already wired in `MotionManager`, just show it.
- Add a "motion activity" badge (walking/running/cycling) using `CMMotionActivityManager`.
- Show a small inline pace sparkline (last 60 seconds).
- Use the accelerometer to detect "stopped" state and auto-pause.

**Common pitfalls**
- `CMPedometer.currentPace` is **seconds per metre**, not min/km — students always forget the conversion.
- `CMAltimeter` requires `NSMotionUsageDescription` AND a real device (it doesn't work in the simulator).
- Pedometer updates fire on a background queue — students forget to dispatch back to main before updating `@Published` properties.

---

## Session 3 — Persistence, history list

**Learning objectives**
- Model a `RunSession` and persist it with **Core Data** (or SwiftData if your students are using iOS 17+ only).
- Build a `HistoryView` that lists saved sessions.
- Navigate from history list to a per-session detail screen.

**Key APIs**
`NSPersistentContainer`, `@FetchRequest`, `NavigationStack`, `NavigationLink`. (Alternative: `@Model` and SwiftData.)

**MVP deliverable**
At the end of a run, the session is saved (start time, duration, distance, steps, path coordinates). The History tab lists all saved sessions sorted by date. Tap a row → see a placeholder detail view.

**Extensions**
- Swipe-to-delete from the list.
- Group sessions by week with section headers.
- Add a "rename" / "add note" capability per session.
- Encode the path as a polyline string instead of separate entities (storage efficiency talking point).

**Common pitfalls**
- Storing `[CLLocationCoordinate2D]` directly — it's not Codable. Use the `LocationPoint` struct.
- Trying to do `fetchRequest` against a non-`NSManagedObject` model.
- Forgetting to save the context after inserting.

**Teacher trick**
The provided `SessionStore` is an in-memory stand-in. Switching it to Core Data in this session is a great chance to reinforce *protocols and dependency inversion* — Views don't change a line.

---

## Session 4 — Feedback, charts, summary screen

**Learning objectives**
- Trigger haptic feedback via `UIImpactFeedbackGenerator`.
- Play audio cues with `AVAudioPlayer` (lays groundwork for Course 2 Session 8).
- Use Swift Charts (`Charts` framework) to plot pace over time.
- Build a polished post-run summary view with map snapshot + stats grid.

**Key APIs**
`UIImpactFeedbackGenerator`, `AVAudioPlayer`, `Charts`, `MKMapSnapshotter`.

**MVP deliverable**
Tapping a row in History opens a `SummaryView` with: map snapshot of the path, a stats grid (distance, duration, steps, ascent), and a pace-over-time chart. During a run, a haptic + audio "ding" fires when each kilometre is crossed.

**Extensions**
- Add altitude profile chart underneath the pace chart.
- Add elevation gain/loss with smoothing (running avg of last 5 GPS samples).
- Customizable km vs mile units in Settings.
- Spoken pace announcements via `AVSpeechSynthesizer`.

**Common pitfalls**
- Kilometre-trigger logic that fires multiple times when the user lingers near a km boundary — track which km has been *announced*, not just the current distance.
- Charts framework requires iOS 16+ deployment target.

**End-of-course checkpoint**
Student can hand their phone to a friend, the friend runs around the block, hands the phone back, and the run is in history with a pretty summary. If they can do that, they pass Course 1.

---

# Course 2 — Wearables, HealthKit, media (4 sessions)

The student leaves Course 2 with a paired Apple Watch app, real heart-rate data, and the ability to capture photos + voice memos during a run.

## Session 5 — Watch app target, WatchConnectivity

**Learning objectives**
- Add a watchOS target to an existing iOS project.
- Understand the architecture: paired phone/watch processes, message passing.
- Build a minimal watch UI with start/stop button + live mirrored stats.
- Use `WCSession` to send messages bidirectionally.

**Key APIs**
`WCSession`, `WCSessionDelegate`, `WKApplication`, basic SwiftUI on watchOS.

**MVP deliverable**
A watch app that shows current pace + distance mirrored from the phone (updated via `WCSession.sendMessage`), with a Start/Stop button on the watch that controls the phone's run. The phone's UI reflects state initiated from the watch.

**Extensions**
- Use `transferUserInfo` for reliability vs `sendMessage` for liveness — discuss tradeoffs.
- Add a complication placeholder showing today's km (real wiring lands in Session 10).
- Persist last-known stats so the watch shows them when the phone is asleep.
- Use Digital Crown for scrolling between stat screens.

**Common pitfalls**
- Forgetting that `WCSession.isSupported()` must be checked before activation.
- `sendMessage` requires the counterpart to be reachable. For background-safe delivery, use `transferUserInfo`.
- Bundle identifiers/team mismatch between the watch target and the iOS target is the #1 silent failure — always check Signing & Capabilities on both.

---

## Session 6 — HealthKit, heart rate, HKWorkout

**Learning objectives**
- Request HealthKit read & write permissions.
- Start an `HKWorkoutSession` on the watch.
- Stream live heart-rate samples via `HKAnchoredObjectQuery`.
- Persist a complete `HKWorkout` to Apple Health on session end.

**Key APIs**
`HKHealthStore`, `HKWorkoutSession`, `HKLiveWorkoutBuilder`, `HKAnchoredObjectQuery`, `HKQuantityType`.

**MVP deliverable**
On the watch, starting a run begins an `HKWorkoutSession` (type: running or hiking). Live heart rate appears on both the watch and phone (via WatchConnectivity). Stopping a run saves an `HKWorkout` to the Health app with distance, calories, and HR samples. The student opens the Health app and *sees their run there*.

**Extensions**
- Read and display resting heart rate (`HKQuantityTypeIdentifier.restingHeartRate`).
- Heart-rate zones (Z1–Z5) computed from age + max HR formula.
- Calorie estimate via `HKLiveWorkoutBuilder`'s built-in `activeEnergyBurned`.
- HRV during cool-down phase.

**Common pitfalls**
- Forgetting the HealthKit capability in both targets.
- `HKHealthStore` is not a singleton in the SDK — but **must** be treated as one in your app (one instance, kept alive). Students often create new instances and authorization "resets".
- Watch HealthKit requires the watch app's Info.plist privacy strings *too*, not just the phone's.

---

## Session 7 — Media: photos + GPS-tagged waypoints

**Learning objectives**
- Open a camera capture UI from SwiftUI.
- Save captured photos to the app's container.
- Attach a `MediaItem` to the active `RunSession` with GPS coordinates.
- Render photo pins on the map.

**Key APIs**
`PHPickerViewController` (UIKit bridge) or `Camera` (iOS 17+), `UIImagePickerController`, file system writes via `FileManager`, `MKAnnotation` / `Annotation` for the map.

**MVP deliverable**
During a run, a "📷 Capture" button on the `RunView`. Tapping opens the camera; the captured photo is saved to disk, a `MediaItem` is added to the session with the current coordinate. After the run, the `SummaryView` shows the path with photo pins, tapping a pin shows the photo full-screen.

**Extensions**
- Photo strip thumbnail row at the bottom of `SummaryView`.
- Filters (sepia, black-and-white) via `CIImage` for fun.
- Save originals to the user's Photo Library (PHPhotoLibrary).
- EXIF tagging with GPS coordinates so exported photos retain location.

**Common pitfalls**
- Writing photos to the app bundle (read-only) instead of `FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)`.
- Camera permissions on simulator → falls back to photo picker, students panic. Mention upfront that camera is device-only.

---

## Session 8 — Media: voice memos, background audio

**Learning objectives**
- Record audio via `AVAudioRecorder`.
- Configure `AVAudioSession` for playback during a run.
- Enable Background Modes → Audio so memos can record with the screen off.
- Play back memos in the `SummaryView`.

**Key APIs**
`AVAudioRecorder`, `AVAudioPlayer`, `AVAudioSession`, Background Modes capability.

**MVP deliverable**
A "🎙 Voice memo" button on the `RunView`. Tap-and-hold to record; release to save. Memo appears as a `MediaItem` of kind `.voiceMemo` on the session, with a play button on the `SummaryView`.

**Extensions**
- Live audio waveform visualization while recording.
- Auto-transcription via `SFSpeechRecognizer` so memos become searchable text.
- Mix the audio cues from Session 4 with voice playback — talk about audio session categories.
- Trim memo with `AVMutableComposition` before saving.

**Common pitfalls**
- Recording without setting `AVAudioSession.Category` → no audio captured. Use `.playAndRecord`.
- Background audio requires the **capability** AND a non-silent audio session category at the moment the app backgrounds.

**End-of-course checkpoint**
Student opens their phone in Health.app and sees a run they did. The run has photos pinned on the map and a voice memo they recorded mid-run. If yes → Course 2 done.

---

# Course 3 — Notifications, advanced sensors, polish (4 sessions)

The student leaves Course 3 with a shippable, polished app: smart notifications, watch complications, an Insights dashboard pulling from HealthKit history, and shareable export.

## Session 9 — Local notifications & smart alerts

**Learning objectives**
- Request notification authorization, schedule local notifications.
- Build a domain-specific *alerting engine*: HR zone breach, pace dropping below target.
- Customize notification appearance with `UNNotificationContent`.
- Render notifications on the watch with a custom UI.

**Key APIs**
`UNUserNotificationCenter`, `UNMutableNotificationContent`, `UNNotificationCategory`, `UNTimeIntervalNotificationTrigger`, watchOS notification scenes.

**MVP deliverable**
A `RunAlertEngine` service observes HR and pace; when HR exceeds Z5 for >30s, or pace drops 20% below the session average, a local notification fires. Watching the watch buzz mid-run is the demo moment. Each fired alert is logged to `session.alerts`.

**Extensions**
- Action buttons on the notification ("Pause run", "Snooze 5min").
- Smart "you've been running for 30 minutes" milestone notification.
- "Low battery" alerts.
- Notification grouping — surface only the most recent of a kind, not 12 of them.
- Time-sensitive interruption level so alerts pierce Focus modes.

**Common pitfalls**
- Asking for `.alert .sound .badge` permissions but no provisional path — students reject and then can't easily re-enable in Settings.
- Scheduling a notification with `timeInterval: 0` — it never fires; minimum is ~0.1s.

---

## Session 10 — Watch sensors, complications, fall detection

**Learning objectives**
- Read watch-specific sensors: `WKAccelerometer`, blood oxygen, wrist motion.
- Build a `WidgetKit`-style watch complication.
- Configure `CLKComplicationDataSource` (or the modern WidgetKit equivalent for watchOS 10+).
- Understand "always-on" considerations for watch UIs.

**Key APIs**
`CMMotionManager` (on watch), `HKQuantityTypeIdentifier.oxygenSaturation`, `WidgetKit` on watchOS, `WKApplication.shared().isAutorotating`.

**MVP deliverable**
A watch complication on the modular face that shows today's total kilometres and updates after each run. Bonus: a "blood oxygen" reading on the watch screen during a rest period.

**Extensions**
- Detect a fall via accelerometer spikes >2.5g + sudden orientation change.
- "Auto-pause" using watch wrist motion (stopped swinging arms).
- Multiple complication families (circular, rectangular, inline).
- Live Activity on the phone Lock Screen during a run (`ActivityKit`).

**Common pitfalls**
- Complications can only refresh a handful of times per day — talk about budget.
- The classic `CLKComplicationDataSource` is deprecated in favour of WidgetKit; cover both if your students will work on legacy apps.

---

## Session 11 — HealthKit history & Insights dashboard

**Learning objectives**
- Query historical HealthKit data with `HKStatisticsCollectionQuery`.
- Build a weekly summary view (total km, total time, average HR, etc.).
- Render trends with Swift Charts.
- Cache query results to avoid jank.

**Key APIs**
`HKStatisticsCollectionQuery`, `HKSampleQuery`, `HKQueryAnchor`, `Charts`.

**MVP deliverable**
The Insights tab is no longer a placeholder. It shows: this week's total distance, weekly trend bar chart for the last 6 weeks, average HR over the last 30 days, and resting HR trend. Data is pulled from HealthKit (not just TrailPulse's own store) so runs recorded in other apps are included.

**Extensions**
- "Streaks": consecutive days with at least one workout.
- VO₂ max trend (`HKQuantityTypeIdentifier.vo2Max`).
- Compare two weeks side-by-side.
- ML model (Create ML) that predicts the user's "form" from cadence + HR variance — advanced, optional.

**Common pitfalls**
- `HKStatisticsCollectionQuery` is one of the chunkier APIs in HealthKit — give students a working snippet rather than asking them to build it from docs alone.
- Anchored queries leak observers if not invalidated — show how to keep a single anchor.

---

## Session 12 — Sharing, export, widgets, polish

**Learning objectives**
- Build a home screen widget with `WidgetKit`.
- Export a session as a GPX file.
- Use `ShareLink` / `UIActivityViewController` to share.
- Polish: app icon, launch screen, accessibility audit, Dark Mode review.

**Key APIs**
`WidgetKit`, `ShareLink`, `UIActivityViewController`, GPX XML hand-rolled (or third-party `CoreGPX` for the bold).

**MVP deliverable**
A home screen widget shows last run + total km this week. Each session in History has a "Share" button that exports a GPX file. The app is App Store–ready (icon set, launch screen, all permissions clearly described, no crashes on cold launch).

**Extensions**
- Lock Screen widgets (iOS 16+ accessory family).
- PDF export of the summary view via `ImageRenderer`.
- App Clip for "try a sample run".
- iCloud sync of sessions via `CloudKit`.
- Localized strings — French, Spanish, etc.

**Common pitfalls**
- Widget previews look fine but blow up at runtime — students forget that widget memory is severely limited.
- GPX files need a proper XML namespace declaration or Strava/Garmin will reject them.

**End-of-course checkpoint**
The student does a 1km walk on real Apple devices. The result appears in their app's history, in Apple Health, on their watch complication, and in a home screen widget. They tap Share → AirDrop the GPX to themselves → open in another app. If yes → curriculum complete.

---

# MVP-only path (when you're behind)

Drop these features if time is tight. The app still ships at the end of Session 12 with everything below.

| Course | Session | MVP only |
|--------|---------|----------|
| 1 | 1 | GPS map + start/stop + path polyline |
| 1 | 2 | Steps + pace + distance stats row |
| 1 | 3 | Core Data persistence + History list |
| 1 | 4 | Summary view + pace chart |
| 2 | 5 | Watch target + WatchConnectivity start/stop |
| 2 | 6 | HealthKit auth + HR stream + HKWorkout save |
| 2 | 7 | Camera capture → GPS-tagged photo on map |
| 2 | 8 | Voice memo record + playback |
| 3 | 9 | Local notifications on HR zone breach |
| 3 | 10 | Watch complication showing today's km |
| 3 | 11 | Insights tab with weekly chart |
| 3 | 12 | GPX export + ShareLink + icon polish |

# Extensions backlog (come back when there's time)

Pulled forward from each session above:

- **Map/UX**: recenter button, accuracy radius, satellite toggle, motion activity badge, inline pace sparkline, auto-pause, swipe-to-delete history, weekly section headers, session notes, custom units, spoken pace.
- **Health**: resting HR, HR zones, HRV cool-down, VO₂ max, streaks, "form score" via Create ML.
- **Media**: photo strip, CI filters, EXIF GPS export, audio waveforms, voice-to-text, audio trim.
- **Watch**: multiple complication families, Live Activity on Lock Screen, fall detection, wrist auto-pause.
- **Notifications**: action buttons, milestones, low-battery, grouping, time-sensitive level.
- **Sharing**: PDF export, Lock Screen widgets, App Clip, CloudKit sync, localization.

A good way to use the extension list: have each student pick **two** extensions across the course to build into a final project showcase at the end of Course 3.

---

# Suggested grading rubric (per session)

| Weight | Criterion |
|--------|-----------|
| 50% | MVP deliverable works on a real device |
| 20% | Code organization (services separate from views, no force-unwraps, naming) |
| 15% | Privacy strings, permissions handled gracefully |
| 10% | UI polish (no overlapping text, dark mode legible, accessibility labels on buttons) |
| 5%  | At least one extension attempted |

The 5% extension carrot rewards initiative without punishing students who barely scrape the MVP.

---

# Things to mention in lecture 1 (don't skip)

- "By session 12, you will have built an app that lives on your wrist." (Sells the arc.)
- The architectural rule: **services don't import SwiftUI; views don't import Core Motion**. Decoupling is the gift that lets every new feature land cleanly.
- The MVP rule above.
- That Apple's sensor APIs are inherently asynchronous and side-effecting — students need to be comfortable with Combine / async / @Published before Course 2.
- Real device testing is non-negotiable from Session 2 onward. Plan it.
