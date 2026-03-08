import SwiftUI
import AppKit
import CoreImage.CIFilterBuiltins

struct MenuBarView: View {
    @ObservedObject var subscriber: NtfySubscriber
    @ObservedObject var launchAtLoginController: LaunchAtLoginController
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
                launchAtLoginPanel
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
            launchAtLoginController.refresh()
        }
    }

    private var launchAtLoginPanel: some View {
        VStack(alignment: .leading, spacing: 10) {
            HStack(alignment: .top, spacing: 12) {
                VStack(alignment: .leading, spacing: 3) {
                    Text(AppText.pick(ko: "로그인 시 자동 실행", en: "Launch at Login"))
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(nsColor: .labelColor))

                    Text(AppText.pick(
                        ko: "로그인하면 우주사과를 자동으로 열어 메뉴바에서 바로 대기합니다.",
                        en: "Start Woojusagwa automatically after login and keep it ready in the menu bar."
                    ))
                    .font(.system(size: 10, weight: .regular, design: .rounded))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                    .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 10)

                Toggle(
                    "",
                    isOn: Binding(
                        get: { launchAtLoginController.isEnabled },
                        set: { launchAtLoginController.setEnabled($0) }
                    )
                )
                .labelsHidden()
                .toggleStyle(.switch)
            }

            Text(launchAtLoginController.statusText)
                .font(.system(size: 10, weight: .medium, design: .rounded))
                .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                .fixedSize(horizontal: false, vertical: true)
        }
        .padding(12)
        .menuPanel(fill: Color(nsColor: .controlBackgroundColor))
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
            VStack(alignment: .leading, spacing: 3) {
                Text(AppText.pick(ko: "빠른 작업", en: "Quick Actions"))
                    .font(.system(size: 11, weight: .semibold, design: .rounded))
                    .foregroundStyle(Color(nsColor: .secondaryLabelColor))

                Text(AppText.pick(
                    ko: "페어링, 테스트, 권한 점검을 여기서 바로 처리합니다.",
                    en: "Handle pairing, testing, and permission checks from here."
                ))
                .font(.system(size: 11, weight: .regular, design: .rounded))
                .foregroundStyle(Color(nsColor: .tertiaryLabelColor))
                .fixedSize(horizontal: false, vertical: true)
            }

            primaryActionButton(
                title: AppText.pick(ko: "새 페어링 QR 만들기", en: "Create New Pairing QR"),
                subtitle: AppText.pick(
                    ko: "이 Mac의 새 토픽과 QR을 즉시 생성합니다.",
                    en: "Generate a fresh topic and QR for this Mac."
                ),
                systemImage: "qrcode.viewfinder",
                action: generatePairingPayload
            )

            LazyVGrid(
                columns: [
                    GridItem(.flexible(), spacing: 10),
                    GridItem(.flexible(), spacing: 10),
                ],
                spacing: 10
            ) {
                secondaryActionButton(
                    title: AppText.pick(ko: "테스트 알림", en: "Test Notification"),
                    subtitle: AppText.pick(
                        ko: "알림센터 경로를 확인합니다.",
                        en: "Check Notification Center delivery."
                    ),
                    systemImage: "bell.badge",
                    tone: .accent
                ) {
                    subscriber.sendTestNotification()
                }

                secondaryActionButton(
                    title: AppText.pick(ko: "권한 다시 확인", en: "Check Permissions"),
                    subtitle: AppText.pick(
                        ko: "현재 알림 권한 상태를 새로 읽습니다.",
                        en: "Refresh the current notification permission state."
                    ),
                    systemImage: "checkmark.shield",
                    tone: .neutral
                ) {
                    subscriber.requestNotificationAuthorization()
                }

                secondaryActionButton(
                    title: AppText.pick(ko: "알림 설정 열기", en: "Open Notification Settings"),
                    subtitle: AppText.pick(
                        ko: "시스템 알림 설정으로 이동합니다.",
                        en: "Open the macOS notification settings."
                    ),
                    systemImage: "gearshape",
                    tone: .neutral
                ) {
                    subscriber.openNotificationSettings()
                }

                secondaryActionButton(
                    title: AppText.pick(ko: "종료", en: "Quit"),
                    subtitle: AppText.pick(
                        ko: "우주사과를 완전히 종료합니다.",
                        en: "Terminate the menu bar app."
                    ),
                    systemImage: "xmark.circle",
                    tone: .critical
                ) {
                    NSApplication.shared.terminate(nil)
                }
            }
        }
        .padding(14)
        .menuPanel(fill: Color(nsColor: .windowBackgroundColor))
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

    private func primaryActionButton(
        title: String,
        subtitle: String,
        systemImage: String,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            HStack(spacing: 12) {
                Image(systemName: systemImage)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundStyle(.white)
                    .frame(width: 30, height: 30)
                    .background(
                        RoundedRectangle(cornerRadius: 9, style: .continuous)
                            .fill(Color.white.opacity(0.14))
                    )

                VStack(alignment: .leading, spacing: 2) {
                    Text(title)
                        .font(.system(size: 13, weight: .semibold, design: .rounded))
                        .foregroundStyle(.white)
                    Text(subtitle)
                        .font(.system(size: 10, weight: .medium, design: .rounded))
                        .foregroundStyle(Color.white.opacity(0.86))
                        .fixedSize(horizontal: false, vertical: true)
                }

                Spacer(minLength: 8)

                Image(systemName: "arrow.up.right")
                    .font(.system(size: 12, weight: .semibold))
                    .foregroundStyle(Color.white.opacity(0.86))
            }
            .padding(14)
            .frame(maxWidth: .infinity, alignment: .leading)
        }
        .buttonStyle(.plain)
        .menuPanel(
            fill: Color(nsColor: .controlAccentColor).opacity(0.92),
            stroke: Color(nsColor: .controlAccentColor).opacity(0.42)
        )
    }

    private func secondaryActionButton(
        title: String,
        subtitle: String,
        systemImage: String,
        tone: SecondaryActionTone,
        action: @escaping () -> Void
    ) -> some View {
        Button(action: action) {
            VStack(alignment: .leading, spacing: 10) {
                Image(systemName: systemImage)
                    .font(.system(size: 14, weight: .semibold))
                    .foregroundStyle(tone.accentColor)
                    .frame(width: 30, height: 30)
                    .background(
                        Circle()
                            .fill(tone.accentColor.opacity(0.12))
                    )

                VStack(alignment: .leading, spacing: 3) {
                    Text(title)
                        .font(.system(size: 12, weight: .semibold, design: .rounded))
                        .foregroundStyle(Color(nsColor: .labelColor))
                        .multilineTextAlignment(.leading)

                    Text(subtitle)
                        .font(.system(size: 10, weight: .regular, design: .rounded))
                        .foregroundStyle(Color(nsColor: .secondaryLabelColor))
                        .fixedSize(horizontal: false, vertical: true)
                        .multilineTextAlignment(.leading)
                }

                Spacer(minLength: 0)
            }
            .padding(12)
            .frame(maxWidth: .infinity, minHeight: 108, alignment: .topLeading)
        }
        .buttonStyle(.plain)
        .menuPanel(
            fill: tone.fillColor,
            stroke: tone.borderColor
        )
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

private enum SecondaryActionTone {
    case neutral
    case accent
    case critical

    var accentColor: Color {
        switch self {
        case .neutral:
            return Color(nsColor: .secondaryLabelColor)
        case .accent:
            return Color(nsColor: .controlAccentColor)
        case .critical:
            return Color(nsColor: .systemRed)
        }
    }

    var fillColor: Color {
        switch self {
        case .neutral:
            return Color(nsColor: .controlBackgroundColor)
        case .accent:
            return Color(nsColor: .controlAccentColor).opacity(0.08)
        case .critical:
            return Color(nsColor: .systemRed).opacity(0.08)
        }
    }

    var borderColor: Color {
        switch self {
        case .neutral:
            return Color(nsColor: .separatorColor).opacity(0.20)
        case .accent:
            return Color(nsColor: .controlAccentColor).opacity(0.20)
        case .critical:
            return Color(nsColor: .systemRed).opacity(0.22)
        }
    }
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
