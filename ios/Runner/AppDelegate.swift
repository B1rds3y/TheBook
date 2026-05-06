import Flutter
import UIKit

@main
@objc class AppDelegate: FlutterAppDelegate, FlutterImplicitEngineDelegate {
  /// Lets the process stay executable briefly after backgrounding so Dart/network work
  /// (e.g. CloudKit) can finish. Typical budget is on the order of ~30s; the system may end it sooner.
  private var backgroundTaskIdentifier: UIBackgroundTaskIdentifier = .invalid

  override func application(
    _ application: UIApplication,
    didFinishLaunchingWithOptions launchOptions: [UIApplication.LaunchOptionsKey: Any]?
  ) -> Bool {
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationDidEnterBackgroundNotification),
      name: UIApplication.didEnterBackgroundNotification,
      object: nil
    )
    NotificationCenter.default.addObserver(
      self,
      selector: #selector(applicationWillEnterForegroundNotification),
      name: UIApplication.willEnterForegroundNotification,
      object: nil
    )
    return super.application(application, didFinishLaunchingWithOptions: launchOptions)
  }

  deinit {
    NotificationCenter.default.removeObserver(self)
  }

  @objc private func applicationDidEnterBackgroundNotification() {
    endBackgroundTaskIfNeeded()
    backgroundTaskIdentifier = UIApplication.shared.beginBackgroundTask(withName: "CloudKitFlush") {
      [weak self] in
      self?.endBackgroundTaskIfNeeded()
    }
  }

  @objc private func applicationWillEnterForegroundNotification() {
    endBackgroundTaskIfNeeded()
  }

  private func endBackgroundTaskIfNeeded() {
    guard backgroundTaskIdentifier != .invalid else { return }
    UIApplication.shared.endBackgroundTask(backgroundTaskIdentifier)
    backgroundTaskIdentifier = .invalid
  }

  func didInitializeImplicitFlutterEngine(_ engineBridge: FlutterImplicitEngineBridge) {
    GeneratedPluginRegistrant.register(with: engineBridge.pluginRegistry)
  }
}
