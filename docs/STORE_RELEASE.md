# Releasing Mushaf+ to Google Play and the App Store

What is already in the repository, and what only the account owner can do.

## Already in place

- Display name **Mushaf+** on every platform; bundle ids `com.salimjemai.quran_plus` (Android) and `com.salimjemai.quranPlus` (iOS/macOS). Keep these: changing them later creates a new app on the stores.
- Launcher icons and splash screens (`flutter_launcher_icons`, `flutter_native_splash`, source `tool/render_icon.dart`).
- Permission texts: microphone, speech recognition and location (`ios/Runner/Info.plist`, `android/app/src/main/AndroidManifest.xml`).
- iOS privacy manifest `ios/Runner/PrivacyInfo.xcprivacy` (no tracking, no collected data, required-reason APIs declared). **Add it to the Runner target once in Xcode** (File → Add Files to "Runner", tick the Runner target) so it ships in the bundle.
- Privacy policy page: https://salimjemai.github.io/QuranPlus/privacy.html (source `web/privacy.html`), linked from Settings → About. Both stores require this URL.
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

## Before each release

- `flutter analyze` and `flutter test` green; CI green.
- Bump `version:` in `pubspec.yaml`.
- Smoke test on a phone: audio, recitation (microphone prompt), Qibla (motion prompt), masjid lookup, downloads.
- Update `web/privacy.html` if a new service is contacted.
