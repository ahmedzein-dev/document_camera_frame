# Document Camera Frame

[![Pub Version](https://img.shields.io/pub/v/document_camera_frame.svg)](https://pub.dev/packages/document_camera_frame)
[![Pub Points](https://img.shields.io/pub/points/document_camera_frame)](https://pub.dev/packages/document_camera_frame/score)
[![Likes](https://img.shields.io/pub/likes/document_camera_frame)](https://pub.dev/packages/document_camera_frame/score)

`DocumentCameraFrame` is a Flutter package for scanning documents using a live camera feed. It provides a customizable frame UI, dual-side capture support (e.g., front/back of ID cards), and easy integration for OCR or document processing workflows.

## Demo

Here’s a quick preview of `DocumentCameraFrame` in action:

<div style="display: flex; gap: 10px;">
  <img src="https://github.com/ahmedzein-dev/document_camera_frame/raw/main/assets/example1.gif?v=2" width="260" alt="example1" />
  <img src="https://github.com/ahmedzein-dev/document_camera_frame/raw/main/assets/example2.gif?v=2" width="260" alt="example2" />
  <img src="https://github.com/ahmedzein-dev/document_camera_frame/raw/main/assets/example3.gif?v=2" width="260" alt="example3" />
</div>

## Features

- 📸 **Live Camera Preview** with adjustable document frame
- ✂️ **Custom Frame Dimensions** for precise cropping
- 🔄 **Dual-Side Capture Support** (e.g., ID front/back)
- 🎛️ **Fully Customizable UI** — titles, padding, button styles
- 🪝 **Easy Event Callbacks** — `onCaptured`, `onRetake`, `onSaved`

## Quick Start
## Installation

Add the package to your Flutter project using:

```bash
flutter pub add document_camera_frame
```

---

## Minimal Example
```dart
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

class QuickExample extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return DocumentCameraFrame(
      frameWidth: 320,
      frameHeight: 200,
      requireBothSides: false,
      onBothSidesSaved: (documentData) {
        print('Document saved: ${documentData.frontImagePath}');
        Navigator.pop(context);
      },
    );
  }
}
```

## Setup Requirements

### iOS Setup

Add the following keys to your `ios/Runner/Info.plist` file to request camera and microphone
permissions:

```xml

<plist version="1.0">
    <dict>
        <!-- Add the following keys inside the <dict> section -->
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

## Common Use Cases

### Driver's License (Both Sides)

```dart
DocumentCameraFrame(
  frameWidth: 320,
  frameHeight: 200,
  frontSideTitle: Text('Scan Front of License', 
    style: TextStyle(color: Colors.white)),
  backSideTitle: Text('Scan Back of License',
    style: TextStyle(color: Colors.white)),
  requireBothSides: true,
  onFrontCaptured: (imagePath) => print('Front: $imagePath'),
  onBackCaptured: (imagePath) => print('Back: $imagePath'),
  onBothSidesSaved: (data) => handleDocument(data),
)
```

### Passport (Single Side)

```dart
DocumentCameraFrame(
  frameWidth: 300,
  frameHeight: 450,
  title: Text('Scan Passport', style: TextStyle(color: Colors.white)),
  requireBothSides: false,
  showSideIndicator: false,
  frontSideInstruction: "Position passport within the frame",
  onBothSidesSaved: (data) => handlePassport(data),
)
```

### ID Card with Custom Styling

```dart
DocumentCameraFrame(
  frameWidth: 320,
  frameHeight: 200,
  requireBothSides: true,
  captureButtonText: "Take Photo",
  saveButtonText: "Done",
  retakeButtonText: "Try Again",
  progressIndicatorColor: Colors.blue,
  outerFrameBorderRadius: 16.0,
  onBothSidesSaved: (data) => processIdCard(data),
)
```

## Widget Parameters

| Parameter                      | Type                            | Description                                                                      | Required    | Default Value                   |
|--------------------------------|---------------------------------|----------------------------------------------------------------------------------|-------------|---------------------------------|
| `frameWidth`                   | `double`                        | Width of the document capture frame.                                             | ✅           | —                               |
| `frameHeight`                  | `double`                        | Height of the document capture frame.                                            | ✅           | —                               |
| `title`                        | `Widget?`                       | Widget to display as the screen's title (optional).                              | ❌           | `null`                          |
| `frontSideTitle`               | `Widget?`                       | Custom title for front side capture.                                             | ❌           | `null`                          |
| `backSideTitle`                | `Widget?`                       | Custom title for back side capture.                                              | ❌           | `null`                          |
| `screenTitleAlignment`         | `Alignment?`                    | Alignment of the screen title (optional).                                        | ❌           | `Alignment.topCenter`           |
| `screenTitlePadding`           | `EdgeInsets?`                   | Padding for the screen title (optional).                                         | ❌           | `EdgeInsets.zero`               |
| `captureButtonText`            | `String?`                       | Text for the "Capture" button.                                                   | ❌           | `"Capture"`                     |
| `captureFrontButtonText`       | `String?`                       | Text for capture button when capturing front side.                               | ❌           | `null`                          |
| `captureBackButtonText`        | `String?`                       | Text for capture button when capturing back side.                                | ❌           | `null`                          |
| `captureButtonTextStyle`       | `TextStyle?`                    | Text style for the "Capture" button text (optional).                             | ❌           | `null`                          |
| `captureInnerCircleRadius`     | `double?`                       | Radius of the inner circle of the capture button (optional).                     | ❌           | `59`                            |
| `captureOuterCircleRadius`     | `double?`                       | Radius of the outer circle of the capture button (optional).                     | ❌           | `70`                            |
| `captureButtonStyle`           | `ButtonStyle?`                  | Style for the "Capture" button (optional).                                       | ❌           | `null`                          |
| `captureButtonAlignment`       | `Alignment?`                    | Alignment of the "Capture" button (optional).                                    | ❌           | `Alignment.bottomCenter`        |
| `captureButtonPadding`         | `EdgeInsets?`                   | Padding for the "Capture" button (optional).                                     | ❌           | `null`                          |
| `captureButtonWidth`           | `double?`                       | Width for the "Capture" button (optional).                                       | ❌           | `null`                          |
| `captureButtonHeight`          | `double?`                       | Height for the "Capture" button (optional).                                      | ❌           | `null`                          |
| `onFrontCaptured`              | `Function(String)`?             | Callback triggered when front side is captured.                                  | ❌           | `null`                          |
| `onBackCaptured`               | `Function(String)`?             | Callback triggered when back side is captured.                                   | ❌           | `null`                          |
| `onBothSidesSaved`             | `Function(DocumentCaptureData)` | Callback triggered when both sides are captured and saved.                       | ✅           | —                               |
| `saveButtonText`               | `String?`                       | Text for the "Save" button.                                                      | ❌           | `"Save"`                        |
| `nextButtonText`               | `String?`                       | Text for "Next" button (when moving from front to back).                         | ❌           | `null`                          |
| `previousButtonText`           | `String?`                       | Text for "Previous" button (when going back to front from back).                 | ❌           | `null`                          |
| `saveButtonTextStyle`          | `TextStyle?`                    | Text style for the "Save" button text (optional).                                | ❌           | `null`                          |
| `saveButtonStyle`              | `ButtonStyle?`                  | Style for the "Save" button (optional).                                          | ❌           | `null`                          |
| `saveButtonAlignment`          | `Alignment?`                    | Alignment of the "Save" button (optional).                                       | ❌           | `Alignment.bottomRight`         |
| `saveButtonPadding`            | `EdgeInsets?`                   | Padding for the "Save" button (optional).                                        | ❌           | `null`                          |
| `saveButtonWidth`              | `double?`                       | Width for the "Save" button (optional).                                          | ❌           | `null`                          |
| `saveButtonHeight`             | `double?`                       | Height for the "Save" button (optional).                                         | ❌           | `null`                          |
| `actionButtonStyle`            | `ButtonStyle?`                  | Style for action buttons (optional).                                             | ❌           | `null`                          |
| `actionButtonAlignment`        | `Alignment?`                    | Alignment of action buttons (optional).                                          | ❌           | `null`                          |
| `actionButtonPadding`          | `EdgeInsets?`                   | Padding for action buttons (optional).                                           | ❌           | `null`                          |
| `actionButtonWidth`            | `double?`                       | Width for action buttons (optional).                                             | ❌           | `null`                          |
| `actionButtonHeight`           | `double?`                       | Height for action buttons (optional).                                            | ❌           | `null`                          |
| `actionButtonTextStyle`        | `TextStyle?`                    | Text style for action buttons (optional).                                        | ❌           | `null`                          |
| `retakeButtonText`             | `String?`                       | Text for the "Retake" button.                                                    | ❌           | `"Retake"`                      |
| `retakeButtonTextStyle`        | `TextStyle?`                    | Text style for the "Retake" button text (optional).                              | ❌           | `null`                          |
| `retakeButtonStyle`            | `ButtonStyle?`                  | Style for the "Retake" button (optional).                                        | ❌           | `null`                          |
| `retakeButtonAlignment`        | `Alignment?`                    | Alignment of the "Retake" button (optional).                                     | ❌           | `Alignment.bottomLeft`          |
| `retakeButtonPadding`          | `EdgeInsets?`                   | Padding for the "Retake" button (optional).                                      | ❌           | `null`                          |
| `retakeButtonWidth`            | `double?`                       | Width for the "Retake" button (optional).                                        | ❌           | `null`                          |
| `retakeButtonHeight`           | `double?`                       | Height for the "Retake" button (optional).                                       | ❌           | `null`                          |
| `onRetake`                     | `VoidCallback?`                 | Callback triggered when the "Retake" button is pressed.                          | ❌           | `null`                          |
| `frameBorder`                  | `BoxBorder?`                    | Border for the displayed frame (optional).                                       | ❌           | `null`                          |
| `capturingAnimationDuration`   | `Duration?`                     | Duration for the capturing animation (optional).                                 | ❌           | `Duration(milliseconds: 1000)`  |
| `capturingAnimationColor`      | `Color?`                        | Color for the capturing animation (optional).                                    | ❌           | `Colors.black26`                |
| `capturingAnimationCurve`      | `Curve?`                        | Curve for the capturing animation (optional).                                    | ❌           | `Curves.easeInOut`              |
| `outerFrameBorderRadius`       | `double`                        | Radius of the outer border of the frame.                                         | ❌           | `12.0`                          |
| `innerCornerBroderRadius`      | `double`                        | Radius of the inner corners of the frame.                                        | ❌           | `8.0`                           |
| `animatedFrameDuration`        | `Duration`                      | Duration for the frame animation (optional).                                     | ❌           | `Duration(milliseconds: 600)`   |
| `flipAnimationDuration`        | `Duration`                      | Duration for the flip animation between sides.                                   | ❌           | `Duration(milliseconds: 1200)`  |
| `flipAnimationCurve`           | `Curve`                         | Curve for the flip animation between sides.                                      | ❌           | `Curves.easeInOut`              |
| `animatedFrameCurve`           | `Curve`                         | Curve for the frame animation (optional).                                        | ❌           | `Curves.easeInOut`              |
| `bottomFrameContainerChild`    | `Widget?`                       | Custom content for the bottom container (optional).                              | ❌           | `null`                          |
| `showCloseButton`              | `bool`                          | Flag to control the visibility of the CloseButton (optional).                    | ❌           | `false`                         |
| `cameraIndex`                  | `int?`                          | Index to specify which camera to use (e.g., 0 for back, 1 for front) (optional). | ❌           | `0` (back)                      |
| `requireBothSides`             | `bool`                          | Whether to require both sides (if false, can save with just front side).         | ❌           | `true`                          |
| `progressIndicatorColor`       | `Color?`                        | Color for the progress indicator (optional).                                     | ❌           | `Theme.primaryColor`            |
| `progressIndicatorHeight`      | `double`                        | Height of the progress indicator.                                                | ❌           | `4.0`                           |
| `frontSideInstruction`         | `String?`                       | Instruction text for front side capture.                                         | ❌           | Default instruction text        |
| `backSideInstruction`          | `String?`                       | Instruction text for back side capture.                                          | ❌           | Default instruction text        |
| `instructionTextStyle`         | `TextStyle?`                    | Text style for instruction text (optional).                                      | ❌           | Default style                   |
| `bottomHintText`               | `String?`                       | Optional bottom hint text shown in the bottom container.                         | ❌           | `null`                          |
| `sideInfoOverlay`              | `Widget?`                       | Optional widget shown on the right (e.g. a check icon).                          | ❌           | `null`                          |
| `showSideIndicator`            | `bool`                          | Show the side indicator (optional).                                              | ❌           | `true`                          |
| `sideIndicatorBackgroundColor` | `Color?`                        | Background color for side indicator.                                             | ❌           | `Colors.black.withOpacity(0.8)` |
| `sideIndicatorBorderColor`     | `Color?`                        | Border color for side indicator.                                                 | ❌           | `null`                          |
| `sideIndicatorActiveColor`     | `Color?`                        | Active color for side indicator.                                                 | ❌           | `Colors.blue`                   |
| `sideIndicatorInactiveColor`   | `Color?`                        | Inactive color for side indicator.                                               | ❌           | `Colors.grey`                   |
| `sideIndicatorCompletedColor`  | `Color?`                        | Completed color for side indicator.                                              | ❌           | `Colors.green`                  |
| `sideIndicatorTextStyle`       | `TextStyle?`                    | Text style for side indicator text.                                              | ❌           | `null`                          |

---

## 🔧 Troubleshooting

### Common Issues

**Camera not initializing:**
- ✅ Check camera permissions in device settings
- ✅ Ensure `minSdkVersion` is at least **21** (Android)
- ✅ Verify camera permissions in **Info.plist** (iOS)

**Build errors:**
- 💡 Run `flutter clean && flutter pub get`
- 💡 Confirm all platform-specific setup is complete

**Permission denied errors:**
- ⚠️ Handle permission errors gracefully in your app UI
- ⚠️ Guide users to enable permissions in device settings

---

### ⚙️ Performance Tips

- 📱 The package automatically manages camera resources
- 🗂️ Images are saved to the **temporary directory** by default
- 🚫 Consider implementing proper **error handling** for production apps

---

## 📌 Full Example

For a comprehensive example with multiple document types, see  
[`example/main.dart`](https://github.com/ahmedzein-dev/document_camera_frame/blob/main/example/lib/main.dart).

## Contributing

Contributions are welcome! If you find a bug or have a feature request, please open an issue or submit a pull request.

## 🙌 Support

- 🐛 **Bug reports:** Please open issues on [GitHub Issues](https://github.com/ahmedzein-dev/document_camera_frame/issues)
- 💡 **Feature requests:** Share your ideas on [GitHub Discussions](https://github.com/ahmedzein-dev/document_camera_frame/discussions)
- ⭐ **Enjoying this package?** Please give it a star on [GitHub](https://github.com/ahmedzein-dev/document_camera_frame) or like it on [pub.dev](https://pub.dev/packages/document_camera_frame)

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
