package io.github.ahmedzein.document_camera_frame

import io.flutter.embedding.engine.plugins.FlutterPlugin

/** DocumentCameraFramePlugin */
class DocumentCameraFramePlugin: FlutterPlugin {
  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    // We don't need any method channels for Android in this package
    // because we use the Dart-only google_mlkit_document_scanner dependency.
    // This registration satisfies the Flutter build system.
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
  }
}
