import SwiftUI
import AVFoundation
import Vision
import AudioToolbox

// MARK: - App Entry Point
@main
struct QRScannerApp: App {
    var body: some Scene {
        WindowGroup {
            ScannerMainView()
        }
    }
}

// MARK: - CDPH Theme Colors
extension Color {
    static let cdphBlue = Color(red: 0.16, green: 0.26, blue: 0.62)
    static let cdphLightBlue = Color(red: 0.2, green: 0.35, blue: 0.75)
    static let cdphDarkBlue = Color(red: 0.12, green: 0.20, blue: 0.50)
    static let californiaGold = Color(red: 1.0, green: 0.65, blue: 0.0)
    static let californiaRed = Color(red: 0.85, green: 0.2, blue: 0.2)
}

// MARK: - California State Shape (for CDPH Logo)
struct CaliforniaShape: Shape {
    func path(in rect: CGRect) -> Path {
        var path = Path()
        let width = rect.size.width
        let height = rect.size.height
        
        path.move(to: CGPoint(x: 0.2 * width, y: 0.1 * height))
        path.addCurve(to: CGPoint(x: 0.4 * width, y: 0.05 * height),
                      control1: CGPoint(x: 0.3 * width, y: 0.02 * height),
                      control2: CGPoint(x: 0.35 * width, y: 0.03 * height))
        path.addCurve(to: CGPoint(x: 0.7 * width, y: 0.15 * height),
                      control1: CGPoint(x: 0.5 * width, y: 0.08 * height),
                      control2: CGPoint(x: 0.6 * width, y: 0.1 * height))
        path.addCurve(to: CGPoint(x: 0.85 * width, y: 0.3 * height),
                      control1: CGPoint(x: 0.8 * width, y: 0.2 * height),
                      control2: CGPoint(x: 0.82 * width, y: 0.25 * height))
        path.addCurve(to: CGPoint(x: 0.9 * width, y: 0.5 * height),
                      control1: CGPoint(x: 0.88 * width, y: 0.4 * height),
                      control2: CGPoint(x: 0.92 * width, y: 0.45 * height))
        path.addCurve(to: CGPoint(x: 0.85 * width, y: 0.7 * height),
                      control1: CGPoint(x: 0.88 * width, y: 0.6 * height),
                      control2: CGPoint(x: 0.87 * width, y: 0.65 * height))
        path.addCurve(to: CGPoint(x: 0.75 * width, y: 0.85 * height),
                      control1: CGPoint(x: 0.82 * width, y: 0.78 * height),
                      control2: CGPoint(x: 0.78 * width, y: 0.82 * height))
        path.addCurve(to: CGPoint(x: 0.5 * width, y: 0.95 * height),
                      control1: CGPoint(x: 0.7 * width, y: 0.9 * height),
                      control2: CGPoint(x: 0.6 * width, y: 0.93 * height))
        path.addCurve(to: CGPoint(x: 0.3 * width, y: 0.9 * height),
                      control1: CGPoint(x: 0.4 * width, y: 0.97 * height),
                      control2: CGPoint(x: 0.35 * width, y: 0.93 * height))
        path.addCurve(to: CGPoint(x: 0.15 * width, y: 0.75 * height),
                      control1: CGPoint(x: 0.25 * width, y: 0.85 * height),
                      control2: CGPoint(x: 0.2 * width, y: 0.8 * height))
        path.addCurve(to: CGPoint(x: 0.1 * width, y: 0.5 * height),
                      control1: CGPoint(x: 0.1 * width, y: 0.65 * height),
                      control2: CGPoint(x: 0.08 * width, y: 0.58 * height))
        path.addCurve(to: CGPoint(x: 0.15 * width, y: 0.3 * height),
                      control1: CGPoint(x: 0.12 * width, y: 0.4 * height),
                      control2: CGPoint(x: 0.13 * width, y: 0.35 * height))
        path.addCurve(to: CGPoint(x: 0.2 * width, y: 0.1 * height),
                      control1: CGPoint(x: 0.17 * width, y: 0.2 * height),
                      control2: CGPoint(x: 0.18 * width, y: 0.15 * height))
        path.closeSubpath()
        
        return path
    }
}

// MARK: - FDA Device Information Model
struct FDADeviceInfo: Codable {
    let deviceName: String?
    let companyName: String?
    let deviceClass: String?
    let regulationNumber: String?
    let productCode: String?
    let dateReceived: String?
    let decisionDate: String?
    let decisionDescription: String?
    
    enum CodingKeys: String, CodingKey {
        case deviceName = "device_name"
        case companyName = "applicant"
        case deviceClass = "device_class"
        case regulationNumber = "regulation_number"
        case productCode = "product_code"
        case dateReceived = "date_received"
        case decisionDate = "decision_date"
        case decisionDescription = "decision"
    }
}

struct FDAResponse: Codable {
    let results: [FDADeviceInfo]
    let meta: FDAMeta?
}

struct FDAMeta: Codable {
    let totalCount: Int
    
    enum CodingKeys: String, CodingKey {
        case totalCount = "total"
    }
}

// MARK: - FDA API Service
class FDAAPIService: ObservableObject {
    private let baseURL = "https://api.fda.gov/device/510k.json"
    
    func searchDevice(by barcode: String) async throws -> FDADeviceInfo? {
        let searchTerm = extractSearchTermFromBarcode(barcode)
        let urlString = "\(baseURL)?search=device_name:\(searchTerm)&limit=1"
        
        guard let url = URL(string: urlString) else {
            throw URLError(.badURL)
        }
        
        let (data, _) = try await URLSession.shared.data(from: url)
        let response = try JSONDecoder().decode(FDAResponse.self, from: data)
        
        return response.results.first
    }
    
    private func extractSearchTermFromBarcode(_ barcode: String) -> String {
        return barcode.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed) ?? barcode
    }
}

// MARK: - Medical Device Result View
struct MedicalDeviceResultView: View {
    let deviceInfo: FDADeviceInfo
    let barcode: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.green.opacity(0.2))
                        .frame(width: 50, height: 50)
                    
                    Image(systemName: "cross.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.green)
                }
                
                VStack(alignment: .leading, spacing: 2) {
                    Text("Medical Device Found")
                        .font(.headline)
                        .foregroundColor(.white)
                    
                    Text("FDA Database Match")
                        .font(.subheadline)
                        .foregroundColor(.white.opacity(0.8))
                }
                
                Spacer()
                
                Button("Copy") {
                    UIPasteboard.general.string = barcode
                    let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                    impactFeedback.impactOccurred()
                }
                .font(.subheadline)
                .fontWeight(.medium)
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                .background(
                    Capsule()
                        .fill(.white.opacity(0.2))
                        .overlay(
                            Capsule()
                                .stroke(.white.opacity(0.3), lineWidth: 1)
                        )
                )
                .foregroundColor(.white)
            }
            
            VStack(alignment: .leading, spacing: 12) {
                if let deviceName = deviceInfo.deviceName {
                    InfoRow(title: "Device Name", value: deviceName)
                }
                
                if let companyName = deviceInfo.companyName {
                    InfoRow(title: "Manufacturer", value: companyName)
                }
                
                if let deviceClass = deviceInfo.deviceClass {
                    InfoRow(title: "Device Class", value: "Class \(deviceClass)")
                }
                
                if let productCode = deviceInfo.productCode {
                    InfoRow(title: "Product Code", value: productCode)
                }
                
                InfoRow(title: "Scanned Barcode", value: barcode)
                
                if let regulationNumber = deviceInfo.regulationNumber {
                    InfoRow(title: "Regulation Number", value: regulationNumber)
                }
                
                if let decisionDescription = deviceInfo.decisionDescription {
                    InfoRow(title: "FDA Status", value: decisionDescription)
                }
            }
            .padding(20)
            .background(
                RoundedRectangle(cornerRadius: 16)
                    .fill(.white)
                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
            )
        }
    }
}

struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            Text(title)
                .font(.caption)
                .fontWeight(.semibold)
                .foregroundColor(.cdphBlue.opacity(0.7))
                .textCase(.uppercase)
            
            Text(value)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.cdphBlue)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
}

// MARK: - Animated CDPH Header View
struct CDPHHeaderView: View {
    @State private var animateGlow = false
    
    var body: some View {
        VStack(spacing: 16) {
            HStack(spacing: 16) {
                // Simple camera icon for scanner app
                ZStack {
                    // Camera body
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.white)
                        .frame(width: 50, height: 38)
                        .shadow(color: .black.opacity(0.2), radius: 4, x: 2, y: 2)
                    
                    // Camera lens
                    Circle()
                        .fill(Color(red: 0.16, green: 0.26, blue: 0.62))
                        .frame(width: 24, height: 24)
                    
                    // Lens center
                    Circle()
                        .fill(Color.white.opacity(0.3))
                        .frame(width: 12, height: 12)
                    
                    // Camera flash/viewfinder
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.orange)
                        .frame(width: 8, height: 6)
                        .offset(x: -15, y: -10)
                }
                .scaleEffect(animateGlow ? 1.05 : 1.0)
                .animation(.easeInOut(duration: 2.0).repeatForever(autoreverses: true), value: animateGlow)
                
                // Large CDPH text for header
                Text("CDPH")
                    .font(.system(size: 48, weight: .bold, design: .rounded))
                    .foregroundStyle(
                        LinearGradient(
                            colors: [.white, .white.opacity(0.9)],
                            startPoint: .top,
                            endPoint: .bottom
                        )
                    )
                    .shadow(color: .black.opacity(0.3), radius: 3, x: 2, y: 2)
            }
            
            VStack(spacing: 4) {
                Text("Health Scanner")
                    .font(.title2)
                    .fontWeight(.semibold)
                    .foregroundColor(.white)
                
                Text("California Department of Public Health")
                    .font(.subheadline)
                    .foregroundColor(.white.opacity(0.85))
                    .multilineTextAlignment(.center)
            }
        }
        .onAppear {
            animateGlow = true
        }
        .padding(.vertical, 20)
    }
}

// MARK: - Scanner Type Enum
enum ScannerType: String, CaseIterable {
    case qrCode = "QR Code"
    case text = "Text"
    case barcode = "Medical Device"
    
    var icon: String {
        switch self {
        case .qrCode: return "qrcode"
        case .text: return "doc.text.viewfinder"
        case .barcode: return "plus.rectangle.on.rectangle"
        }
    }
    
    var description: String {
        switch self {
        case .qrCode: return "Instantly scan QR codes for health verification and quick access"
        case .text: return "Capture and digitize printed documents with optical character recognition"
        case .barcode: return "Scan medical device barcodes and lookup FDA registration details"
        }
    }
    
    var color: Color {
        switch self {
        case .qrCode: return .californiaGold
        case .text: return .californiaRed
        case .barcode: return .green
        }
    }
}

// MARK: - Animated Scanner Card
struct ScannerTypeCard: View {
    let type: ScannerType
    let isSelected: Bool
    let action: () -> Void
    
    @State private var isPressed = false
    
    var body: some View {
        Button(action: {
            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                action()
            }
        }) {
            VStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(
                            LinearGradient(
                                colors: [
                                    isSelected ? type.color : .white.opacity(0.2),
                                    isSelected ? type.color.opacity(0.7) : .white.opacity(0.1)
                                ],
                                startPoint: .topLeading,
                                endPoint: .bottomTrailing
                            )
                        )
                        .frame(width: 60, height: 60)
                        .shadow(color: isSelected ? type.color.opacity(0.4) : .clear, radius: 8)
                    
                    Image(systemName: type.icon)
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(isSelected ? .white : .white.opacity(0.8))
                }
                .scaleEffect(isSelected ? 1.1 : 1.0)
                
                Text(type.rawValue)
                    .font(.system(size: 16, weight: .semibold))
                    .foregroundColor(.white)
                
                Text(type.description)
                    .font(.caption)
                    .foregroundColor(.white.opacity(0.7))
                    .multilineTextAlignment(.center)
                    .lineLimit(2)
            }
            .padding(20)
            .frame(maxWidth: .infinity)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(
                                LinearGradient(
                                    colors: [
                                        isSelected ? type.color : .white.opacity(0.2),
                                        isSelected ? type.color.opacity(0.5) : .white.opacity(0.1)
                                    ],
                                    startPoint: .topLeading,
                                    endPoint: .bottomTrailing
                                ),
                                lineWidth: isSelected ? 2 : 1
                            )
                    )
            )
            .scaleEffect(isPressed ? 0.95 : 1.0)
            .shadow(color: isSelected ? type.color.opacity(0.3) : .black.opacity(0.1),
                   radius: isSelected ? 12 : 4, x: 0, y: isSelected ? 6 : 2)
        }
        .buttonStyle(PlainButtonStyle())
        .onLongPressGesture(minimumDuration: 0, maximumDistance: .infinity, pressing: { pressing in
            withAnimation(.easeInOut(duration: 0.1)) {
                isPressed = pressing
            }
        }, perform: {})
        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: isSelected)
    }
}

// MARK: - Main Scanner View
struct ScannerMainView: View {
    @State private var scannedResult: String = ""
    @State private var isShowingScanner = false
    @State private var alertMessage = ""
    @State private var showAlert = false
    @State private var selectedScannerType: ScannerType = .qrCode
    @State private var showResultAnimation = false
    @State private var fdaDeviceInfo: FDADeviceInfo?
    @State private var isLoadingFDAData = false
    @StateObject private var fdaService = FDAAPIService()
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(
                    colors: [Color.cdphDarkBlue, Color.cdphBlue, Color.cdphLightBlue],
                    startPoint: .topLeading,
                    endPoint: .bottomTrailing
                )
                .ignoresSafeArea()
                
                GeometryReader { geometry in
                    ForEach(0..<3, id: \.self) { i in
                        Circle()
                            .fill(Color.white.opacity(0.05))
                            .frame(width: 200, height: 200)
                            .position(
                                x: geometry.size.width * (0.2 + Double(i) * 0.3),
                                y: geometry.size.height * (0.1 + Double(i) * 0.4)
                            )
                            .blur(radius: 2)
                    }
                }
                .ignoresSafeArea()
                
                ScrollView(showsIndicators: false) {
                    VStack(spacing: 32) {
                        CDPHHeaderView()
                        
                        VStack(spacing: 16) {
                            Text("Choose Scanner Type")
                                .font(.title3)
                                .fontWeight(.medium)
                                .foregroundColor(.white)
                            
                            HStack(spacing: 16) {
                                ScannerTypeCard(
                                    type: .qrCode,
                                    isSelected: selectedScannerType == .qrCode
                                ) {
                                    selectedScannerType = .qrCode
                                    clearResults()
                                }
                                
                                ScannerTypeCard(
                                    type: .text,
                                    isSelected: selectedScannerType == .text
                                ) {
                                    selectedScannerType = .text
                                    clearResults()
                                }
                            }
                            .padding(.horizontal, 20)
                            
                            ScannerTypeCard(
                                type: .barcode,
                                isSelected: selectedScannerType == .barcode
                            ) {
                                selectedScannerType = .barcode
                                clearResults()
                            }
                            .padding(.horizontal, 40)
                        }
                        
                        Button(action: {
                            withAnimation(.spring(response: 0.3, dampingFraction: 0.7)) {
                                requestCameraPermission()
                            }
                        }) {
                            HStack(spacing: 16) {
                                ZStack {
                                    Circle()
                                        .fill(.white.opacity(0.2))
                                        .frame(width: 44, height: 44)
                                    
                                    Image(systemName: selectedScannerType.icon)
                                        .font(.system(size: 20, weight: .medium))
                                        .foregroundColor(.white)
                                }
                                
                                VStack(alignment: .leading, spacing: 2) {
                                    Text("Start Scanning")
                                        .font(.title2)
                                        .fontWeight(.semibold)
                                    
                                    Text("Scan \(selectedScannerType.rawValue)")
                                        .font(.subheadline)
                                        .opacity(0.9)
                                }
                                
                                Spacer()
                                
                                Image(systemName: "chevron.right")
                                    .font(.title2)
                                    .fontWeight(.medium)
                            }
                            .foregroundColor(.cdphBlue)
                            .padding(.horizontal, 24)
                            .padding(.vertical, 20)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(.white)
                                    .shadow(color: .black.opacity(0.15), radius: 12, x: 0, y: 6)
                            )
                            .overlay(
                                RoundedRectangle(cornerRadius: 25)
                                    .stroke(
                                        LinearGradient(
                                            colors: [selectedScannerType.color.opacity(0.3), .clear],
                                            startPoint: .topLeading,
                                            endPoint: .bottomTrailing
                                        ),
                                        lineWidth: 1
                                    )
                            )
                        }
                        .padding(.horizontal, 20)
                        .animation(.spring(response: 0.4, dampingFraction: 0.8), value: selectedScannerType)
                        
                        if isLoadingFDAData {
                            VStack(spacing: 16) {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(1.5)
                                
                                Text("Looking up medical device in FDA database...")
                                    .font(.subheadline)
                                    .foregroundColor(.white.opacity(0.8))
                                    .multilineTextAlignment(.center)
                            }
                            .padding(24)
                            .background(
                                RoundedRectangle(cornerRadius: 20)
                                    .fill(.ultraThinMaterial)
                            )
                            .padding(.horizontal, 20)
                        }
                        
                        if !scannedResult.isEmpty {
                            if let deviceInfo = fdaDeviceInfo, selectedScannerType == .barcode {
                                MedicalDeviceResultView(deviceInfo: deviceInfo, barcode: scannedResult)
                                    .padding(.horizontal, 20)
                                    .transition(.asymmetric(
                                        insertion: .scale.combined(with: .opacity),
                                        removal: .scale.combined(with: .opacity)
                                    ))
                            } else {
                                VStack(spacing: 20) {
                                    HStack(spacing: 12) {
                                        ZStack {
                                            Circle()
                                                .fill(selectedScannerType.color.opacity(0.2))
                                                .frame(width: 40, height: 40)
                                            
                                            Image(systemName: selectedScannerType == .barcode ? "cross.fill" : "checkmark.circle.fill")
                                                .font(.system(size: 20))
                                                .foregroundColor(selectedScannerType.color)
                                                .scaleEffect(showResultAnimation ? 1.2 : 1.0)
                                                .animation(.spring(response: 0.3, dampingFraction: 0.7), value: showResultAnimation)
                                        }
                                        
                                        VStack(alignment: .leading, spacing: 2) {
                                            Text("Scan Complete")
                                                .font(.headline)
                                                .foregroundColor(.white)
                                            
                                            Text("\(selectedScannerType.rawValue) detected")
                                                .font(.subheadline)
                                                .foregroundColor(.white.opacity(0.8))
                                        }
                                        
                                        Spacer()
                                        
                                        Button("Copy") {
                                            UIPasteboard.general.string = scannedResult
                                            let impactFeedback = UIImpactFeedbackGenerator(style: .medium)
                                            impactFeedback.impactOccurred()
                                        }
                                        .font(.subheadline)
                                        .fontWeight(.medium)
                                        .padding(.horizontal, 16)
                                        .padding(.vertical, 8)
                                        .background(
                                            Capsule()
                                                .fill(.white.opacity(0.2))
                                                .overlay(
                                                    Capsule()
                                                        .stroke(.white.opacity(0.3), lineWidth: 1)
                                                )
                                        )
                                        .foregroundColor(.white)
                                    }
                                    
                                    ScrollView {
                                        Text(scannedResult)
                                            .font(.system(size: 14, design: .monospaced))
                                            .foregroundColor(.cdphBlue)
                                            .padding(20)
                                            .frame(maxWidth: .infinity, alignment: .leading)
                                            .background(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .fill(.white)
                                                    .shadow(color: .black.opacity(0.08), radius: 8, x: 0, y: 4)
                                            )
                                            .overlay(
                                                RoundedRectangle(cornerRadius: 16)
                                                    .stroke(.white.opacity(0.5), lineWidth: 1)
                                            )
                                    }
                                    .frame(maxHeight: 200)
                                }
                                .padding(24)
                                .background(
                                    RoundedRectangle(cornerRadius: 24)
                                        .fill(.ultraThinMaterial)
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 24)
                                                .stroke(
                                                    LinearGradient(
                                                        colors: [.white.opacity(0.3), .white.opacity(0.1)],
                                                        startPoint: .topLeading,
                                                        endPoint: .bottomTrailing
                                                    ),
                                                    lineWidth: 1
                                                )
                                        )
                                )
                                .padding(.horizontal, 20)
                                .transition(.asymmetric(
                                    insertion: .scale.combined(with: .opacity),
                                    removal: .scale.combined(with: .opacity)
                                ))
                            }
                            
                            if selectedScannerType == .barcode && fdaDeviceInfo == nil && !isLoadingFDAData {
                                VStack(spacing: 12) {
                                    HStack(spacing: 12) {
                                        Image(systemName: "exclamationmark.triangle.fill")
                                            .font(.system(size: 18))
                                            .foregroundColor(.orange)
                                        
                                        Text("Device not found in FDA database")
                                            .font(.subheadline)
                                            .foregroundColor(.white.opacity(0.9))
                                    }
                                    
                                    Text("The scanned barcode may not be registered with the FDA or may require manual verification.")
                                        .font(.caption)
                                        .foregroundColor(.white.opacity(0.7))
                                        .multilineTextAlignment(.center)
                                }
                                .padding(16)
                                .background(
                                    RoundedRectangle(cornerRadius: 16)
                                        .fill(.orange.opacity(0.2))
                                        .overlay(
                                            RoundedRectangle(cornerRadius: 16)
                                                .stroke(.orange.opacity(0.3), lineWidth: 1)
                                        )
                                )
                                .padding(.horizontal, 20)
                            }
                        }
                        
                        Spacer(minLength: 40)
                    }
                    .padding(.top, 20)
                    .onAppear {
                        if !scannedResult.isEmpty {
                            showResultAnimation = true
                            DispatchQueue.main.asyncAfter(deadline: .now() + 0.5) {
                                showResultAnimation = false
                            }
                        }
                    }
                }
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
        .preferredColorScheme(.dark)
        .sheet(isPresented: $isShowingScanner) {
            if selectedScannerType == .qrCode {
                QRScannerView { result in
                    handleResult(result)
                }
            } else if selectedScannerType == .text {
                TextScannerView { result in
                    handleResult(result)
                }
            } else {
                BarcodeScannerView { result in
                    handleResult(result)
                }
            }
        }
        .alert("Scanner Alert", isPresented: $showAlert) {
            Button("OK") {
                alertMessage = ""
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    private func clearResults() {
        scannedResult = ""
        fdaDeviceInfo = nil
        isLoadingFDAData = false
    }
    
    private func requestCameraPermission() {
        let cameraAuthorizationStatus = AVCaptureDevice.authorizationStatus(for: .video)
        
        switch cameraAuthorizationStatus {
        case .authorized:
            DispatchQueue.main.async {
                self.isShowingScanner = true
            }
        case .notDetermined:
            AVCaptureDevice.requestAccess(for: .video) { granted in
                DispatchQueue.main.async {
                    if granted {
                        self.isShowingScanner = true
                    } else {
                        self.alertMessage = "Camera access is required to scan QR codes and text. Please enable camera access in Settings."
                        self.showAlert = true
                    }
                }
            }
        case .denied, .restricted:
            DispatchQueue.main.async {
                self.alertMessage = "Camera access has been denied. Please go to Settings > Privacy & Security > Camera and enable access for this app."
                self.showAlert = true
            }
        @unknown default:
            DispatchQueue.main.async {
                self.alertMessage = "Camera access status is unknown. Please try again."
                self.showAlert = true
            }
        }
    }
    
    private func handleResult(_ result: String?) {
        DispatchQueue.main.async {
            withAnimation(.spring(response: 0.5, dampingFraction: 0.7)) {
                self.isShowingScanner = false
            }
            
            if let result = result, !result.isEmpty {
                withAnimation(.spring(response: 0.6, dampingFraction: 0.8).delay(0.2)) {
                    self.scannedResult = result
                }
                
                if self.selectedScannerType == .barcode {
                    self.lookupFDADevice(barcode: result)
                }
                
                let impactFeedback = UINotificationFeedbackGenerator()
                impactFeedback.notificationOccurred(.success)
            } else {
                self.alertMessage = "No \(self.selectedScannerType.rawValue.lowercased()) detected. Please try again."
                self.showAlert = true
                let impactFeedback = UINotificationFeedbackGenerator()
                impactFeedback.notificationOccurred(.error)
            }
        }
    }
    
    private func lookupFDADevice(barcode: String) {
        isLoadingFDAData = true
        
        Task {
            do {
                let deviceInfo = try await fdaService.searchDevice(by: barcode)
                
                await MainActor.run {
                    withAnimation(.spring(response: 0.5, dampingFraction: 0.8)) {
                        self.fdaDeviceInfo = deviceInfo
                        self.isLoadingFDAData = false
                    }
                }
            } catch {
                await MainActor.run {
                    self.isLoadingFDAData = false
                }
            }
        }
    }
}

// MARK: - QR Scanner View
struct QRScannerView: UIViewControllerRepresentable {
    let completion: (String?) -> Void
    
    func makeUIViewController(context: Context) -> QRScannerViewController {
        QRScannerViewController(completion: completion)
    }
    
    func updateUIViewController(_ uiViewController: QRScannerViewController, context: Context) {}
}

class QRScannerViewController: UIViewController {
    private let completion: (String?) -> Void
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false
    
    init(completion: @escaping (String?) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hasScanned = false
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    deinit {
        stopSession()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        captureSession = AVCaptureSession()
        guard let session = captureSession else { return }
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [.qr]
        }
        
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        closeButton.backgroundColor = UIColor(red: 0.16, green: 0.26, blue: 0.62, alpha: 0.9)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        let scanFrame = UIView()
        scanFrame.layer.borderColor = UIColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0).cgColor
        scanFrame.layer.borderWidth = 3
        scanFrame.layer.cornerRadius = 20
        scanFrame.backgroundColor = UIColor.clear
        scanFrame.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanFrame)
        
        let label = UILabel()
        label.text = "Point camera at QR code"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        label.backgroundColor = UIColor(red: 0.16, green: 0.26, blue: 0.62, alpha: 0.9)
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            scanFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanFrame.widthAnchor.constraint(equalToConstant: 280),
            scanFrame.heightAnchor.constraint(equalToConstant: 280),
            
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.heightAnchor.constraint(equalToConstant: 60),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func closeTapped() {
        completion(nil)
    }
    
    private func startSession() {
        guard let session = captureSession else { return }
        DispatchQueue.global(qos: .background).async {
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    private func stopSession() {
        guard let session = captureSession else { return }
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

extension QRScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        hasScanned = true
        AudioServicesPlaySystemSound(SystemSoundID(kSystemSoundID_Vibrate))
        completion(stringValue)
    }
}

// MARK: - Text Scanner View
struct TextScannerView: UIViewControllerRepresentable {
    let completion: (String?) -> Void
    
    func makeUIViewController(context: Context) -> TextScannerViewController {
        TextScannerViewController(completion: completion)
    }
    
    func updateUIViewController(_ uiViewController: TextScannerViewController, context: Context) {}
}

class TextScannerViewController: UIViewController {
    private let completion: (String?) -> Void
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var photoOutput: AVCapturePhotoOutput?
    
    init(completion: @escaping (String?) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    deinit {
        stopSession()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        captureSession = AVCaptureSession()
        guard let session = captureSession else { return }
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        photoOutput = AVCapturePhotoOutput()
        if let photoOutput = photoOutput, session.canAddOutput(photoOutput) {
            session.addOutput(photoOutput)
        }
        
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        closeButton.backgroundColor = UIColor(red: 0.16, green: 0.26, blue: 0.62, alpha: 0.9)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        let captureButton = UIButton(type: .system)
        captureButton.setTitle("📸", for: .normal)
        captureButton.titleLabel?.font = UIFont.systemFont(ofSize: 24)
        captureButton.backgroundColor = UIColor.white
        captureButton.layer.cornerRadius = 35
        captureButton.layer.shadowColor = UIColor.black.cgColor
        captureButton.layer.shadowOffset = CGSize(width: 0, height: 4)
        captureButton.layer.shadowRadius = 12
        captureButton.layer.shadowOpacity = 0.3
        captureButton.addTarget(self, action: #selector(capturePhoto), for: .touchUpInside)
        
        captureButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(captureButton)
        
        let scanFrame = UIView()
        scanFrame.layer.borderColor = UIColor(red: 1.0, green: 0.65, blue: 0.0, alpha: 1.0).cgColor
        scanFrame.layer.borderWidth = 3
        scanFrame.layer.cornerRadius = 20
        scanFrame.backgroundColor = UIColor.clear
        scanFrame.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanFrame)
        
        let label = UILabel()
        label.text = "Position text in frame and tap capture"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = UIColor(red: 0.16, green: 0.26, blue: 0.62, alpha: 0.9)
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.numberOfLines = 2
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            captureButton.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            captureButton.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            captureButton.widthAnchor.constraint(equalToConstant: 70),
            captureButton.heightAnchor.constraint(equalToConstant: 70),
            
            scanFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanFrame.widthAnchor.constraint(equalToConstant: 320),
            scanFrame.heightAnchor.constraint(equalToConstant: 220),
            
            label.bottomAnchor.constraint(equalTo: captureButton.topAnchor, constant: -30),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 60),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func closeTapped() {
        completion(nil)
    }
    
    @objc private func capturePhoto() {
        guard let photoOutput = photoOutput else { return }
        let settings = AVCapturePhotoSettings()
        photoOutput.capturePhoto(with: settings, delegate: self)
    }
    
    private func startSession() {
        guard let session = captureSession else { return }
        DispatchQueue.global(qos: .background).async {
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    private func stopSession() {
        guard let session = captureSession else { return }
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

extension TextScannerViewController: AVCapturePhotoCaptureDelegate {
    func photoOutput(_ output: AVCapturePhotoOutput, didFinishProcessingPhoto photo: AVCapturePhoto, error: Error?) {
        guard let imageData = photo.fileDataRepresentation(),
              let image = UIImage(data: imageData),
              let cgImage = image.cgImage else {
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        let request = VNRecognizeTextRequest { [weak self] request, error in
            guard let observations = request.results as? [VNRecognizedTextObservation],
                  !observations.isEmpty else {
                DispatchQueue.main.async {
                    self?.completion(nil)
                }
                return
            }
            
            let recognizedStrings = observations.compactMap { observation in
                return observation.topCandidates(1).first?.string
            }
            
            let fullText = recognizedStrings.joined(separator: "\n")
            
            DispatchQueue.main.async {
                self?.completion(fullText.isEmpty ? nil : fullText)
            }
        }
        
        request.recognitionLevel = .accurate
        request.usesLanguageCorrection = true
        
        let handler = VNImageRequestHandler(cgImage: cgImage, options: [:])
        
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try handler.perform([request])
            } catch {
                DispatchQueue.main.async {
                    self.completion(nil)
                }
            }
        }
    }
}

// MARK: - Barcode Scanner View
struct BarcodeScannerView: UIViewControllerRepresentable {
    let completion: (String?) -> Void
    
    func makeUIViewController(context: Context) -> BarcodeScannerViewController {
        BarcodeScannerViewController(completion: completion)
    }
    
    func updateUIViewController(_ uiViewController: BarcodeScannerViewController, context: Context) {}
}

class BarcodeScannerViewController: UIViewController {
    private let completion: (String?) -> Void
    private var captureSession: AVCaptureSession?
    private var previewLayer: AVCaptureVideoPreviewLayer?
    private var hasScanned = false
    
    init(completion: @escaping (String?) -> Void) {
        self.completion = completion
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupCamera()
        setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        hasScanned = false
        startSession()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        stopSession()
    }
    
    deinit {
        stopSession()
    }
    
    private func setupCamera() {
        guard let device = AVCaptureDevice.default(for: .video),
              let input = try? AVCaptureDeviceInput(device: device) else {
            DispatchQueue.main.async {
                self.completion(nil)
            }
            return
        }
        
        captureSession = AVCaptureSession()
        guard let session = captureSession else { return }
        
        session.beginConfiguration()
        
        if session.canAddInput(input) {
            session.addInput(input)
        }
        
        let output = AVCaptureMetadataOutput()
        if session.canAddOutput(output) {
            session.addOutput(output)
            output.setMetadataObjectsDelegate(self, queue: DispatchQueue.main)
            output.metadataObjectTypes = [
                .ean8, .ean13, .upce, .code39, .code39Mod43, .code93, .code128,
                .dataMatrix, .pdf417, .aztec, .interleaved2of5, .itf14
            ]
        }
        
        session.commitConfiguration()
        
        previewLayer = AVCaptureVideoPreviewLayer(session: session)
        previewLayer?.frame = view.layer.bounds
        previewLayer?.videoGravity = .resizeAspectFill
        
        if let previewLayer = previewLayer {
            view.layer.addSublayer(previewLayer)
        }
    }
    
    private func setupUI() {
        view.backgroundColor = .black
        
        let closeButton = UIButton(type: .system)
        closeButton.setTitle("✕", for: .normal)
        closeButton.setTitleColor(.white, for: .normal)
        closeButton.titleLabel?.font = UIFont.systemFont(ofSize: 18, weight: .medium)
        closeButton.backgroundColor = UIColor(red: 0.16, green: 0.26, blue: 0.62, alpha: 0.9)
        closeButton.layer.cornerRadius = 20
        closeButton.addTarget(self, action: #selector(closeTapped), for: .touchUpInside)
        
        closeButton.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(closeButton)
        
        let scanFrame = UIView()
        scanFrame.layer.borderColor = UIColor.systemGreen.cgColor
        scanFrame.layer.borderWidth = 3
        scanFrame.layer.cornerRadius = 20
        scanFrame.backgroundColor = UIColor.clear
        scanFrame.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(scanFrame)
        
        let medicalIcon = UILabel()
        medicalIcon.text = "✚"
        medicalIcon.textColor = .systemGreen
        medicalIcon.font = UIFont.systemFont(ofSize: 20, weight: .bold)
        medicalIcon.backgroundColor = UIColor.black.withAlphaComponent(0.7)
        medicalIcon.layer.cornerRadius = 15
        medicalIcon.clipsToBounds = true
        medicalIcon.textAlignment = .center
        medicalIcon.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(medicalIcon)
        
        let label = UILabel()
        label.text = "Position medical device barcode in frame\nSupports UPC, Code 128, Data Matrix & more"
        label.textColor = .white
        label.textAlignment = .center
        label.font = UIFont.systemFont(ofSize: 16, weight: .medium)
        label.backgroundColor = UIColor(red: 0.16, green: 0.26, blue: 0.62, alpha: 0.9)
        label.layer.cornerRadius = 16
        label.clipsToBounds = true
        label.numberOfLines = 3
        label.translatesAutoresizingMaskIntoConstraints = false
        view.addSubview(label)
        
        NSLayoutConstraint.activate([
            closeButton.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor, constant: 20),
            closeButton.trailingAnchor.constraint(equalTo: view.trailingAnchor, constant: -20),
            closeButton.widthAnchor.constraint(equalToConstant: 40),
            closeButton.heightAnchor.constraint(equalToConstant: 40),
            
            scanFrame.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            scanFrame.centerYAnchor.constraint(equalTo: view.centerYAnchor),
            scanFrame.widthAnchor.constraint(equalToConstant: 320),
            scanFrame.heightAnchor.constraint(equalToConstant: 200),
            
            medicalIcon.topAnchor.constraint(equalTo: scanFrame.topAnchor, constant: -15),
            medicalIcon.leadingAnchor.constraint(equalTo: scanFrame.leadingAnchor, constant: -15),
            medicalIcon.widthAnchor.constraint(equalToConstant: 30),
            medicalIcon.heightAnchor.constraint(equalToConstant: 30),
            
            label.bottomAnchor.constraint(equalTo: view.safeAreaLayoutGuide.bottomAnchor, constant: -40),
            label.centerXAnchor.constraint(equalTo: view.centerXAnchor),
            label.heightAnchor.constraint(greaterThanOrEqualToConstant: 80),
            label.leadingAnchor.constraint(greaterThanOrEqualTo: view.leadingAnchor, constant: 20),
            label.trailingAnchor.constraint(lessThanOrEqualTo: view.trailingAnchor, constant: -20)
        ])
    }
    
    @objc private func closeTapped() {
        completion(nil)
    }
    
    private func startSession() {
        guard let session = captureSession else { return }
        DispatchQueue.global(qos: .background).async {
            if !session.isRunning {
                session.startRunning()
            }
        }
    }
    
    private func stopSession() {
        guard let session = captureSession else { return }
        if session.isRunning {
            session.stopRunning()
        }
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()
        previewLayer?.frame = view.layer.bounds
    }
}

extension BarcodeScannerViewController: AVCaptureMetadataOutputObjectsDelegate {
    func metadataOutput(_ output: AVCaptureMetadataOutput, didOutput metadataObjects: [AVMetadataObject], from connection: AVCaptureConnection) {
        guard !hasScanned,
              let metadataObject = metadataObjects.first,
              let readableObject = metadataObject as? AVMetadataMachineReadableCodeObject,
              let stringValue = readableObject.stringValue else { return }
        
        hasScanned = true
        
        let impactFeedback = UIImpactFeedbackGenerator(style: .heavy)
        impactFeedback.impactOccurred()
        
        DispatchQueue.main.asyncAfter(deadline: .now() + 0.2) {
            let secondImpact = UIImpactFeedbackGenerator(style: .light)
            secondImpact.impactOccurred()
        }
        
        completion(stringValue)
    }
}
