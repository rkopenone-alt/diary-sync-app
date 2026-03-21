# Diary Sync - Personal Assistant

## Prerequisites
To compile and run this application:
1. Install **Flutter SDK** (https://flutter.dev/docs/get-started/install/windows).
2. Ensure you have the Android toolchain installed (for Android `.apk` builds) and Visual Studio installed with "Desktop development with C++" workload (for Windows `.exe` builds).

## How to build after creating
Since this project was generated manually, the native Android and Windows folders are missing. To generate them, open a terminal in this directory and run:

```bash
flutter create .
flutter pub get
```

## To run the app
- **Android**: Connect an Android device or start an emulator, then run `flutter run -d android`
- **Windows**: Run `flutter run -d windows`

## To build release artifacts
- **Android APK**: `flutter build apk --release` (outputs to `build/app/outputs/flutter-apk/app-release.apk`)
- **Windows EXE**: `flutter build windows --release` (outputs to `build/windows/runner/Release/`)
