# Document Camera Frame

The `DocumentCameraFrame` package simplifies document scanning by providing a customizable camera
interface for capturing and cropping document images. It’s ideal for applications that require
efficient and user-friendly document capture.

## Screenshot

<img src="https://github.com/AhmedZein1996/document_camera_frame/raw/main/screenshots/two_sided_ui.jpg" width="400" height="868" alt="Two-Sided Document Capture UI" />

![example.gif](https://github.com/AhmedZein1996/document_camera_frame/raw/main/example.gif)

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

## Usage

### Import the Package

```dart
import 'package:document_camera_frame/document_camera_frame.dart';
```

### Example

```dart
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      debugShowCheckedModeBanner: false,
      home: const HomeScreen(),
    );
  }
}

class HomeScreen extends StatelessWidget {
  const HomeScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: DocumentTypeSelectionScreen(),
    );
  }
}

/// Example for different document types
class DocumentTypeSelectionScreen extends StatelessWidget {
  const DocumentTypeSelectionScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: const Text('Select Document Type'),
      ),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          children: [
            _buildDocumentTypeCard(
              context,
              'Driver\'s License',
              'Capture both front and back sides',
              Icons.credit_card,
                      () => _navigateToCamera(context, DocumentType.driverLicense),
            ),
            const SizedBox(height: 16),
            _buildDocumentTypeCard(
              context,
              'Passport',
              'Capture the main page only',
              Icons.book,
                      () => _navigateToCamera(context, DocumentType.passport),
            ),
            const SizedBox(height: 16),
            _buildDocumentTypeCard(
              context,
              'ID Card',
              'Capture both sides',
              Icons.badge,
                      () => _navigateToCamera(context, DocumentType.idCard),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildDocumentTypeCard(
          BuildContext context,
          String title,
          String subtitle,
          IconData icon,
          VoidCallback onTap,
          ) {
    return Card(
      child: ListTile(
        leading: Icon(icon, size: 40, color: Theme.of(context).primaryColor),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: onTap,
      ),
    );
  }

  void _navigateToCamera(BuildContext context, DocumentType documentType) {
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (context) =>
                _buildCameraForDocumentType(context, documentType),
      ),
    );
  }

  Widget _buildCameraForDocumentType(
          BuildContext context, DocumentType documentType) {
    switch (documentType) {
      case DocumentType.driverLicense:
        return DocumentCameraFrame(
          frameWidth: 320,
          frameHeight: 200,
          frontSideTitle: const Text('Scan Front of License',
                  style: TextStyle(color: Colors.white)),
          backSideTitle: const Text('Scan Back of License',
                  style: TextStyle(color: Colors.white)),
          requireBothSides: true,
          // Callbacks
          onFrontCaptured: (imagePath) {
            debugPrint('Front side captured: $imagePath');
            // You can perform additional actions here
            // such as uploading to server, saving locally, etc.
          },

          onBackCaptured: (imagePath) {
            debugPrint('Back side captured: $imagePath');
            // You can perform additional actions here
          },

          onBothSidesSaved: (documentData) {
            debugPrint('Document capture completed!');
            debugPrint('Front: ${documentData.frontImagePath}');
            debugPrint('Back: ${documentData.backImagePath}');
            debugPrint('Is complete: ${documentData.isComplete}');

            // Navigate to next screen or process the captured document
            _handleDocumentSaved(context, documentData);
          },
        );

      case DocumentType.passport:
        return DocumentCameraFrame(
          frameWidth: 300,
          frameHeight: 450,
          actionButtonHeight: 40,
          title: const Text('Scan Passport',
                  style: TextStyle(color: Colors.white)),
          requireBothSides: false,
          showSideIndicator: false,
          frontSideInstruction:
          "Position the main page of your passport within the frame",
          onBothSidesSaved: (data) {
            debugPrint('Passport captured');
            Navigator.of(context).pop();
          },
        );

      case DocumentType.idCard:
        return DocumentCameraFrame(
          frameWidth: 320,
          frameHeight: 200,
          frontSideTitle: const Text('Scan Front of ID',
                  style: TextStyle(color: Colors.white)),
          backSideTitle: const Text('Scan Back of ID',
                  style: TextStyle(color: Colors.white)),
          requireBothSides: true,
          showSideIndicator: false,
          onBothSidesSaved: (documentData) {
            // Handle the saved document
            _processDocument(context, documentData);
            Navigator.of(context).pop();
          },
        );
    }
  }

  void _handleDocumentSaved(
          BuildContext context, DocumentCaptureData documentData) {
    // Show success dialog
    showDialog(
      context: context,
      builder: (context) => AlertDialog(
        title: const Text('Document Captured Successfully'),
        content: Column(
          mainAxisSize: MainAxisSize.min,
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text('Your document has been captured successfully.'),
            const SizedBox(height: 10),
            Text(
                    'Front side: ${documentData.frontImagePath != null ? "✓" : "✗"}'),
            Text(
                    'Back side: ${documentData.backImagePath != null ? "✓" : "✗"}'),
          ],
        ),
        actions: [
          TextButton(
            onPressed: () {
              Navigator.of(context).pop(); // Close dialog
              Navigator.of(context).pop(); // Go back to previous screen
            },
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }

  static void _processDocument(
          BuildContext context, DocumentCaptureData documentData) {
    // Process the captured document data
    final hasBackSide = documentData.backImagePath != null;

    ScaffoldMessenger.of(context).showSnackBar(
      SnackBar(
        content: Text(
          hasBackSide
                  ? 'Document captured with both sides!'
                  : 'Document captured (front side only)',
        ),
        backgroundColor: Colors.green,
      ),
    );
  }
}

enum DocumentType {
  driverLicense,
  passport,
  idCard,
}

```

---

## Widget Parameters
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

## License

This project is licensed under the MIT License. See the [LICENSE](./LICENSE) file for details.
