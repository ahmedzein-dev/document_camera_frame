import 'dart:io';
import 'package:pdf/pdf.dart';
import 'package:pdf/widgets.dart' as pw;
import 'package:path_provider/path_provider.dart';

import '../core/enums.dart';

/// Service for generating PDF documents from captured images
class PdfGenerationService {
  /// Generates a PDF document from captured images
  ///
  /// [frontImagePath] - Path to the front side image (required)
  /// [backImagePath] - Path to the back side image (optional)
  /// [pageSize] - PDF page size (A4 or Letter)
  /// [imageQuality] - JPEG compression quality (1-100)
  ///
  /// Returns the path to the generated PDF file
  Future<String> generatePdf({
    required String frontImagePath,
    String? backImagePath,
    PdfPageSize pageSize = PdfPageSize.a4,
    int imageQuality = 85,
  }) async {
    final pdf = pw.Document();

    // Determine page format
    final PdfPageFormat format = pageSize == PdfPageSize.a4
        ? PdfPageFormat.a4
        : PdfPageFormat.letter;

    // Load front image
    final frontImageFile = File(frontImagePath);
    final frontImageBytes = await frontImageFile.readAsBytes();
    final frontImage = pw.MemoryImage(frontImageBytes);

    // Add front page
    pdf.addPage(
      pw.Page(
        pageFormat: format,
        build: (pw.Context context) {
          return pw.Center(child: pw.Image(frontImage, fit: pw.BoxFit.contain));
        },
      ),
    );

    // Add back page if provided
    if (backImagePath != null && backImagePath.isNotEmpty) {
      final backImageFile = File(backImagePath);
      final backImageBytes = await backImageFile.readAsBytes();
      final backImage = pw.MemoryImage(backImageBytes);

      pdf.addPage(
        pw.Page(
          pageFormat: format,
          build: (pw.Context context) {
            return pw.Center(
              child: pw.Image(backImage, fit: pw.BoxFit.contain),
            );
          },
        ),
      );
    }

    // Save PDF to temporary directory
    final tempDir = await getTemporaryDirectory();
    final timestamp = DateTime.now().millisecondsSinceEpoch;
    final pdfPath = '${tempDir.path}/document_$timestamp.pdf';
    final pdfFile = File(pdfPath);
    await pdfFile.writeAsBytes(await pdf.save());

    return pdfPath;
  }
}
