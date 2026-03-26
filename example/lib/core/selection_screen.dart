import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';
import 'models.dart';
import 'widgets.dart';
import 'camera_screen.dart';
import 'result_screen.dart';

class SelectionScreen extends StatefulWidget {
  const SelectionScreen({super.key});

  @override
  State<SelectionScreen> createState() => _SelectionScreenState();
}

class _SelectionScreenState extends State<SelectionScreen> {
  DocumentType _selectedDocType = DocumentType.idCard;
  DocumentCameraUIMode _selectedUiMode = DocumentCameraUIMode.defaultMode;

  static const _docTypes = [
    DocTypeInfo(
      type: DocumentType.idCard,
      label: 'ID Card',
      subtitle: "National ID / Driver's licence",
      icon: Icons.credit_card_rounded,
      frameWidth: 320,
      frameHeight: 200,
      isTwoSided: true,
    ),
    DocTypeInfo(
      type: DocumentType.passport,
      label: 'Passport',
      subtitle: 'International travel document',
      icon: Icons.book_rounded,
      frameWidth: 300,
      frameHeight: 420,
      isTwoSided: false,
    ),
    DocTypeInfo(
      type: DocumentType.driverLicense,
      label: "Driver's Licence",
      subtitle: 'Full licence — front & back',
      icon: Icons.drive_eta_rounded,
      frameWidth: 320,
      frameHeight: 200,
      isTwoSided: true,
    ),
  ];

  static const _uiModes = [
    UiModeInfo(
      mode: DocumentCameraUIMode.defaultMode,
      label: 'Default',
      description:
          'Full UI with dark overlay, frame box, guidance and progress',
      icon: Icons.view_quilt_rounded,
    ),
    UiModeInfo(
      mode: DocumentCameraUIMode.minimal,
      label: 'Minimal',
      description: 'Camera + four corner indicators only — no overlays',
      icon: Icons.crop_free_rounded,
    ),
    UiModeInfo(
      mode: DocumentCameraUIMode.overlay,
      label: 'Overlay',
      description: 'Full UI but without the dark background cutout',
      icon: Icons.layers_rounded,
    ),
    UiModeInfo(
      mode: DocumentCameraUIMode.kiosk,
      label: 'Kiosk',
      description: 'Auto-capture only — navigation & save buttons remain',
      icon: Icons.desktop_windows_rounded,
    ),
    UiModeInfo(
      mode: DocumentCameraUIMode.textExtract,
      label: 'Text Extract',
      description: 'Auto-captures and runs OCR — text returned in result',
      icon: Icons.text_fields_rounded,
    ),
    UiModeInfo(
      mode: DocumentCameraUIMode.camScanner,
      label: 'Cam Scanner',
      description:
          'Launches native scanner (ML Kit on Android, VisionKit on iOS)',
      icon: Icons.document_scanner_rounded,
    ),
  ];

  DocTypeInfo get _currentDoc =>
      _docTypes.firstWhere((d) => d.type == _selectedDocType);

  // ---------------------------------------------------------------------------
  // Flutter-standard await pattern — push the camera, wait for it to pop
  // with the result, then navigate forward. Identical to showDatePicker /
  // ImagePicker / showModalBottomSheet — no surprises for any Flutter dev.
  // ---------------------------------------------------------------------------
  Future<void> _launch() async {
    final DocumentCaptureData? result =
        await Navigator.push<DocumentCaptureData>(
      context,
      MaterialPageRoute<DocumentCaptureData>(
        builder: (_) => CameraScreen(
          docInfo: _currentDoc,
          uiMode: _selectedUiMode,
        ),
      ),
    );

    if (result != null && mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(builder: (_) => ResultScreen(documentData: result)),
      );
    }
  }

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      backgroundColor: cs.surface,
      appBar: AppBar(
        backgroundColor: cs.surface,
        elevation: 0,
        title: const Text(
          'Document Camera',
          style: TextStyle(fontWeight: FontWeight.w700, fontSize: 22),
        ),
        centerTitle: false,
      ),
      body: SafeArea(
        child: Column(
          children: [
            Expanded(
              child: SingleChildScrollView(
                padding: const EdgeInsets.fromLTRB(20, 8, 20, 20),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    _sectionLabel('Document type'),
                    const SizedBox(height: 10),
                    DocTypeSelector(
                      types: _docTypes,
                      selected: _selectedDocType,
                      onChanged: (t) => setState(() => _selectedDocType = t),
                    ),
                    const SizedBox(height: 28),
                    _sectionLabel('UI mode'),
                    const SizedBox(height: 10),
                    UiModeSelector(
                      modes: _uiModes,
                      selected: _selectedUiMode,
                      onChanged: (m) => setState(() => _selectedUiMode = m),
                    ),
                  ],
                ),
              ),
            ),
            LaunchBar(onLaunch: _launch),
          ],
        ),
      ),
    );
  }

  Widget _sectionLabel(String text) => Text(
        text,
        style: TextStyle(
          fontSize: 16,
          fontWeight: FontWeight.w600,
          color: Theme.of(context).colorScheme.onSurfaceVariant,
          letterSpacing: .8,
        ),
      );
}
