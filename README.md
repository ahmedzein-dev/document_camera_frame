# Document Camera Frame

[![Pub Version](https://img.shields.io/pub/v/document_camera_frame.svg)](https://pub.dev/packages/document_camera_frame)
[![Pub Points](https://img.shields.io/pub/points/document_camera_frame)](https://pub.dev/packages/document_camera_frame/score)
[![Likes](https://img.shields.io/pub/likes/document_camera_frame)](https://pub.dev/packages/document_camera_frame/score)

`DocumentCameraFrame` is a Flutter package for scanning documents using a live camera feed. It provides a customizable frame UI, dual-side capture support (e.g., front/back of ID cards), automatic document detection, and easy integration for OCR or document processing workflows.

## Demo

Here’s a quick preview of `DocumentCameraFrame` in action:

<div style="display: flex; gap: 10px; flex-wrap: wrap; justify-content: center;">
  <figure style="display: flex; flex-direction: column; align-items: center; margin: 0;">
    <img src="https://github.com/ahmedzein-dev/document_camera_frame/raw/main/assets/example_auto_detect.gif" width="350" alt="Auto Detection Example" />
    <figcaption>Auto document edge detection in real-time</figcaption>
  </figure>

  <figure style="display: flex; flex-direction: column; align-items: center; margin: 0;">
    <img src="https://github.com/ahmedzein-dev/document_camera_frame/raw/main/assets/example1.gif?v=2" width="350" alt="example1" />
    <figcaption>Manual frame adjustment example</figcaption>
  </figure>

  <figure style="display: flex; flex-direction: column; align-items: center; margin: 0;">
    <img src="https://github.com/ahmedzein-dev/document_camera_frame/raw/main/assets/example2.gif?v=2" width="350" alt="example2" />
    <figcaption>Frame capture animation in action</figcaption>
  </figure>

  <figure style="display: flex; flex-direction: column; align-items: center; margin: 0;">
    <img src="https://github.com/ahmedzein-dev/document_camera_frame/raw/main/assets/example3.gif?v=2" width="350" alt="example3" />
    <figcaption>Document cropping and perspective correction</figcaption>
  </figure>
</div>


## Features

- 📸 **Live Camera Preview** with adjustable document frame
- ✂️ **Custom Frame Dimensions** for precise cropping
- 🔎 **Automatic Document Detection**
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
      enableAutoCapture: true, // Enable automatic capture
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

1. Set the minimum iOS deployment target to 15.5 or higher in your `ios/Podfile`:

```ruby
platform :ios, '15.5'  # or newer version
```

2. Add the following keys to your `ios/Runner/Info.plist` file to request camera and microphone
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
  enableAutoCapture: true, // Automatically capture when document is aligned
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
  enableAutoCapture: false, // Manual capture only
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
  enableAutoCapture: true,
  captureButtonText: "Take Photo",
  saveButtonText: "Done",
  retakeButtonText: "Try Again",
  progressIndicatorColor: Colors.blue,
  outerFrameBorderRadius: 16.0,
  onBothSidesSaved: (data) => processIdCard(data),
)
```

## Widget Parameters

### Core Parameters

| Parameter                   | Type      | Description                                                                      | Required | Default Value |
|-----------------------------|-----------|----------------------------------------------------------------------------------|----------|---------------|
| `frameWidth`                | `double`  | Width of the document capture frame.                                             | ✅        | —             |
| `frameHeight`               | `double`  | Height of the document capture frame.                                            | ✅        | —             |
| `enableAutoCapture`         | `bool`    | Enables automatic capture when a document is properly aligned in the frame.      | ❌        | `false`       |
| `requireBothSides`          | `bool`    | Whether to require both sides (if false, can save with just front side).         | ❌        | `true`        |
| `showCloseButton`           | `bool`    | Flag to control the visibility of the CloseButton (optional).                    | ❌        | `false`       |
| `cameraIndex`               | `int?`    | Index to specify which camera to use (e.g., 0 for back, 1 for front) (optional). | ❌        | `0` (back)    |
| `bottomFrameContainerChild` | `Widget?` | Custom content for the bottom container (optional).                              | ❌        | `null`        |
| `bottomHintText`            | `String?` | Optional bottom hint text shown in the bottom container.                         | ❌        | `null`        |
| `sideInfoOverlay`           | `Widget?` | Optional widget shown on the right (e.g. a check icon).                          | ❌        | `null`        |

### Styling Classes

| Parameter            | Type                               | Description                                             | Required | Default Value                        |
|----------------------|------------------------------------|---------------------------------------------------------|----------|--------------------------------------|
| `animationStyle`     | `DocumentCameraAnimationStyle`     | Animation styling configuration for the camera widget.  | ❌        | `DocumentCameraAnimationStyle()`     |
| `frameStyle`         | `DocumentCameraFrameStyle`         | Frame styling configuration for borders and appearance. | ❌        | `DocumentCameraFrameStyle()`         |
| `buttonStyle`        | `DocumentCameraButtonStyle`        | Button styling configuration for all buttons.           | ❌        | `DocumentCameraButtonStyle()`        |
| `titleStyle`         | `DocumentCameraTitleStyle`         | Title styling configuration for screen titles.          | ❌        | `DocumentCameraTitleStyle()`         |
| `sideIndicatorStyle` | `DocumentCameraSideIndicatorStyle` | Side indicator styling configuration.                   | ❌        | `DocumentCameraSideIndicatorStyle()` |
| `progressStyle`      | `DocumentCameraProgressStyle`      | Progress indicator styling configuration.               | ❌        | `DocumentCameraProgressStyle()`      |
| `instructionStyle`   | `DocumentCameraInstructionStyle`   | Instruction text styling configuration.                 | ❌        | `DocumentCameraInstructionStyle()`   |

### Callbacks

| Parameter          | Type                            | Description                                                                                                  | Required | Default Value |
|--------------------|---------------------------------|--------------------------------------------------------------------------------------------------------------|----------|---------------|
| `onFrontCaptured`  | `Function(String)?`             | Callback triggered when front side is captured.                                                              | ❌        | `null`        |
| `onBackCaptured`   | `Function(String)?`             | Callback triggered when back side is captured.                                                               | ❌        | `null`        |
| `onBothSidesSaved` | `Function(DocumentCaptureData)` | Callback triggered when both sides are captured and saved.                                                   | ✅        | —             |
| `onRetake`         | `VoidCallback?`                 | Callback triggered when the "Retake" button is pressed.                                                      | ❌        | `null`        |
| `onCameraError`    | `void Function(Object error)?`  | Callback triggered when a camera-related error occurs (e.g., initialization, streaming, or capture failure). | ❌        | `null`        |

## Styling Classes Details

### DocumentCameraAnimationStyle

| Property                     | Type        | Description                                          | Default Value                     |
|------------------------------|-------------|------------------------------------------------------|-----------------------------------|
| `capturingAnimationDuration` | `Duration?` | Duration for the capturing animation (optional).     | `null`                            |
| `capturingAnimationColor`    | `Color?`    | Color for the capturing animation (optional).        | `null`                            |
| `capturingAnimationCurve`    | `Curve?`    | Curve for the capturing animation (optional).        | `null`                            |
| `frameFlipDuration`          | `Duration`  | Duration for the flip animation between sides.       | `Duration(milliseconds: 1200)`    |
| `frameFlipCurve`             | `Curve`     | Curve for the flip animation between sides.          | `Curves.easeInOut`                |

### DocumentCameraFrameStyle

| Property                       | Type         | Description                                           | Default Value                    |
|--------------------------------|--------------|-------------------------------------------------------|----------------------------------|
| `outerFrameBorderRadius`       | `double`     | Radius of the outer border of the frame.              | `12.0`                           |
| `innerCornerBroderRadius`      | `double`     | Radius of the inner corners of the frame.             | `8.0`                            |
| `frameBorder`                  | `BoxBorder?` | Border for the displayed frame (optional).            | `null`                           |

### DocumentCameraButtonStyle

| Property                   | Type           | Description                                              | Default Value |
|----------------------------|----------------|----------------------------------------------------------|---------------|
| `captureOuterCircleRadius` | `double?`      | Radius of the outer circle of the capture button.        | `null`        |
| `captureInnerCircleRadius` | `double?`      | Radius of the inner circle of the capture button.        | `null`        |
| `captureButtonText`        | `String?`      | Text for the "Capture" button.                           | `null`        |
| `captureFrontButtonText`   | `String?`      | Text for capture button when capturing front side.       | `null`        |
| `captureBackButtonText`    | `String?`      | Text for capture button when capturing back side.        | `null`        |
| `saveButtonText`           | `String?`      | Text for the "Save" button.                              | `null`        |
| `nextButtonText`           | `String?`      | Text for "Next" button (when moving from front to back). | `null`        |
| `previousButtonText`       | `String?`      | Text for "Previous" button (when going back to front).   | `null`        |
| `retakeButtonText`         | `String?`      | Text for the "Retake" button.                            | `null`        |
| `captureButtonStyle`       | `ButtonStyle?` | Style for the "Capture" button (optional).               | `null`        |
| `actionButtonStyle`        | `ButtonStyle?` | Style for action buttons (optional).                     | `null`        |
| `retakeButtonStyle`        | `ButtonStyle?` | Style for the "Retake" button (optional).                | `null`        |
| `captureButtonAlignment`   | `Alignment?`   | Alignment of the "Capture" button (optional).            | `null`        |
| `captureButtonPadding`     | `EdgeInsets?`  | Padding for the "Capture" button (optional).             | `null`        |
| `captureButtonWidth`       | `double?`      | Width for the "Capture" button (optional).               | `null`        |
| `captureButtonHeight`      | `double?`      | Height for the "Capture" button (optional).              | `null`        |
| `actionButtonAlignment`    | `Alignment?`   | Alignment of action buttons (optional).                  | `null`        |
| `actionButtonPadding`      | `EdgeInsets?`  | Padding for action buttons (optional).                   | `null`        |
| `actionButtonWidth`        | `double?`      | Width for action buttons (optional).                     | `null`        |
| `actionButtonHeight`       | `double?`      | Height for action buttons (optional).                    | `null`        |
| `captureButtonTextStyle`   | `TextStyle?`   | Text style for the "Capture" button text (optional).     | `null`        |
| `actionButtonTextStyle`    | `TextStyle?`   | Text style for action buttons (optional).                | `null`        |
| `retakeButtonTextStyle`    | `TextStyle?`   | Text style for the "Retake" button text (optional).      | `null`        |

### DocumentCameraTitleStyle

| Property                       | Type          | Description                                           | Default Value                    |
|--------------------------------|---------------|-------------------------------------------------------|----------------------------------|
| `title`                        | `Widget?`     | Widget to display as the screen's title (optional).   | `null`                           |
| `frontSideTitle`               | `Widget?`     | Custom title for front side capture.                  | `null`                           |
| `backSideTitle`                | `Widget?`     | Custom title for back side capture.                   | `null`                           |
| `screenTitleAlignment`         | `Alignment?`  | Alignment of the screen title (optional).             | `null`                           |
| `screenTitlePadding`           | `EdgeInsets?` | Padding for the screen title (optional).              | `null`                           |

### DocumentCameraSideIndicatorStyle

| Property                       | Type         | Description                                           | Default Value                    |
|--------------------------------|--------------|-------------------------------------------------------|----------------------------------|
| `showSideIndicator`            | `bool`       | Show the side indicator (optional).                   | `true`                           |
| `sideIndicatorBackgroundColor` | `Color?`     | Background color for side indicator.                  | `null`                           |
| `sideIndicatorBorderColor`     | `Color?`     | Border color for side indicator.                      | `null`                           |
| `sideIndicatorActiveColor`     | `Color?`     | Active color for side indicator.                      | `null`                           |
| `sideIndicatorInactiveColor`   | `Color?`     | Inactive color for side indicator.                    | `null`                           |
| `sideIndicatorCompletedColor`  | `Color?`     | Completed color for side indicator.                   | `null`                           |
| `sideIndicatorTextStyle`       | `TextStyle?` | Text style for side indicator text.                   | `null`                           |

### DocumentCameraProgressStyle

| Property                       | Type     | Description                                           | Default Value                    |
|--------------------------------|----------|-------------------------------------------------------|----------------------------------|
| `progressIndicatorColor`       | `Color?` | Color for the progress indicator (optional).          | `null`                           |
| `progressIndicatorHeight`      | `double` | Height of the progress indicator.                     | `4.0`                            |

### DocumentCameraInstructionStyle

| Property                       | Type         | Description                                           | Default Value                    |
|--------------------------------|--------------|-------------------------------------------------------|----------------------------------|
| `frontSideInstruction`         | `String?`    | Instruction text for front side capture.              | `null`                           |
| `backSideInstruction`          | `String?`    | Instruction text for back side capture.               | `null`                           |
| `instructionTextStyle`         | `TextStyle?` | Text style for instruction text (optional).           | `null`                           |

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
- 💡 Ensure minimum iOS deployment target is 15.5 or higher in your ios/Podfile

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
