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
