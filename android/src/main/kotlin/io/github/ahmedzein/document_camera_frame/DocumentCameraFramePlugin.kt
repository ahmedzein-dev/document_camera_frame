package io.github.ahmedzein.document_camera_frame

import io.flutter.embedding.engine.plugins.FlutterPlugin
import io.flutter.plugin.common.MethodCall
import io.flutter.plugin.common.MethodChannel
import io.flutter.plugin.common.MethodChannel.MethodCallHandler
import io.flutter.plugin.common.MethodChannel.Result

/** DocumentCameraFramePlugin */
class DocumentCameraFramePlugin: FlutterPlugin, MethodCallHandler {
  private lateinit var channel : MethodChannel

  override fun onAttachedToEngine(flutterPluginBinding: FlutterPlugin.FlutterPluginBinding) {
    channel = MethodChannel(flutterPluginBinding.binaryMessenger, "flutter_doc_scanner")
    channel.setMethodCallHandler(this)
  }

  override fun onMethodCall(call: MethodCall, result: Result) {
    // Android scanning is handled in Dart via google_mlkit_document_scanner.
    // This handler satisfies the platform implementation requirement for pub.dev.
    result.notImplemented()
  }

  override fun onDetachedFromEngine(binding: FlutterPlugin.FlutterPluginBinding) {
    channel.setMethodCallHandler(null)
  }
}
