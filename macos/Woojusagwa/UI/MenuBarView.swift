import SwiftUI
import AppKit
import CoreImage.CIFilterBuiltins

struct MenuBarView: View {
    @ObservedObject var subscriber: NtfySubscriber
    @State private var showingQR = false
    @State private var pairingPayload = ""
    @State private var pairingError = ""
    
    var body: some View {
        ScrollView(.vertical, showsIndicators: false) {
            VStack(alignment: .leading, spacing: 14) {
                VStack(alignment: .leading, spacing: 4) {
                    Text(AppText.pick(ko: "우주사과", en: "Woojusagwa"))
                        .font(.system(size: 18, weight: .bold, design: .rounded))
                    Text(AppText.pick(
                        ko: "Galaxy SMS를 여러 Mac 알림으로 이어주는 가장 작은 네이티브 브리지",
                        en: "The smallest native bridge from Galaxy SMS to multiple Mac notifications"
                    ))
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    Text(AppText.pick(
                        ko: "백엔드 없이, 계정 없이, 각 Mac의 고유 토픽으로 연결됩니다.",
                        en: "No backend, no account, just one private topic per Mac."
                    ))
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
                    .fixedSize(horizontal: false, vertical: true)
                    Text(subscriber.appVersionLabel)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.secondary)
                }

                Divider()

                statusRow
                deviceCard
                notificationCard
                topicCard
                lastMessageCard

                VStack(spacing: 10) {
                    actionButton(
                        AppText.pick(ko: "새 페어링 QR 만들기", en: "Create New Pairing QR"),
                        style: .prominent
                    ) {
                        generatePairingPayload()
                    }

                    actionButton(
                        AppText.pick(ko: "테스트 알림", en: "Send Test Notification"),
                        style: .prominent
                    ) {
                        subscriber.sendTestNotification()
                    }

                    actionButton(
                        AppText.pick(ko: "권한 다시 확인", en: "Check Permissions Again"),
                        style: .bordered
                    ) {
                        subscriber.requestNotificationAuthorization()
                    }

                    actionButton(
                        AppText.pick(ko: "알림 설정 열기", en: "Open Notification Settings"),
                        style: .bordered
                    ) {
                        subscriber.openNotificationSettings()
                    }

                    actionButton(
                        AppText.pick(ko: "마지막 메시지 복사", en: "Copy Last Message"),
                        style: .bordered
                    ) {
                        subscriber.copyLastMessage()
                    }

                    Button(AppText.pick(ko: "종료", en: "Quit")) {
                        NSApplication.shared.terminate(nil)
                    }
                    .buttonStyle(.plain)
                    .frame(maxWidth: .infinity, alignment: .trailing)
                }

                if showingQR {
                    VStack(alignment: .center, spacing: 8) {
                        Image(nsImage: generateQRCode(from: pairingPayload))
                            .interpolation(.none)
                            .resizable()
                            .scaledToFit()
                            .frame(width: 170, height: 170)

                        Text(AppText.pick(
                            ko: "이 QR은 이 Mac의 고유 토픽과 식별자를 담고 있습니다. 믿는 기기만 스캔하세요.",
                            en: "This QR contains this Mac's private topic and identity. Scan it only on devices you trust."
                        ))
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                        .fixedSize(horizontal: false, vertical: true)
                    }
                    .frame(maxWidth: .infinity)
                    .padding(.vertical, 4)
                }

                if !pairingError.isEmpty {
                    Text(pairingError)
                        .font(.system(size: 11, weight: .medium, design: .rounded))
                        .foregroundStyle(.red)
                        .fixedSize(horizontal: false, vertical: true)
                }
            }
            .padding(16)
        }
        .frame(width: 360)
        .frame(maxHeight: 680)
        .onAppear {
            subscriber.refreshNotificationAuthorizationStatus()
        }
    }

    private var statusRow: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(subscriber.connectionStatus.localizedLabel)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
    }

    private var topicCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(AppText.pick(ko: "현재 토픽", en: "Current Topic"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(subscriber.topicLabel.isEmpty ? AppText.pick(ko: "아직 페어링되지 않음", en: "Not paired yet") : subscriber.topicLabel)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
                .lineLimit(2)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var deviceCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(AppText.pick(ko: "이 Mac", en: "This Mac"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(subscriber.deviceNameLabel)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .lineLimit(2)
                .fixedSize(horizontal: false, vertical: true)
            Text(AppText.pick(ko: "ID", en: "ID") + ": \(subscriber.deviceIdLabel)")
                .font(.system(size: 11, weight: .medium, design: .monospaced))
                .foregroundStyle(.secondary)
                .lineLimit(1)
                .truncationMode(.middle)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var notificationCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(AppText.pick(ko: "알림 상태", en: "Notification Status"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(subscriber.notificationAuthorizationStatus)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .fixedSize(horizontal: false, vertical: true)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var lastMessageCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(AppText.pick(ko: "마지막 수신", en: "Last Message"))
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(subscriber.lastMessage.isEmpty ? AppText.pick(ko: "아직 수신된 메시지가 없습니다", en: "No messages received yet") : subscriber.lastMessage)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .lineLimit(4)
                .fixedSize(horizontal: false, vertical: true)
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var statusColor: Color {
        switch subscriber.connectionStatus {
        case .receiving:
            return .green
        case .listening, .connecting:
            return .orange
        default:
            return .red
        }
    }

    func generatePairingPayload() {
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
                .frame(maxWidth: .infinity, alignment: .leading)
        } else {
            Button(title, action: action)
                .buttonStyle(.bordered)
                .frame(maxWidth: .infinity, alignment: .leading)
        }
    }
    
    func generateQRCode(from string: String) -> NSImage {
        let context = CIContext()
        let filter = CIFilter.qrCodeGenerator()
        filter.message = Data(string.utf8)

        if let outputImage = filter.outputImage {
            if let cgimg = context.createCGImage(outputImage, from: outputImage.extent) {
                return NSImage(cgImage: cgimg, size: NSSize(width: 150, height: 150))
            }
        }
        return NSImage()
    }
}

private enum ActionButtonStyle {
    case prominent
    case bordered
}
