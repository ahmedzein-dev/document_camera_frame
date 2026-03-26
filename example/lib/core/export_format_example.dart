import 'dart:io';
import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';
import 'package:open_file/open_file.dart';

/// Example screen demonstrating different export formats with verification and preview.
class ExportFormatScreen extends StatelessWidget {
  const ExportFormatScreen({super.key});

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar:
          AppBar(title: const Text('Export Format Demo'), centerTitle: true),
      body: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            const Text(
              'Select an export format to test:',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 20),
            _buildFormatCard(
              context,
              'JPG (Default)',
              'Standard JPEG format',
              Icons.image,
              DocumentOutputFormat.jpg,
              Colors.orange,
            ),
            const SizedBox(height: 12),
            _buildFormatCard(
              context,
              'PNG',
              'Lossless compression format',
              Icons.image_outlined,
              DocumentOutputFormat.png,
              Colors.green,
            ),
            const SizedBox(height: 12),
            _buildFormatCard(
              context,
              'PDF',
              'Multi-page PDF document',
              Icons.picture_as_pdf,
              DocumentOutputFormat.pdf,
              Colors.red,
            ),
            const SizedBox(height: 12),
            _buildFormatCard(
              context,
              'TIFF',
              'High-quality archival format',
              Icons.collections,
              DocumentOutputFormat.tiff,
              Colors.blue,
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildFormatCard(
    BuildContext context,
    String title,
    String subtitle,
    IconData icon,
    DocumentOutputFormat format,
    Color color,
  ) {
    return Card(
      elevation: 2,
      child: ListTile(
        leading: Icon(icon, size: 40, color: color),
        title: Text(title, style: const TextStyle(fontWeight: FontWeight.bold)),
        subtitle: Text(subtitle),
        trailing: const Icon(Icons.arrow_forward_ios),
        onTap: () => _launchCamera(context, format),
      ),
    );
  }

  // ---------------------------------------------------------------------------
  // Flutter-standard await pattern — push the camera, wait for the result,
  // then navigate to the preview.
  // onDocumentSaved is optional — use it only for side effects like analytics
  // or intermediate processing. Navigation is already handled: the package
  // pops with the result automatically.
  // ---------------------------------------------------------------------------
  Future<void> _launchCamera(
    BuildContext context,
    DocumentOutputFormat format,
  ) async {
    final DocumentCaptureData? result =
        await Navigator.push<DocumentCaptureData>(
      context,
      MaterialPageRoute(
        builder: (_) => DocumentCameraFrame(
          frameWidth: 320,
          frameHeight: 200,
          outputFormat: format,
          initialFlashMode: FlashMode.off,
          pdfPageSize: PdfPageSize.a4,
          imageQuality: 90,
          titleStyle: DocumentCameraTitleStyle(
            frontSideTitle: Text(
              'Scan Front (${format.name.toUpperCase()})',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
            backSideTitle: Text(
              'Scan Back (${format.name.toUpperCase()})',
              style: const TextStyle(color: Colors.white, fontSize: 18),
            ),
          ),
          requireBothSides: true,
          enableAutoCapture: true,
          enableExtractText: true,
          // No callback needed — await the result directly above.
          // Add onDocumentSaved only for side effects (analytics, logging).
        ),
      ),
    );

    if (result != null && context.mounted) {
      Navigator.push(
        context,
        MaterialPageRoute(
          builder: (_) => DocumentPreviewScreen(data: result, format: format),
        ),
      );
    }
  }
}

// =============================================================================

class DocumentPreviewScreen extends StatelessWidget {
  const DocumentPreviewScreen({
    super.key,
    required this.data,
    required this.format,
  });

  final DocumentCaptureData data;
  final DocumentOutputFormat format;

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        title: Text('${format.name.toUpperCase()} Preview'),
        centerTitle: true,
      ),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              _buildFormatVerification(),
              const SizedBox(height: 24),
              if (data.hasFrontSide)
                _buildImagePreview(
                  'Front Image',
                  data.frontPreviewPath ?? data.frontImagePath!,
                ),
              if (data.hasBackSide) ...[
                const SizedBox(height: 24),
                _buildImagePreview(
                  'Back Image',
                  data.backPreviewPath ?? data.backImagePath!,
                ),
              ],
              if (data.hasPdf) ...[
                const SizedBox(height: 24),
                _buildPdfInfo(context),
              ],
              const SizedBox(height: 24),
              _buildFileInfo(),
              const SizedBox(height: 24),
              _buildExtractedText(),
            ],
          ),
        ),
      ),
    );
  }

  // ── Extracted text ──────────────────────────────────────────────────────────

  Widget _buildExtractedText() {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (data.hasFrontText) ...[
          const Text(
            'Front side',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildTextBlock(data.frontOcrText!),
          const SizedBox(height: 24),
        ],
        if (data.hasBackText) ...[
          const Text(
            'Back side',
            style: TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
          ),
          const SizedBox(height: 8),
          _buildTextBlock(data.backOcrText!),
        ],
      ],
    );
  }

  Widget _buildTextBlock(String text) {
    return Container(
      padding: const EdgeInsets.all(12),
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
      ),
      child: SelectableText(
        text,
        style: const TextStyle(color: Colors.black),
      ),
    );
  }

  // ── Format verification ─────────────────────────────────────────────────────

  Widget _buildFormatVerification() {
    final expected = _expectedExtension();
    final frontExt = data.frontImagePath?.split('.').last ?? '';
    final backExt = data.backImagePath?.split('.').last ?? '';
    final pdfExt = data.pdfPath?.split('.').last ?? '';

    final bool ok = format == DocumentOutputFormat.pdf
        ? pdfExt == 'pdf'
        : frontExt == expected &&
            (data.backImagePath == null || backExt == expected);

    return Card(
      color: ok ? Colors.green.shade50 : Colors.red.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(
                  ok ? Icons.check_circle : Icons.error,
                  color: ok ? Colors.green : Colors.red,
                  size: 28,
                ),
                const SizedBox(width: 12),
                Text(
                  'Format Verification',
                  style: TextStyle(
                    fontSize: 18,
                    fontWeight: FontWeight.bold,
                    color: ok ? Colors.green.shade900 : Colors.red.shade900,
                  ),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildVerificationRow('Expected Format', expected.toUpperCase()),
            if (data.hasFrontSide)
              _buildVerificationRow('Front Image', '.$frontExt'),
            if (data.hasBackSide)
              _buildVerificationRow('Back Image', '.$backExt'),
            if (data.hasPdf) _buildVerificationRow('PDF Document', '.$pdfExt'),
            const SizedBox(height: 8),
            Text(
              ok
                  ? '✓ All files exported in correct format!'
                  : '✗ Format mismatch detected',
              style: TextStyle(
                fontWeight: FontWeight.bold,
                color: ok ? Colors.green.shade700 : Colors.red.shade700,
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _buildVerificationRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 4),
      child: Row(
        children: [
          Text('$label: ', style: const TextStyle(fontWeight: FontWeight.w500)),
          Text(value, style: const TextStyle(fontFamily: 'monospace')),
        ],
      ),
    );
  }

  // ── File info ───────────────────────────────────────────────────────────────

  Widget _buildFileInfo() {
    return Card(
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            const Text(
              'File Information',
              style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
            ),
            const SizedBox(height: 12),
            if (data.hasFrontSide)
              _buildFileDetails('Front', data.frontImagePath!),
            if (data.hasBackSide) ...[
              const Divider(height: 24),
              _buildFileDetails('Back', data.backImagePath!),
            ],
            if (data.hasPdf) ...[
              const Divider(height: 24),
              _buildFileDetails('PDF', data.pdfPath!),
            ],
          ],
        ),
      ),
    );
  }

  Widget _buildFileDetails(String label, String path) {
    final file = File(path);
    final exists = file.existsSync();
    final sizeKB = exists ? (file.lengthSync() / 1024).toStringAsFixed(2) : '0';

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          '$label Image',
          style: const TextStyle(fontWeight: FontWeight.bold, fontSize: 16),
        ),
        const SizedBox(height: 8),
        _buildInfoRow('Path', path),
        _buildInfoRow('Size', '$sizeKB KB'),
        _buildInfoRow('Exists', exists ? 'Yes ✓' : 'No ✗'),
      ],
    );
  }

  Widget _buildInfoRow(String label, String value) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 2),
      child: Row(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          SizedBox(
            width: 80,
            child: Text('$label:', style: const TextStyle(color: Colors.grey)),
          ),
          Expanded(
            child: Text(
              value,
              style: const TextStyle(fontFamily: 'monospace', fontSize: 12),
            ),
          ),
        ],
      ),
    );
  }

  // ── Image preview ───────────────────────────────────────────────────────────

  Widget _buildImagePreview(String title, String path) {
    final file = File(path);
    final exists = file.existsSync();

    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(
          title,
          style: const TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
        ),
        const SizedBox(height: 12),
        if (exists)
          ClipRRect(
            borderRadius: BorderRadius.circular(8),
            child: Image.file(
              file,
              width: double.infinity,
              fit: BoxFit.cover,
              errorBuilder: (_, __, ___) => _previewUnavailable(),
            ),
          )
        else
          Container(
            height: 200,
            decoration: BoxDecoration(
              color: Colors.grey.shade200,
              borderRadius: BorderRadius.circular(8),
            ),
            child: const Center(child: Text('Image not found')),
          ),
      ],
    );
  }

  Widget _previewUnavailable() {
    return Container(
      height: 200,
      width: double.infinity,
      decoration: BoxDecoration(
        color: Colors.grey.shade200,
        borderRadius: BorderRadius.circular(8),
        border: Border.all(color: Colors.grey.shade400),
      ),
      child: Column(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          const Icon(Icons.broken_image, size: 48, color: Colors.grey),
          const SizedBox(height: 12),
          const Text(
            'Preview not available',
            style: TextStyle(fontWeight: FontWeight.bold),
          ),
          const SizedBox(height: 4),
          Text(
            'Format may not be supported by device viewer',
            style: TextStyle(color: Colors.grey.shade600, fontSize: 12),
          ),
        ],
      ),
    );
  }

  // ── PDF info ────────────────────────────────────────────────────────────────

  Widget _buildPdfInfo(BuildContext context) {
    final file = File(data.pdfPath!);
    final exists = file.existsSync();
    final sizeKB = exists ? (file.lengthSync() / 1024).toStringAsFixed(2) : '0';

    return Card(
      color: Colors.blue.shade50,
      child: Padding(
        padding: const EdgeInsets.all(16),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Icon(Icons.picture_as_pdf,
                    color: Colors.red.shade700, size: 32),
                const SizedBox(width: 12),
                const Text(
                  'PDF Document',
                  style: TextStyle(fontSize: 18, fontWeight: FontWeight.bold),
                ),
              ],
            ),
            const SizedBox(height: 12),
            _buildInfoRow('Path', data.pdfPath!),
            _buildInfoRow('Size', '$sizeKB KB'),
            _buildInfoRow('Pages', data.hasBackSide ? '2' : '1'),
            _buildInfoRow('Page Size', 'A4'),
            const SizedBox(height: 12),
            const Text(
              '📄 PDF contains both front and back images as separate pages',
              style: TextStyle(fontStyle: FontStyle.italic),
            ),
            const SizedBox(height: 16),
            SizedBox(
              width: double.infinity,
              child: ElevatedButton.icon(
                onPressed: exists
                    ? () async {
                        try {
                          await OpenFile.open(data.pdfPath!);
                        } catch (e) {
                          if (!context.mounted) return;
                          ScaffoldMessenger.of(context).showSnackBar(
                            SnackBar(
                              content: Text('Could not open PDF: $e'),
                              backgroundColor: Colors.red,
                            ),
                          );
                        }
                      }
                    : null,
                icon: const Icon(Icons.open_in_new),
                label: const Text('View / Download PDF'),
                style: ElevatedButton.styleFrom(
                  padding: const EdgeInsets.symmetric(vertical: 12),
                  backgroundColor: Colors.red.shade700,
                  foregroundColor: Colors.white,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }

  // ── Helpers ─────────────────────────────────────────────────────────────────

  String _expectedExtension() {
    switch (format) {
      case DocumentOutputFormat.jpg:
        return 'jpg';
      case DocumentOutputFormat.png:
        return 'png';
      case DocumentOutputFormat.pdf:
        return 'pdf';
      case DocumentOutputFormat.tiff:
        return 'tiff';
    }
  }
}
