import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

import 'core/result_screen.dart';
import 'core/selection_screen.dart';
import 'core/export_format_example.dart';

void main() => runApp(const ExampleApp());

class ExampleApp extends StatelessWidget {
  const ExampleApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MaterialApp(
      title: 'Document Camera Example',
      debugShowCheckedModeBanner: false,
      theme: ThemeData(
        useMaterial3: true,
        colorScheme: ColorScheme.fromSeed(
          seedColor: const Color(0xFF2563EB),
          brightness: Brightness.light,
        ),
      ),
      home: const QuickStartScreen(),
    );
  }
}

/// A "Quick Start" screen showing the simplest way to use the package.
class QuickStartScreen extends StatelessWidget {
  const QuickStartScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(title: const Text('Quick Start')),
      body: Center(
        child: Padding(
          padding: const EdgeInsets.all(24.0),
          child: Column(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              const Icon(Icons.camera_alt_rounded,
                  size: 64, color: Colors.blue),
              const SizedBox(height: 24),
              const Text(
                'Document Camera',
                style: TextStyle(fontSize: 24, fontWeight: FontWeight.bold),
              ),
              const SizedBox(height: 8),
              const Text(
                'The simplest way to start capturing documents.',
                textAlign: TextAlign.center,
                style: TextStyle(color: Colors.grey),
              ),
              const SizedBox(height: 48),

              // --- QUICK START BUTTON ---
              SizedBox(
                width: double.infinity,
                child: FilledButton.icon(
                  onPressed: () => _launchSimpleCamera(context),
                  icon: const Icon(Icons.flash_on),
                  label: const Text('Launch Simple ID Capture'),
                  style: FilledButton.styleFrom(
                    padding: const EdgeInsets.symmetric(vertical: 16),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- EXPORT FORMATS BUTTON ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const ExportFormatScreen()),
                    );
                  },
                  icon: const Icon(Icons.picture_as_pdf_rounded),
                  label:
                      const Text('Test Export Formats (JPG, PNG, PDF, TIFF)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),

              const SizedBox(height: 16),

              // --- ADVANCED EXAMPLES BUTTON ---
              SizedBox(
                width: double.infinity,
                child: OutlinedButton.icon(
                  onPressed: () {
                    Navigator.push(
                      context,
                      MaterialPageRoute(
                          builder: (_) => const SelectionScreen()),
                    );
                  },
                  icon: const Icon(Icons.settings_input_component),
                  label: const Text(
                      'Advanced Modes (Minimal, Kiosk, Overlay, Text Extract, Cam Scanner)'),
                  style: OutlinedButton.styleFrom(
                    padding: const EdgeInsets.all(8),
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  void _launchSimpleCamera(BuildContext context) {
    // -------------------------------------------------------------------------
    // QUICK START EXAMPLE:
    // Just pass the frame dimensions and a save callback.
    // -------------------------------------------------------------------------
    Navigator.push(
      context,
      MaterialPageRoute(
        builder: (ctx) => DocumentCameraFrame(
          // 1. Set the visual frame size (e.g. standard ID card ratio)
          frameWidth: 320,
          frameHeight: 200,

          // 2. Decide if you need front+back or just front
          requireBothSides: true,

          // 3. Handle the result
          onDocumentSaved: (data) {
            Navigator.pop(ctx);
            Navigator.push(
              ctx,
              MaterialPageRoute(
                  builder: (_) => ResultScreen(documentData: data)),
            );
          },
        ),
      ),
    );
  }
}
