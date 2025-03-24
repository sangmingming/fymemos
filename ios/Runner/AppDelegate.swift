import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate {
  private var methodChannel: FlutterMethodChannel?

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    GeneratedPluginRegistrant.register(with: self)
    // 初始化 MethodChannel
    guard let controller = window?.rootViewController as? FlutterViewController else {
        fatalError("rootViewController is not type FlutterViewController")
    }
    methodChannel = FlutterMethodChannel(
        name: "app_shortcuts",
        binaryMessenger: controller.binaryMessenger
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  override func application(
        _ application: UIApplication,
        performActionFor shortcutItem: UIApplicationShortcutItem,
        completionHandler: @escaping (Bool) -> Void
    ) {
        if shortcutItem.type == "CreateMemoShortcut" {
            methodChannel?.invokeMethod("launchFromShortcut", arguments: "/create_memo")
        }
        completionHandler(true)
    }
}
