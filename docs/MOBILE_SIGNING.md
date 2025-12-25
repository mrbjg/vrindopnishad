# Mobile App Signing Documentation

This document explains how to sign the **Sant-Vaani (Vrindopnishad)** Android app for production/release. Proper signing removes the "Play Protect" warnings and allows you to publish the app.

## 1. Keystore Information
- **File Location:** `/Users/mr.bajrangi/upload-keystore.jks`
- **Alias:** `upload`
- **Validity:** 10,000 days (approx. 27 years)

## 2. Configuration (`key.properties`)
To keep your passwords secure, they are stored in a `key.properties` file inside the `mobile_app/android/` folder. This file is **ignored by Git** to prevent accidental leaks.

### Create the file:
Create a file at `mobile_app/android/key.properties` with the following content:

```properties
storePassword=@Pandit+10
keyPassword=@Pandit+10
keyAlias=upload
storeFile=/Users/mr.bajrangi/upload-keystore.jks
```

## 3. How it Works
The `mobile_app/android/app/build.gradle.kts` is configured to:
1. Look for `key.properties`.
2. If found, it uses your release key to sign the APK.
3. If not found, it falls back to the `debug` key (which causes the Play Protect warning).

## 4. Building the Signed APK
Once you have created the `key.properties` file, run:

```bash
cd mobile_app
flutter clean
flutter build apk --release
```

The output will be at:
`build/app/outputs/flutter-apk/app-release.apk`

## 5. Removing "Play Protect" Warnings
Even with a signed app, Google Play Protect might still show a warning because it hasn't "seen" your app before. To fully clear this:
1. **Submit for Verification:** Go to [Google Play Protect Appeals](https://support.google.com/googleplay/android-developer/contact/protect_appeals).
2. **Provide App Details:** Upload your signed APK and your developer details.
3. **Wait:** Once Google verifies the app is safe, the warning will disappear for everyone.
