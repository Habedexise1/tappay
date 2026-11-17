import SwiftUI
import WidgetKit

private enum WidgetStore {
  static let appGroupId = "group.com.example.tappay"
  static let scannerURL = URL(string: "tappay://qr_scanner?homeWidget")!
  static let balanceKey = "widget_balance"
  static let lastAmountKey = "widget_last_amount"
  static let lastMerchantKey = "widget_last_merchant"
  static let lastDateKey = "widget_last_date"
}

struct TapPayEntry: TimelineEntry {
  let date: Date
  let balance: String
  let lastAmount: String
  let lastMerchant: String
  let lastDate: String

  static let sample = TapPayEntry(
    date: Date(),
    balance: "₦6,000,000.00",
    lastAmount: "-₦12,500.00",
    lastMerchant: "Sarah Jenkins",
    lastDate: "Today"
  )

  static func load() -> TapPayEntry {
    let store = UserDefaults(suiteName: WidgetStore.appGroupId)
    return TapPayEntry(
      date: Date(),
      balance: store?.string(forKey: WidgetStore.balanceKey) ?? "Open TapPay",
      lastAmount: store?.string(forKey: WidgetStore.lastAmountKey) ?? "—",
      lastMerchant: store?.string(forKey: WidgetStore.lastMerchantKey) ?? "No transactions yet",
      lastDate: store?.string(forKey: WidgetStore.lastDateKey) ?? ""
    )
  }
}

struct TapPayProvider: TimelineProvider {
  func placeholder(in context: Context) -> TapPayEntry {
    .sample
  }

  func getSnapshot(in context: Context, completion: @escaping (TapPayEntry) -> Void) {
    completion(context.isPreview ? .sample : .load())
  }

  func getTimeline(in context: Context, completion: @escaping (Timeline<TapPayEntry>) -> Void) {
    completion(Timeline(entries: [.load()], policy: .never))
  }
}

private struct WidgetPalette {
  let background: Color
  let primary: Color
  let secondary: Color
  let divider: Color
  let accent = Color(red: 0, green: 0.816, blue: 0.518)

  init(scheme: ColorScheme) {
    if scheme == .dark {
      background = Color(red: 0.043, green: 0.114, blue: 0.086)
      primary = .white
      secondary = Color(red: 0.631, green: 0.702, blue: 0.667)
      divider = Color(red: 0.118, green: 0.208, blue: 0.169)
    } else {
      background = .white
      primary = Color(red: 0.031, green: 0.090, blue: 0.067)
      secondary = Color(red: 0.294, green: 0.333, blue: 0.388)
      divider = Color(red: 0.898, green: 0.906, blue: 0.922)
    }
  }
}

struct TapPayWidgetView: View {
  let entry: TapPayEntry

  @Environment(\.colorScheme) private var colorScheme
  @Environment(\.widgetFamily) private var family

  var body: some View {
    let palette = WidgetPalette(scheme: colorScheme)

    VStack(alignment: .leading, spacing: 8) {
      HStack {
        Text("TapPay Balance")
          .font(.system(size: 12, weight: .medium))
          .foregroundColor(palette.secondary)
        Spacer(minLength: 4)
        Label("Scan", systemImage: "qrcode.viewfinder")
          .font(.system(size: 11, weight: .bold))
          .foregroundColor(colorScheme == .dark ? Color(red: 0.027, green: 0.082, blue: 0.059) : palette.primary)
          .padding(.horizontal, 8)
          .padding(.vertical, 4)
          .background(Capsule().fill(palette.accent))
      }

      Text(entry.balance)
        .font(.system(size: family == .systemSmall ? 18 : 22, weight: .bold))
        .foregroundColor(palette.primary)
        .lineLimit(1)
        .minimumScaleFactor(0.6)

      Spacer(minLength: 0)

      Rectangle().fill(palette.divider).frame(height: 1)

      Text("Last transaction")
        .font(.system(size: 10))
        .foregroundColor(palette.secondary)

      HStack(alignment: .firstTextBaseline) {
        VStack(alignment: .leading, spacing: 2) {
          Text(entry.lastMerchant)
            .font(.system(size: 12, weight: .semibold))
            .foregroundColor(palette.primary)
            .lineLimit(1)
          if family != .systemSmall, !entry.lastDate.isEmpty {
            Text(entry.lastDate)
              .font(.system(size: 10))
              .foregroundColor(palette.secondary)
          }
        }
        Spacer(minLength: 4)
        Text(entry.lastAmount)
          .font(.system(size: 12, weight: .bold))
          .foregroundColor(palette.accent)
          .lineLimit(1)
          .minimumScaleFactor(0.7)
      }
    }
    .widgetURL(WidgetStore.scannerURL)
    .modifier(WidgetBackground(color: palette.background))
  }
}

private struct WidgetBackground: ViewModifier {
  let color: Color

  func body(content: Content) -> some View {
    if #available(iOS 17.0, *) {
      content.containerBackground(color, for: .widget)
    } else {
      content.padding().background(color)
    }
  }
}

@main
struct TapPayWidget: Widget {
  let kind = "TapPayWidget"

  var body: some WidgetConfiguration {
    StaticConfiguration(kind: kind, provider: TapPayProvider()) { entry in
      TapPayWidgetView(entry: entry)
    }
    .configurationDisplayName("TapPay Balance")
    .description("Your primary balance, last transaction and a quick QR scan.")
    .supportedFamilies([.systemSmall, .systemMedium])
  }
}
