# DocumentCameraFrame Widget

The `DocumentCameraFrame` package simplifies document scanning by providing a customizable camera
interface for capturing and cropping document images. It’s ideal for applications that require
efficient and user-friendly document capture.

---

## Features

- **Document Frame**: Customizable dimensions for focused document capture.
- **Camera Preview**: Real-time camera feed for instant feedback.
- **User-Friendly Controls**:
    - **Capture**: Take a snapshot of the document.
    - **Save**: Save the captured image.
    - **Retake**: Retake the image if unsatisfactory.
- **Customizable UI**:
    - Define frame dimensions, button styles, and positions.
    - Add optional titles with alignment and padding options.
- **Event Callbacks**: Handle events like `onCaptured`, `onSaved`, and `onRetake` easily.

---

## Installation

Add the package to your Flutter project using:

```bash
flutter pub add document_camera_frame
```

Then run:

```bash
flutter pub get
```

---

## Setup

### iOS Setup

Add the following keys to your `ios/Runner/Info.plist` file to request camera and microphone
permissions:

```xml

<plist version="1.0">
    <dict>
        <key>NSCameraUsageDescription</key>
        <string>We need camera access to capture documents.</string>
        <key>NSMicrophoneUsageDescription</key>
        <string>We need microphone access for audio-related features.</string>
    </dict>
</plist>
```

### Android Setup

1. Update the `minSdkVersion` to 21 or higher in `android/app/build.gradle`:

```gradle
android {
    defaultConfig {
        minSdk 21
    }
}
```

2. Add these permissions to your `AndroidManifest.xml` file:

```xml

<manifest xmlns:android="http://schemas.android.com/apk/res/android">

    <uses-permission android:name="android.permission.WRITE_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.READ_EXTERNAL_STORAGE" />
    <uses-permission android:name="android.permission.CAMERA" />
    <uses-feature android:name="android.hardware.camera" />
    <uses-feature android:name="android.hardware.camera.autofocus" />

    <application android:label="MyApp" android:name="${applicationName}"
        android:icon="@mipmap/ic_launcher">
        <!-- Activities and other components -->
    </application>

</manifest>
```

---

## Handling Camera Access Permissions

Permission errors may occur when initializing the camera. You must handle them appropriately. Below
are the possible error codes:

| **Error Code**                    | **Description**                                                                                  |
|-----------------------------------|--------------------------------------------------------------------------------------------------|
| `CameraAccessDenied`              | User denied camera access permission.                                                            |
| `CameraAccessDeniedWithoutPrompt` | iOS only. User previously denied access and needs to enable it manually via Settings.            |
| `CameraAccessRestricted`          | iOS only. Camera access is restricted (e.g., parental controls).                                 |
| `AudioAccessDenied`               | User denied microphone access permission.                                                        |
| `AudioAccessDeniedWithoutPrompt`  | iOS only. User previously denied microphone access and needs to enable it manually via Settings. |
| `AudioAccessRestricted`           | iOS only. Microphone access is restricted (e.g., parental controls).                             |

---

## Usage

### Import the Package

```dart
import 'package:document_camera_frame/document_camera_frame.dart';
```

### Example

```dart
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: Scaffold(
        body: Builder(
          builder: (context) =>
              DocumentCameraView(
                frameWidth: 300.0,
                frameHeight: 400.0,
                captureButtonTextStyle: const TextStyle(fontSize: 24),
                captureButtonStyle: ElevatedButton.styleFrom(
                  backgroundColor: Colors.white,
                  foregroundColor: Colors.black,
                  padding: const EdgeInsets.symmetric(horizontal: 40, vertical: 10),
                ),
                screenTitle: const Text(
                  'Capture Your Document',
                  style: TextStyle(color: Colors.white, fontSize: 20),
                ),
                captureButtonText: 'Snap',
                saveButtonText: 'Keep',
                retakeButtonText: 'Retry',
                onCaptured: (imgPath) {
                  print('Captured image path: $imgPath');
                },
                onSaved: (imgPath) {
                  print('Saved image path: $imgPath');
                },
                onRetake: () {
                  print('Retake button pressed');
                },
              ),
        ),
      ),
    );
  }
}
```

---

## Widget Parameters

| Parameter                | Type               | Description                                          | Required | Default Value         |
|--------------------------|--------------------|------------------------------------------------------|----------|-----------------------|
| `frameWidth`             | `double`           | Width of the document capture frame.                 | ✅        | —                     |
| `frameHeight`            | `double`           | Height of the document capture frame.                | ✅        | —                     |
| `screenTitle`            | `Widget?`          | Title widget to display on the screen (optional).    | ❌        | `null`                |
| `screenTitleAlignment`   | `Alignment?`       | Alignment of the screen title (optional).            | ❌        | `Alignment.topCenter` |
| `screenTitlePadding`     | `EdgeInsets?`      | Padding for the screen title (optional).             | ❌        | `EdgeInsets.zero`     |
| `captureButtonText`      | `String?`          | Text for the "Capture" button.                       | ❌        | `"Capture"`           |
| `captureButtonTextStyle` | `TextStyle?`       | Text style for the "Capture" button text (optional). | ❌        | `null`                |
| `captureButtonStyle`     | `ButtonStyle?`     | Style for the "Capture" button (optional).           | ❌        | `null`                |
| `captureButtonAlignment` | `Alignment?`       | Alignment of the "Capture" button (optional).        | ❌        | `null`                |
| `captureButtonPadding`   | `EdgeInsets?`      | Padding for the "Capture" button (optional).         | ❌        | `null`                |
| `onCaptured`             | `Function(String)` | Callback when an image is captured.                  | ✅        | —                     |
| `saveButtonText`         | `String?`          | Text for the "Save" button.                          | ❌        | `"Save"`              |
| `saveButtonTextStyle`    | `TextStyle?`       | Text style for the "Save" button text (optional).    | ❌        | `null`                |
| `saveButtonStyle`        | `ButtonStyle?`     | Style for the "Save" button (optional).              | ❌        | `null`                |
| `saveButtonAlignment`    | `Alignment?`       | Alignment of the "Save" button (optional).           | ❌        | `null`                |
| `saveButtonPadding`      | `EdgeInsets?`      | Padding for the "Save" button (optional).            | ❌        | `null`                |
| `onSaved`                | `Function(String)` | Callback when an image is saved.                     | ✅        | —                     |
| `retakeButtonText`       | `String?`          | Text for the "Retake" button.                        | ❌        | `"Retake"`            |
| `retakeButtonTextStyle`  | `TextStyle?`       | Text style for the "Retake" button text (optional).  | ❌        | `null`                |
| `retakeButtonStyle`      | `ButtonStyle?`     | Style for the "Retake" button (optional).            | ❌        | `null`                |
| `retakeButtonAlignment`  | `Alignment?`       | Alignment of the "Retake" button (optional).         | ❌        | `null`                |
| `retakeButtonPadding`    | `EdgeInsets?`      | Padding for the "Retake" button (optional).          | ❌        | `null`                |
| `onRetake`               | `VoidCallback?`    | Callback when the "Retake" button is pressed.        | ❌        | `null`                |
| `imageBorder`            | `BoxBorder?`       | Border for the captured image preview (optional).    | ❌        | `null`                |
| `animationDuration`      | `Duration?`        | Duration for any animations (optional).              | ❌        | `null`                |
| `animationColor`         | `Color?`           | Color for animation effects (optional).              | ❌        | `null`                |

---

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
