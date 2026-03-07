import SwiftUI
import AppKit
import CoreImage.CIFilterBuiltins

struct MenuBarView: View {
    @ObservedObject var subscriber: NtfySubscriber
    @State private var showingQR = false
    @State private var pairingPayload = ""
    @State private var pairingError = ""

    private var summary: MenuBarSummary {
        MenuBarSummary.make(
            deviceName: subscriber.deviceNameLabel,
            deviceId: subscriber.deviceIdLabel,
            topic: subscriber.topicLabel,
            notificationStatus: subscriber.notificationAuthorizationStatus,
            languageCode: subscriber.selectedLanguage.tag
        )
    }

    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 12) {
                headerPanel
                connectionPanel

                ForEach(summary.sections) { section in
                    detailCard(section)
                }

                actionPanel

                if showingQR {
                    qrPanel
                }

                if !pairingError.isEmpty {
                    errorPanel
                }
            }
            .padding(14)
        }
        .frame(width: 372)
        .frame(maxHeight: 660)
        .onAppear {
            subscriber.refreshNotificationAuthorizationStatus()
        }
    }

    private var headerPanel: some View {
        VStack(alignment: .leading, spacing: 12) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 6) {
                    Text(summary.title)
                        .font(.system(size: 20, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(nsColor: .labelColor))

                    Text(summary.subtitle)
                        .font(.system(size: 13, weight: .medium, design: .rounded))
                        .foregroundStyle(Color(nsColor: .labelColor))
                        .fixedSize(horizontal: false, vertical: true)

                    Text(summary.footnote)
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Text(subscriber.appVersionLabel)
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 6)
                    .background(
                        Capsule(style: .continuous)
                            .fill(Color(nsColor: .controlBackgroundColor))
                    )
                    .overlay(
                        Capsule(style: .continuous)
                            .stroke(Color(nsColor: .separatorColor).opacity(0.24), lineWidth: 1)
                    )
            }

            Divider()

            HStack(spacing: 12) {
                Text(AppText.pick(ko: "언어", en: "Language"))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))

                Spacer()

                Picker(
                    "",
                    selection: Binding(
                        get: { subscriber.selectedLanguage },
                        set: { subscriber.setLanguage($0) }
                    )
                ) {
                    Text(AppLanguage.korean.displayName).tag(AppLanguage.korean)
                    Text(AppLanguage.english.displayName).tag(AppLanguage.english)
                }
                .labelsHidden()
                .pickerStyle(.segmented)
                .frame(width: 152)
            }
        }
        .padding(14)
        .menuPanel(fill: Color(nsColor: .windowBackgroundColor))
    }

    private var connectionPanel: some View {
        HStack(alignment: .top, spacing: 12) {
            ZStack {
                Circle()
                    .fill(statusColor.opacity(0.14))
                    .frame(width: 28, height: 28)

                Circle()
                    .fill(statusColor)
                    .frame(width: 8, height: 8)
            }

            VStack(alignment: .leading, spacing: 4) {
                Text(subscriber.connectionStatus.localizedLabel)
                    .font(.system(size: 13, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(nsColor: .labelColor))

                Text(connectionDescription)
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .fixedSize(horizontal: false, vertical: true)
            }

            Spacer(minLength: 0)
        }
        .padding(12)
        .menuPanel(
            fill: statusColor.opacity(0.08),
            stroke: statusColor.opacity(0.24)
        )
    }

    private func detailCard(_ section: MenuBarSummary.Section) -> some View {
        VStack(alignment: .leading, spacing: 6) {
            Text(section.title)
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(Color(nsColor: .secondaryLabelColor))

            detailText(
                section.primaryText,
                style: section.primaryStyle,
                truncatesInMiddle: section.usesMiddleTruncation
            )

            if let secondaryText = section.secondaryText {
                detailText(
                    secondaryText,
                    style: section.secondaryStyle ?? .body,
                    truncatesInMiddle: section.usesMiddleTruncation,
                    secondary: true
                )
            }
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(12)
        .menuPanel(fill: Color(nsColor: .controlBackgroundColor))
    }

    private var actionPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            actionButton(
                AppText.pick(ko: "새 페어링 QR 만들기", en: "Create New Pairing QR"),
                style: .prominent,
                action: generatePairingPayload
            )

            HStack(spacing: 10) {
                actionButton(
                    AppText.pick(ko: "테스트 알림", en: "Send Test Notification"),
                    style: .bordered
                ) {
                    subscriber.sendTestNotification()
                }

                actionButton(
                    AppText.pick(ko: "권한 다시 확인", en: "Check Permissions Again"),
                    style: .bordered
                ) {
                    subscriber.requestNotificationAuthorization()
                }
            }

            HStack(spacing: 10) {
                actionButton(
                    AppText.pick(ko: "알림 설정 열기", en: "Open Notification Settings"),
                    style: .bordered
                ) {
                    subscriber.openNotificationSettings()
                }

                Button(AppText.pick(ko: "종료", en: "Quit")) {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.borderless)
                .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                .frame(maxWidth: .infinity, alignment: .trailing)
            }
        }
        .padding(.top, 2)
    }

    private var qrPanel: some View {
        VStack(alignment: .center, spacing: 10) {
            Image(nsImage: generateQRCode(from: pairingPayload))
                .interpolation(.none)
                .resizable()
                .scaledToFit()
                .frame(width: 176, height: 176)

            Text(AppText.pick(
                ko: "이 QR은 이 Mac의 고유 토픽과 식별자를 담고 있습니다. 믿는 기기만 스캔하세요.",
                en: "This QR contains this Mac's private topic and identity. Scan it only on devices you trust."
            ))
            .font(.system(size: 11, weight: .regular, design: .rounded))
            .foregroundStyle(Color(nsColor: .secondaryLabelColor))
            .multilineTextAlignment(.center)
            .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity)
        .padding(14)
        .menuPanel(fill: Color(nsColor: .controlBackgroundColor))
    }

    private var errorPanel: some View {
        Text(pairingError)
            .font(.system(size: 11, weight: .medium, design: .rounded))
            .foregroundStyle(Color(nsColor: .systemRed))
            .fixedSize(horizontal: false, vertical: true)
            .frame(maxWidth: .infinity, alignment: .leading)
            .padding(12)
            .menuPanel(
                fill: Color(nsColor: .systemRed).opacity(0.08),
                stroke: Color(nsColor: .systemRed).opacity(0.22)
            )
    }

    private func detailText(
        _ text: String,
        style: MenuBarSummary.Section.TextStyle,
        truncatesInMiddle: Bool,
        secondary: Bool = false
    ) -> some View {
        Text(text)
            .font(
                style == .monospaced
                ? .system(size: secondary ? 11 : 12, weight: .medium, design: .monospaced)
                : .system(size: secondary ? 11 : 12, weight: .medium, design: .rounded)
            )
            .foregroundStyle(
                secondary
                ? Color(nsColor: .secondaryLabelColor)
                : Color(nsColor: .labelColor)
            )
            .lineLimit(style == .monospaced ? 2 : 3)
            .truncationMode(truncatesInMiddle ? .middle : .tail)
            .fixedSize(horizontal: false, vertical: true)
            .textSelection(.enabled)
    }

    private var connectionDescription: String {
        switch subscriber.connectionStatus {
        case .readyToPair:
            return AppText.pick(
                ko: "새 페어링 QR을 만든 뒤 Android 앱에서 스캔하면 연결됩니다.",
                en: "Create a pairing QR, then scan it from the Android app."
            )
        case .disconnected:
            return AppText.pick(
                ko: "연결이 끊어졌습니다. 토픽과 네트워크 상태를 다시 확인하세요.",
                en: "The relay connection is down. Check the topic and network state."
            )
        case .connecting, .listening:
            return AppText.pick(
                ko: "문자 알림을 기다리는 중입니다. 수신되면 macOS 알림센터에 바로 표시됩니다.",
                en: "Waiting for SMS notifications. Incoming messages appear in macOS Notification Center."
            )
        case .receiving:
            return AppText.pick(
                ko: "최근 수신이 있었고, 계속 같은 토픽에서 알림을 대기 중입니다.",
                en: "Messages were received recently and the app is still listening on this topic."
            )
        case .relayError:
            return AppText.pick(
                ko: "릴레이 연결에 문제가 있습니다. 네트워크와 ntfy 서버 주소를 확인하세요.",
                en: "There is a relay connection problem. Check the network and ntfy server address."
            )
        case .relayPayloadError:
            return AppText.pick(
                ko: "수신한 데이터 형식이 맞지 않습니다. 페어링을 다시 만들면 해결될 수 있습니다.",
                en: "The incoming relay payload is invalid. Recreating the pairing can help."
            )
        }
    }

    private var statusColor: Color {
        switch subscriber.connectionStatus {
        case .receiving:
            return Color(nsColor: .systemGreen)
        case .listening, .connecting:
            return Color(nsColor: .systemOrange)
        default:
            return Color(nsColor: .systemRed)
        }
    }

    private func generatePairingPayload() {
        do {
            pairingPayload = try subscriber.prepareFreshPairingPayload()
            pairingError = ""
            showingQR = true
        } catch {
            pairingError = AppText.pick(
                ko: "페어링 QR 생성에 실패했습니다. 앱을 다시 실행해 주세요.",
                en: "Failed to create a pairing QR. Relaunch the app and try again."
            )
            showingQR = false
        }
    }

    @ViewBuilder
    private func actionButton(
        _ title: String,
        style: ActionButtonStyle,
        action: @escaping () -> Void
    ) -> some View {
        if style == .prominent {
            Button(title, action: action)
                .buttonStyle(.borderedProminent)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
        } else {
            Button(title, action: action)
                .buttonStyle(.bordered)
                .controlSize(.large)
                .frame(maxWidth: .infinity)
        }
    }

    private func generateQRCode(from string: String) -> NSImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage,
           let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
            return NSImage(cgImage: cgimg, size: NSSize(width: 150, height: 150))
        }

        return NSImage()
    }
}

private enum ActionButtonStyle {
    case prominent
    case bordered
}

private extension View {
    func menuPanel(fill: Color, stroke: Color? = nil) -> some View {
        let border = stroke ?? Color(nsColor: .separatorColor).opacity(0.20)

        return background(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .fill(fill)
        )
        .overlay(
            RoundedRectangle(cornerRadius: 14, style: .continuous)
                .stroke(border, lineWidth: 1)
        )
    }
}
