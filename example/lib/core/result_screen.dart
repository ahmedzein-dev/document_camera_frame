import 'package:document_camera_frame/document_camera_frame.dart';
import 'package:flutter/material.dart';

class ResultScreen extends StatelessWidget {
  const ResultScreen({super.key, required this.documentData});

  final DocumentCaptureData documentData;

  @override
  Widget build(BuildContext context) {
    final cs = Theme.of(context).colorScheme;

    return Scaffold(
      appBar: AppBar(title: const Text('Result')),
      body: SafeArea(
        child: SingleChildScrollView(
          padding: const EdgeInsets.all(16),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              if (documentData.hasFrontText) ...[
                _label(context, 'Front side OCR'),
                const SizedBox(height: 8),
                _textBlock(context, cs, documentData.frontOcrText ?? ''),
                const SizedBox(height: 20),
              ],
              if (documentData.hasBackText) ...[
                _label(context, 'Back side OCR'),
                const SizedBox(height: 8),
                _textBlock(context, cs, documentData.backOcrText ?? ''),
              ],
              if (!documentData.hasFrontText && !documentData.hasBackText)
                Center(
                  child: Padding(
                    padding: const EdgeInsets.only(top: 40),
                    child: Text(
                      'Document captured successfully ✓',
                      style: TextStyle(
                        color: cs.primary,
                        fontSize: 16,
                        fontWeight: FontWeight.w600,
                      ),
                    ),
                  ),
                ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _label(BuildContext context, String text) => Text(
        text,
        style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w600),
      );

  Widget _textBlock(BuildContext context, ColorScheme cs, String text) =>
      Container(
        padding: const EdgeInsets.all(12),
        decoration: BoxDecoration(
          color: cs.surfaceContainerHighest.withValues(alpha: 0.5),
          borderRadius: BorderRadius.circular(10),
        ),
        child: SelectableText(
          text.isEmpty ? '(No text detected)' : text,
          style: Theme.of(context).textTheme.bodyMedium,
        ),
      );
}
