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
      home: const DocumentTypeSelectionScreen(),
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
          outputFormat: DocumentOutputFormat.jpg,
          titleStyle: const DocumentCameraTitleStyle(
            frontSideTitle: Text('Scan Front of License',
                style: TextStyle(color: Colors.white)),
            backSideTitle: Text('Scan Back of License',
                style: TextStyle(color: Colors.white)),
          ),
          showDetectionStatusText: true,
          requireBothSides: true,
          enableAutoCapture: true,
          enableExtractText: true,
          onFrontCaptured: (imagePath) {
            debugPrint('Front side captured: $imagePath');
          },
          onBackCaptured: (imagePath) {
            debugPrint('Back side captured: $imagePath');
          },
          onDocumentSaved: (documentData) {
            debugPrint('Document capture completed!');
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DocumentResultScreen(
                  documentData: documentData,
                ),
              ),
            );
          },
        );

      case DocumentType.passport:
        return DocumentCameraFrame(
          frameWidth: 300,
          frameHeight: 450,
          titleStyle: const DocumentCameraTitleStyle(
            title: Text('Scan Passport', style: TextStyle(color: Colors.white)),
          ),
          buttonStyle: const DocumentCameraButtonStyle(
            actionButtonHeight: 40,
          ),
          sideIndicatorStyle: const DocumentCameraSideIndicatorStyle(
            showSideIndicator: false,
          ),
          instructionStyle: const DocumentCameraInstructionStyle(
            showInstructionText: false,
          ),
          showDetectionStatusText: false,
          requireBothSides: false,
          enableAutoCapture: false,
          enableExtractText: true,
          onDocumentSaved: (documentData) {
            debugPrint('Passport captured');
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DocumentResultScreen(
                  documentData: documentData,
                ),
              ),
            );
          },
        );

      case DocumentType.idCard:
        return DocumentCameraFrame(
          frameWidth: 320,
          frameHeight: 200,
          titleStyle: const DocumentCameraTitleStyle(
            frontSideTitle:
                Text('Scan Front of ID', style: TextStyle(color: Colors.white)),
            backSideTitle:
                Text('Scan Back of ID', style: TextStyle(color: Colors.white)),
          ),
          sideIndicatorStyle: const DocumentCameraSideIndicatorStyle(
            showSideIndicator: false,
          ),
          requireBothSides: true,
          enableAutoCapture: true,
          enableExtractText: true,
          onDocumentSaved: (documentData) {
            Navigator.of(context).pop();
            Navigator.of(context).push(
              MaterialPageRoute<void>(
                builder: (context) => DocumentResultScreen(
                  documentData: documentData,
                ),
              ),
            );
          },
        );
    }
  }
}

/// Screen that displays extracted text from [DocumentCaptureData]
/// when [enableExtractText] was true on [DocumentCameraFrame].
class DocumentResultScreen extends StatelessWidget {
  const DocumentResultScreen({super.key, required this.documentData});

  final DocumentCaptureData documentData;

  @override
  Widget build(BuildContext context) {
    final frontOcrText = documentData.frontOcrText;
    final backOcrText = documentData.backOcrText;

    return Scaffold(
      appBar: AppBar(
        title: const Text('Extracted Text'),
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (documentData.hasFrontText) ...[
                const Text(
                  'Front side',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextBlock(
                  context,
                  frontOcrText?.isEmpty ?? true
                      ? '(No text detected)'
                      : (frontOcrText ?? '(Text extraction not requested)'),
                ),
                const SizedBox(height: 24),
              ],
              if (documentData.hasBackText) ...[
                const Text(
                  'Back side',
                  style: TextStyle(
                    fontWeight: FontWeight.bold,
                    fontSize: 16,
                  ),
                ),
                const SizedBox(height: 8),
                _buildTextBlock(
                  context,
                  backOcrText?.isEmpty ?? true
                      ? '(No text detected)'
                      : (backOcrText ?? '(Text extraction not requested)'),
                ),
              ],
            ],
          ),
        ),
      ),
    );
  }

  Widget _buildTextBlock(BuildContext context, String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Theme.of(context)
            .colorScheme
            .surfaceContainerHighest
            .withValues(alpha: 0.5),
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        text,
        style: Theme.of(context).textTheme.bodyMedium,
      ),
    );
  }
}

enum DocumentType { driverLicense, passport, idCard }
