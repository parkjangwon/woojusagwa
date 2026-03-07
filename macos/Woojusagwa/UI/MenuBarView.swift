import SwiftUI
import AppKit
import CoreImage.CIFilterBuiltins

struct MenuBarView: View {
    @ObservedObject var subscriber: NtfySubscriber
    @State private var showingQR = false
    @State private var pairingPayload = ""
    @State private var pairingError = ""
    
    var body: some View {
        VStack(alignment: .leading, spacing: 14) {
            VStack(alignment: .leading, spacing: 4) {
                Text("우주사과")
                    .font(.system(size: 18, weight: .bold, design: .rounded))
                Text("Galaxy SMS를 Mac 알림으로 이어주는 가장 작은 네이티브 브리지")
                    .font(.system(size: 12, weight: .medium, design: .rounded))
                    .foregroundStyle(.secondary)
                Text("백엔드 없이, 계정 없이, 토픽 하나로 연결됩니다.")
                    .font(.system(size: 11, weight: .regular, design: .rounded))
                    .foregroundStyle(.secondary)
            }

            Divider()

            statusRow
            topicCard
            lastMessageCard

            Button("새 페어링 QR 만들기") {
                generatePairingPayload()
            }
            .buttonStyle(.borderedProminent)

            if showingQR {
                VStack(alignment: .center, spacing: 8) {
                    Image(nsImage: generateQRCode(from: pairingPayload))
                        .interpolation(.none)
                        .resizable()
                        .scaledToFit()
                        .frame(width: 170, height: 170)

                    Text("이 QR은 Mac의 비밀 토픽을 담고 있습니다. 믿는 기기만 스캔하세요.")
                        .font(.system(size: 11, weight: .regular, design: .rounded))
                        .foregroundStyle(.secondary)
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity)
                .padding(.vertical, 4)
            }

            if !pairingError.isEmpty {
                Text(pairingError)
                    .font(.system(size: 11, weight: .medium, design: .rounded))
                    .foregroundStyle(.red)
            }

            HStack(spacing: 10) {
                Button("마지막 메시지 복사") {
                    subscriber.copyLastMessage()
                }
                .buttonStyle(.bordered)

                Button("종료") {
                    NSApplication.shared.terminate(nil)
                }
                .buttonStyle(.plain)
            }
        }
        .padding()
        .frame(width: 320)
    }

    private var statusRow: some View {
        HStack(spacing: 8) {
            Circle()
                .fill(statusColor)
                .frame(width: 10, height: 10)
            Text(subscriber.connectionStatus)
                .font(.system(size: 12, weight: .semibold, design: .rounded))
        }
    }

    private var topicCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("현재 토픽")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(subscriber.topicLabel)
                .font(.system(size: 12, weight: .medium, design: .monospaced))
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var lastMessageCard: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text("마지막 수신")
                .font(.system(size: 11, weight: .semibold, design: .rounded))
                .foregroundStyle(.secondary)
            Text(subscriber.lastMessage)
                .font(.system(size: 12, weight: .medium, design: .rounded))
                .textSelection(.enabled)
        }
        .frame(maxWidth: .infinity, alignment: .leading)
        .padding(10)
        .background(Color(NSColor.controlBackgroundColor))
        .clipShape(RoundedRectangle(cornerRadius: 10, style: .continuous))
    }

    private var statusColor: Color {
        switch subscriber.connectionStatus {
        case "Receiving messages":
            return .green
        case "Listening on ntfy", "Connecting...":
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
            pairingError = "페어링 QR 생성에 실패했습니다. 앱을 다시 실행해 주세요."
            showingQR = false
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
