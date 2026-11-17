import Flutter
import UIKit

final class TapPaySceneBridge: NSObject, FlutterPlugin, FlutterSceneLifeCycleDelegate {
  private static let channelName = "tappay/widget_link"
  private static let coverTag = 74_201

  private let channel: FlutterMethodChannel
  private var initialLink: String?

  init(channel: FlutterMethodChannel) {
    self.channel = channel
    super.init()
  }

  static func register(with registrar: FlutterPluginRegistrar) {
    let channel = FlutterMethodChannel(name: channelName, binaryMessenger: registrar.messenger())
    let instance = TapPaySceneBridge(channel: channel)
    registrar.addMethodCallDelegate(instance, channel: channel)
    registrar.addSceneDelegate(instance)
  }

  func handle(_ call: FlutterMethodCall, result: @escaping FlutterResult) {
    switch call.method {
    case "getInitialLink":
      result(initialLink)
      initialLink = nil
    default:
      result(FlutterMethodNotImplemented)
    }
  }

  func scene(
    _ scene: UIScene,
    willConnectTo session: UISceneSession,
    options connectionOptions: UIScene.ConnectionOptions?
  ) -> Bool {
    if let url = connectionOptions?.urlContexts.first?.url, Self.isWidgetLink(url) {
      initialLink = url.absoluteString
    }
    return false
  }

  func scene(_ scene: UIScene, openURLContexts URLContexts: Set<UIOpenURLContext>) -> Bool {
    guard let url = URLContexts.first?.url, Self.isWidgetLink(url) else { return false }
    channel.invokeMethod("onLink", arguments: url.absoluteString)
    return true
  }

  func sceneWillResignActive(_ scene: UIScene) {
    showPrivacyCover(in: scene)
  }

  func sceneDidEnterBackground(_ scene: UIScene) {
    showPrivacyCover(in: scene)
  }

  func sceneDidBecomeActive(_ scene: UIScene) {
    hidePrivacyCover(in: scene)
  }

  private static func isWidgetLink(_ url: URL) -> Bool {
    url.scheme == "tappay" && url.host == "qr_scanner"
  }

  private func window(for scene: UIScene) -> UIWindow? {
    guard let windowScene = scene as? UIWindowScene else { return nil }
    return windowScene.windows.first(where: { $0.isKeyWindow }) ?? windowScene.windows.first
  }

  private func showPrivacyCover(in scene: UIScene) {
    guard let window = window(for: scene), window.viewWithTag(Self.coverTag) == nil else { return }

    let cover = UIVisualEffectView(effect: UIBlurEffect(style: .systemThickMaterial))
    cover.tag = Self.coverTag
    cover.frame = window.bounds
    cover.autoresizingMask = [.flexibleWidth, .flexibleHeight]

    let icon = UIImageView(image: UIImage(systemName: "lock.shield.fill"))
    icon.tintColor = UIColor(red: 0, green: 0.816, blue: 0.518, alpha: 1)
    icon.contentMode = .scaleAspectFit
    icon.translatesAutoresizingMaskIntoConstraints = false

    let label = UILabel()
    label.text = "TapPay Secure Shield"
    label.font = .systemFont(ofSize: 17, weight: .semibold)
    label.textColor = .label
    label.translatesAutoresizingMaskIntoConstraints = false

    cover.contentView.addSubview(icon)
    cover.contentView.addSubview(label)
    NSLayoutConstraint.activate([
      icon.centerXAnchor.constraint(equalTo: cover.contentView.centerXAnchor),
      icon.centerYAnchor.constraint(equalTo: cover.contentView.centerYAnchor, constant: -16),
      icon.widthAnchor.constraint(equalToConstant: 56),
      icon.heightAnchor.constraint(equalToConstant: 56),
      label.centerXAnchor.constraint(equalTo: cover.contentView.centerXAnchor),
      label.topAnchor.constraint(equalTo: icon.bottomAnchor, constant: 14),
    ])

    window.addSubview(cover)
  }

  private func hidePrivacyCover(in scene: UIScene) {
    window(for: scene)?.viewWithTag(Self.coverTag)?.removeFromSuperview()
  }
}
