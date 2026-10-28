# Releasing Mushaf+ to Google Play and the App Store

What is already in the repository, and what only the account owner can do.

## Already in place

- Display name **Mushaf+** on every platform; bundle ids `com.salimjemai.mushafplus` (Android) and `com.salimjemai.mushafplus` (iOS/macOS). Keep these: changing them later creates a new app on the stores.
- Launcher icons and splash screens (`flutter_launcher_icons`, `flutter_native_splash`, source `tool/render_icon.dart`).
- Permission texts: microphone, speech recognition and location (`ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`).
- iOS privacy manifest `ios/Runner/PrivacyInfo.xcprivacy` (no tracking, no collected data, required-reason APIs declared). **Add it to the Runner target once in Xcode** (File → Add Files to "Runner", tick the Runner target) so it ships in the bundle.
- Privacy policy page: https://salimjemai.github.io/MushafPlus/privacy.html (source `web/privacy.html`), linked from Settings → About. Both stores require this URL.
- Android release signing reads `android/key.properties` (see `key.properties.example`). CI signs the App Bundle when the `ANDROID_KEYSTORE_BASE64`, `ANDROID_KEYSTORE_PASSWORD`, `ANDROID_KEY_ALIAS` and `ANDROID_KEY_PASSWORD` secrets exist.
- CI builds: analyze + tests, signed/unsigned `.aab` and `.apk`, Windows, and an unsigned iOS build on macOS to catch compile errors. Artifacts are attached to each run.

## Versioning

`pubspec.yaml` → `version: 1.0.0+1`. The part before `+` is the store version, the number after is the build number. Every upload must raise the build number; CI uses it as-is.

## Google Play (Android)

1. Create the keystore once and keep it safe (losing it means you can never update the app):
   ```bash
   keytool -genkey -v -keystore mushafplus-release.jks -keyalg RSA -keysize 2048 -validity 10000 -alias mushafplus
   ```
2. Locally: copy it to `android/`, fill `android/key.properties`. In GitHub: add the four secrets above (`base64 -w0 mushafplus-release.jks` for the first).
3. Build: `flutter build appbundle --release` → `build/app/outputs/bundle/release/app-release.aab` (or download the CI artifact).
4. Play Console ($25 once): create the app "Mushaf+", upload the `.aab` to Internal testing first.
5. Fill in: store listing (short/long description, 2–8 phone screenshots, 1024×500 feature graphic, 512×512 icon), content rating questionnaire, target audience, **Data safety** (declare: location collected on device only, not shared; no data collected by the developer), privacy policy URL, App access (no login).
6. Promote Internal → Closed/Open testing → Production. New personal developer accounts must run a closed test with 12 testers for 14 days before production access.

## App Store (iOS)

1. Apple Developer Program ($99/year) and a Mac with Xcode (or a macOS CI runner with certificates).
2. In Xcode open `ios/Runner.xcworkspace`, set your Team under Signing & Capabilities; automatic signing creates the certificates. Add `PrivacyInfo.xcprivacy` to the target (see above).
3. Build and upload: `flutter build ipa --release` then upload `build/ios/ipa/*.ipa` with Transporter or `xcrun altool`, or archive from Xcode (Product → Archive → Distribute).
4. App Store Connect: create the app "Mushaf+", fill the listing (screenshots for 6.7" and 6.5" iPhone and 12.9" iPad, description, keywords, support URL, privacy policy URL), **App Privacy** answers (Location: used for app functionality, not linked to identity; no tracking), age rating, and export compliance (the app uses only HTTPS: answer "No" to custom encryption).
5. Test with TestFlight, then submit for review. Reviewers will exercise microphone and location: keep the permission texts honest and the features working without an account.

## Store listing text (starting point)

**Short:** The Quran as a real Mushaf, with tajweed colours, recitation checking, word-by-word meanings, hadith books and masjid prayer times.

**Long:** Mushaf+ opens the Quran as a printed book you turn page by page, with every letter coloured by its tajweed rule and an explanation one tap away. Recite from memory and the app marks each word green or red. Read 100+ translations and word-by-word meanings, listen to twenty reciters at any speed, and keep notes, highlights and bookmarks. The nine hadith collections open like books and export to PDF. Masjids get precise prayer, iqama and Jumu'ah times, a Qibla compass, adhans, and widgets to embed on their website. Works offline for the Quran text, tajweed and anything you download. In English, Arabic, French, Urdu, Indonesian and Turkish.

## Support Mushaf+ (tip jar and donations)

Apple (guideline 3.1.1) and Google (Payments policy) require that a voluntary tip to the developer inside the app goes through their own in-app purchase, with no link or mention of other payment methods in the iOS/Android app. The website has no such rule. The code follows that split (`lib/data/donations.dart`, `lib/features/support/support_screen.dart`, Settings → Support Mushaf+ and the home card):

- **iOS / Android:** three consumable products `mushafplus_tip_small`, `mushafplus_tip_medium`, `mushafplus_tip_large`. Create them with exactly these ids:
  - App Store Connect → the app → In-App Purchases → "+" → Consumable; set a reference name, a price tier per product (e.g. 0.99 / 4.99 / 9.99), a localized display name ("Small tip", …) and a one-line description; add a review screenshot of the Support screen. In Xcode add the **In-App Purchase** capability to the Runner target and accept the Paid Apps agreement + banking/tax forms in App Store Connect, otherwise products never load.
  - Play Console → Monetize → Products → In-app products → Create; same ids, prices, titles. Set up the merchant account (Payments profile) first. Test with license testers (Setup → License testing) on an internal-testing build.
  - The screen shows "Tips are not available right now" until the store returns the products; nothing in the app is unlocked by a tip (keep it that way, it is what makes the tip a simple consumable).
- **Web / desktop:** fill `donationLinks` (Stripe Payment Link, PayPal donate button, Ko-fi, …) and/or `bankDetails` in `lib/data/donations.dart`; empty entries are hidden and the page says donations are coming soon. These links never appear in the store builds.

## Before each release

- `flutter analyze` and `flutter test` green; CI green.
- Bump `version:` in `pubspec.yaml`.
- Smoke test on a phone: audio, recitation (microphone prompt), Qibla (motion prompt), masjid lookup, downloads.
- Update `web/privacy.html` if a new service is contacted.

## Watches: Wear OS and Apple Watch

Both companions were added without a Mac or a watch at hand; what the Windows machine could not verify is listed under "By hand" below.

### Wear OS (same Flutter app, `wear` flavor)

- `android/app/build.gradle.kts` defines two product flavors with the **same application id**: `phone` (unchanged app) and `wear`. The `wear` flavor merges `android/app/src/wear/AndroidManifest.xml` on top of the main manifest: `<uses-feature android:name="android.hardware.type.watch" />` (so Play never offers it to phones), `com.google.android.wearable.standalone = true` (it works without a phone: prayer times, Qibla and the Quran text are computed or bundled on the watch), and `required="false"` for compass, GPS, Bluetooth, microphone and touchscreen. Its version code is the pubspec build number plus 100 000, because Play wants distinct version codes per form factor.
- At runtime `MainActivity` answers the `mushafplus/device` channel (`FEATURE_WATCH` / `UI_MODE_TYPE_WATCH`, `isScreenRound`) and `lib/main.dart` overrides `deviceFormProvider`; on a watch `MushafPlusApp` shows `lib/features/watch/` instead of the phone shell: five swipeable pages, black background, content kept inside the circle on round screens: next prayer countdown and today's five times (with "Use my location" when no place is set), Qibla dial, tasbih counter (haptic every 33, long-press resets), verse of the day, and "Recite & check" (pick a surah, tap the microphone, words colour as they are heard, a buzz for each wrong word).
- Build: `flutter build appbundle --release --flavor wear` → `build/app/outputs/bundle/wearRelease/app-wear-release.aab`; the phone build is now `--flavor phone` (`.../phoneRelease/app-phone-release.aab`). CI builds and uploads both (`mushaf-plus-android`, `mushaf-plus-wear-os`).
- Preview without a watch: `flutter build web --release --dart-define=MUSHAF_WATCH=true -o build/web_watch` and open it in a 192×192 browser window; or run the Wear OS emulator (Android Studio → Device Manager → Wear OS Large Round) and `flutter run --flavor wear -d <emulator>`.
- Play Console: Advanced settings → Form factors → **Add form factor → Wear OS**, then upload the `wear` bundle to the Wear OS track (Release → Wear OS); it needs at least one 1:1 screenshot (384–512 px) and the Wear OS app-quality questionnaire. Keep the phone bundle on the normal production track. Both must be signed with the same key.

### Apple Watch ("Mushaf+ Watch", SwiftUI)

Flutter does not run on watchOS, so the watch app is native SwiftUI, fed by the iPhone app. Note on data flow: an App Group does **not** cross devices, so the phone sends the data with **WatchConnectivity** (`updateApplicationContext`, delivered even when the watch app is closed) and the watch app stores it in the App Group `group.com.salimjemai.mushafplus`, which is what the complication reads. The Flutter side (`lib/data/watch_sync.dart`) builds the payload (place, 7 days of prayer times as epoch seconds, 7 verses of the day with the user's translation, and the interface strings in the app language) and calls the `mushafplus/watch` channel on launch, on resume and whenever the active place changes; `ios/Runner/WatchBridge.swift` keeps a copy in the App Group and sends it.

Recitation checking on the watch: watchOS has no speech recognition API, so `ios/MushafWatch/ReciteSession.swift` records the watch microphone, streams 16 kHz PCM to the phone, and `ios/Runner/RecitationRelay.swift` runs Apple's Arabic recogniser plus the Swift port of the matcher (`RecitationMatcher.swift`) and sends word statuses back; the watch colours the words and plays a haptic on each wrong word. The first message wakes the iPhone app in the background, but recognition is most reliable while Mushaf+ is open on the phone (an imam leading the prayer keeps the phone in a pocket with the app open).

Files in the repository:

| Path | Target |
|---|---|
| `ios/Runner/WatchBridge.swift`, `RecitationRelay.swift`, `RecitationMatcher.swift`, `Runner.entitlements` | Runner (already in `project.pbxproj`; CI compiles them) |
| `ios/MushafWatch/*.swift`, `Info.plist`, `MushafWatch.entitlements` | Watch App (to create) |
| `ios/MushafWatch/Shared/WatchPayload.swift` | Watch App **and** complication |
| `ios/MushafWatchComplication/MushafWatchComplication.swift`, `.entitlements` | Complication (widget extension, to create) |

**By hand, in Xcode on a Mac (once):**

1. Open `ios/Runner.xcworkspace`. File → New → Target → watchOS → **App**. Product name `Mushaf+ Watch`, bundle identifier `com.salimjemai.mushafplus.watchkitapp`, Interface SwiftUI, Language Swift, tick **Include Complication**; when asked, "Watch App for Existing iOS App" → Runner. Minimum deployment: watchOS 10.0. Xcode adds an "Embed Watch Content" phase to Runner.
2. In the new Watch App target delete the template `ContentView.swift` and `…App.swift`, then File → Add Files to "Runner" → select every file in `ios/MushafWatch/` (including `Shared/`), ticking only the Watch App target. Then select `Shared/WatchPayload.swift` and also tick the complication target in the File Inspector.
3. In the complication target delete the template widget files and add `ios/MushafWatchComplication/MushafWatchComplication.swift`. Its bundle id must be `com.salimjemai.mushafplus.watchkitapp.complication`.
4. Info keys: either set the Watch App target's Build Settings → *Info.plist File* to `MushafWatch/Info.plist` and *Generate Info.plist File* to No, or copy `NSLocationWhenInUseUsageDescription`, `NSMicrophoneUsageDescription`, `NSSpeechRecognitionUsageDescription` and `WKCompanionAppBundleIdentifier = com.salimjemai.mushafplus` into the target's Info tab.
5. Signing & Capabilities, for **Runner, Mushaf+ Watch and the complication**: set the Team, then "+ Capability → App Groups" and add `group.com.salimjemai.mushafplus` (automatic signing registers it in the developer portal). Point *Code Signing Entitlements* at `Runner/Runner.entitlements`, `MushafWatch/MushafWatch.entitlements` and `MushafWatchComplication/MushafWatchComplication.entitlements` (or let Xcode write its own; the content is the same). Runner also needs the **Background Modes → Audio** capability only if you want recognition to continue with the phone locked; otherwise nothing more.
6. Add an app icon to the Watch App's `Assets.xcassets` (1024×1024, same artwork as `assets/icon/icon.png`) and keep the accent colour green (`#0F6E56`).
7. Build once (Product → Build for the Watch App scheme on a paired simulator pair), then commit `ios/Runner.xcodeproj/project.pbxproj` so CI (`flutter build ios --no-codesign`) compiles the watch targets too.
8. Test: run Runner on an iPhone simulator paired with a watch simulator, set a prayer location on the phone, open the watch app (the payload arrives through the application context) and add the "Next prayer" complication to a face. `flutter build ipa` then ships the watch app inside the iOS build; App Store Connect lists it under the same app, and the App Store page gets watch screenshots (410×502 or 416×496).
9. App Privacy: nothing new is collected. Recitation audio from the watch is processed by Apple's speech recognition on the iPhone, exactly like the phone's own Recite screen, so the existing "Audio data: used for app functionality, not linked to identity" answer still holds.
