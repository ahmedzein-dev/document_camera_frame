import Flutter
import UIKit
import VisionKit
import PDFKit

@available(iOS 13.0, *)
public class DocumentCameraFramePlugin: NSObject,
    FlutterPlugin, VNDocumentCameraViewControllerDelegate {

    var resultChannel: FlutterResult?
    var presentingController: VNDocumentCameraViewController?

    public static func register(with registrar: FlutterPluginRegistrar) {
        let channel = FlutterMethodChannel(
            name: "flutter_doc_scanner",
            binaryMessenger: registrar.messenger()
        )
        let instance = DocumentCameraFramePlugin()
        registrar.addMethodCallDelegate(instance, channel: channel)
    }

    public func handle(_ call: FlutterMethodCall,
                       result: @escaping FlutterResult) {
        guard call.method == "getScannedDocumentAsImages" else {
            result(FlutterMethodNotImplemented)
            return
        }
        self.resultChannel = result
        let vc = VNDocumentCameraViewController()
        vc.delegate = self
        self.presentingController = vc
        let root = UIApplication.shared.keyWindow?.rootViewController
        root?.present(vc, animated: true)
    }

    // MARK: – VNDocumentCameraViewControllerDelegate

    public func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFinishWith scan: VNDocumentCameraScan
    ) {
        let docsDir = FileManager.default
            .urls(for: .documentDirectory, in: .userDomainMask)[0]
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd-HHmmss"
        let timestamp = formatter.string(from: Date())

        var paths: [String] = []
        for i in 0..<scan.pageCount {
            let image = scan.imageOfPage(at: i)
            let url = docsDir.appendingPathComponent("\(timestamp)-\(i).png")
            if let data = image.pngData() {
                try? data.write(to: url)
                paths.append(url.path)
            }
        }
        resultChannel?(paths)
        presentingController?.dismiss(animated: true)
    }

    public func documentCameraViewControllerDidCancel(
        _ controller: VNDocumentCameraViewController
    ) {
        resultChannel?(nil)
        presentingController?.dismiss(animated: true)
    }

    public func documentCameraViewController(
        _ controller: VNDocumentCameraViewController,
        didFailWithError error: Error
    ) {
        resultChannel?(FlutterError(
            code: "SCAN_ERROR",
            message: error.localizedDescription,
            details: nil
        ))
        presentingController?.dismiss(animated: true)
    }
}
