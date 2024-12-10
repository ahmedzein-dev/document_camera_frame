# DocumentCameraFrame Widget

The `DocumentCameraFrame` widget is a customizable camera interface for capturing and cropping
document images. It includes a predefined frame for document capture, buttons for user interactions,
and an easy-to-extend design.

---

## Features

- **Document Frame**: Displays a customizable frame for capturing documents.
- **Camera Preview**: Real-time camera feed with support for capturing images.
- **Action Buttons**:
    - Capture: Capture the document image.
    - Save: Save the captured document.
    - Retake: Retake the image if needed.
- **Customizable UI**:
    - Frame dimensions (width/height).
    - Button styles, text, and positions.
    - Optional screen title with alignment and padding.
- **Callbacks**: Trigger events like `onCaptured`, `onSaved`, and `onRetake`.

---

## Usage

### Import the Package

```dart
import 'package:your_project/document_camera_frame.dart';
```

### Example

```dart
import 'package:document_camera_frame/src/ui/page/document_camera_frame.dart';
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

| Parameter                | Type               | Description                                          | Required |
|--------------------------|--------------------|------------------------------------------------------|----------|
| `frameWidth`             | `double`           | Width of the document capture frame.                 | ✅        |
| `frameHeight`            | `double`           | Height of the document capture frame.                | ✅        |
| `screenTitle`            | `Widget?`          | Title widget to display on the screen (optional).    | ❌        |
| `screenTitleAlignment`   | `Alignment?`       | Alignment of the screen title (optional).            | ❌        |
| `screenTitlePadding`     | `EdgeInsets?`      | Padding for the screen title (optional).             | ❌        |
| `captureButtonText`      | `String?`          | Text for the "Capture" button.                       | ❌        |
| `captureButtonTextStyle` | `TextStyle?`       | Text style for the "Capture" button text (optional). | ❌        |
| `onCaptured`             | `Function(String)` | Callback when an image is captured.                  | ❌        |
| `saveButtonText`         | `String?`          | Text for the "Save" button.                          | ❌        |
| `onSaved`                | `Function(String)` | Callback when an image is saved.                     | ❌        |
| `retakeButtonText`       | `String?`          | Text for the "Retake" button.                        | ❌        |
| `onRetake`               | `VoidCallback?`    | Callback when the "Retake" button is pressed.        | ❌        |

---

## Dependencies

This widget depends on the following packages:

- `camera`
- `flutter`

Make sure these packages are included in your `pubspec.yaml`.

---

## License

This project is licensed under the MIT License. See the LICENSE file for details.
