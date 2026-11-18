import Flutter
import Photos
import UIKit

/// iOS bridge. iOS does not allow third-party apps to set the wallpaper
/// programmatically, so `setWallpaper` always reports unsupported and the
/// Dart side falls back to saving into Photos with a user hint.
@main
@objc class AppDelegate: FlutterAppDelegate {
    override func application(
        _ application: UIApplication,
        didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
    ) -> Bool {
        let controller = window?.rootViewController as! FlutterViewController
        let channel = FlutterMethodChannel(
            name: "han.colors/wallpaper",
            binaryMessenger: controller.binaryMessenger)

        channel.setMethodCallHandler { call, result in
            switch call.method {
            case "saveToGallery":
                guard
                    let args = call.arguments as? [String: Any],
                    let bytes = args["bytes"] as? FlutterStandardTypedData,
                    let image = UIImage(data: bytes.data)
                else {
                    result(FlutterError(code: "BAD_ARGS", message: "missing bytes", details: nil))
                    return
                }
                PHPhotoLibrary.shared().performChanges {
                    PHAssetChangeRequest.creationRequestForAsset(from: image)
                } completionHandler: { ok, error in
                    if ok {
                        result(true)
                    } else {
                        result(FlutterError(
                            code: "SAVE_FAILED",
                            message: error?.localizedDescription,
                            details: nil))
                    }
                }
            case "setWallpaper":
                result(FlutterError(
                    code: "UNSUPPORTED",
                    message: "iOS does not allow apps to set wallpaper. Saved to Photos instead.",
                    details: nil))
            default:
                result(FlutterMethodNotImplemented)
            }
        }

        GeneratedPluginRegistrant.register(with: self)
        return super.application(application, didFinishLaunchingWithOptions: launchOptions)
    }
}
