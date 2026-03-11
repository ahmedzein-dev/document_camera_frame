import 'dart:io';
import 'package:flutter/services.dart';
import 'package:google_mlkit_document_scanner/google_mlkit_document_scanner.dart';

/// Platform-aware service that launches the native document scanner UI.
///
/// - **Android**: uses [google_mlkit_document_scanner].
/// - **iOS**: invokes `VNDocumentCameraViewController` via a [MethodChannel].
///
/// Returns a (possibly empty) list of file paths to the scanned images.
/// An empty list means the user cancelled.
class CamScannerService {
  static const _channel = MethodChannel('flutter_doc_scanner');

  /// Launches the native scanner UI and returns scanned image file paths.
  ///
  /// [maxPages] controls the Android page limit (ignored on iOS — the user
  /// decides how many pages to scan inside the native sheet).
  Future<List<String>> scan({int maxPages = 2}) async {
    try {
      if (Platform.isAndroid) {
        return await _scanAndroid(maxPages: maxPages);
      } else if (Platform.isIOS) {
        final results = await _scanIos();
        return results;
      }
    } catch (e) {
      // Surface as empty — callers treat an empty list as "cancelled/failed".
      return [];
    }
    return [];
  }

  // ---------------------------------------------------------------------------
  // Android – google_mlkit_document_scanner
  // ---------------------------------------------------------------------------

  Future<List<String>> _scanAndroid({required int maxPages}) async {
    final scanner = DocumentScanner(
      options: DocumentScannerOptions(
        documentFormats: const {DocumentFormat.jpeg},
        mode: ScannerMode.full,
        isGalleryImport: true,
        pageLimit: maxPages,
      ),
    );
    try {
      final result = await scanner.scanDocument();
      // result.images is List<String>? — guard against null.
      return result.images ?? [];
    } finally {
      await scanner.close();
    }
  }

  // ---------------------------------------------------------------------------
  // iOS – VNDocumentCameraViewController over a method channel
  // ---------------------------------------------------------------------------

  Future<List<String>> _scanIos() async {
    final dynamic result = await _channel.invokeMethod<dynamic>(
      'getScannedDocumentAsImages',
    );
    if (result == null) return [];
    return List<String>.from(result as List);
  }
}
