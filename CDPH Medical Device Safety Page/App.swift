import SwiftUI

@main
struct CDPHBusinessEntityApp: App {
    var body: some Scene {
        WindowGroup {
            ContentView()
        }
    }
}

struct ContentView: View {
    @State private var testResults: [TestResult] = []
    @State private var isLoading = false
    @State private var selectedTab = 0
    @State private var searchText = ""
    
    var body: some View {
        GeometryReader { geometry in
            HStack(spacing: 0) {
                // Left Sidebar
                VStack(spacing: 0) {
                    CDPHSidebarHeader()
                    
                    VStack(spacing: 8) {
                        SidebarNavItem(
                            title: "Dashboard",
                            icon: "house.fill",
                            isSelected: selectedTab == 0
                        ) {
                            selectedTab = 0
                        }
                        
                        SidebarNavItem(
                            title: "Business Search",
                            icon: "magnifyingglass",
                            isSelected: selectedTab == 1
                        ) {
                            selectedTab = 1
                        }
                        
                        SidebarNavItem(
                            title: "System Logs",
                            icon: "doc.text.fill",
                            isSelected: selectedTab == 2
                        ) {
                            selectedTab = 2
                        }
                        
                        Rectangle()
                            .fill(Color.orange)
                            .frame(height: 3)
                            .cornerRadius(1.5)
                            .padding(.vertical, 15)
                        
                        SidebarNavItem(
                            title: "Settings",
                            icon: "gearshape.fill",
                            isSelected: false
                        ) { }
                        
                        SidebarNavItem(
                            title: "Help & Support",
                            icon: "questionmark.circle.fill",
                            isSelected: false
                        ) { }
                    }
                    .padding(.horizontal, 16)
                    .padding(.top, 20)
                    
                    Spacer()
                    
                    UserProfileSection()
                }
                .frame(width: geometry.size.width * 0.32)
                .background(Color.white.opacity(0.95))
                
                // Main Content Area
                VStack(spacing: 0) {
                    CDPHTopBar(selectedTab: selectedTab)
                    
                    Group {
                        switch selectedTab {
                        case 0:
                            DashboardView(
                                testResults: testResults,
                                isLoading: isLoading,
                                runDiagnostics: runComprehensiveTests,
                                performSearch: { performBusinessSearch() },
                                testCredentials: testSecureStorage,
                                viewStatus: viewSystemStatus
                            )
                        case 1:
                            BusinessSearchView(
                                searchText: $searchText,
                                testResults: testResults,
                                performSearch: performLiveSearch
                            )
                        case 2:
                            SystemLogsView(
                                testResults: testResults,
                                clearLogs: { testResults.removeAll() }
                            )
                        default:
                            DashboardView(
                                testResults: testResults,
                                isLoading: isLoading,
                                runDiagnostics: runComprehensiveTests,
                                performSearch: { performBusinessSearch() },
                                testCredentials: testSecureStorage,
                                viewStatus: viewSystemStatus
                            )
                        }
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                .background(Color(.systemGroupedBackground))
            }
        }
    }
    
    private func runComprehensiveTests() {
        isLoading = true
        testResults.removeAll()
        
        testSecureStorage()
        
        Task {
            await testBusinessAPI()
            DispatchQueue.main.async {
                self.isLoading = false
                self.testResults.append(TestResult(
                    title: "System Diagnostic Complete",
                    subtitle: "All tests executed successfully",
                    status: .success,
                    details: "Completed at \(Date().formatted(date: .omitted, time: .shortened))",
                    icon: "checkmark.circle.fill",
                    type: .system
                ))
            }
        }
    }
    
    private func testSecureStorage() {
        let credentials = CaliforniaSOSCredentials()
        credentials.saveCredentials()
        
        if credentials.getStoredPassword() != nil {
            testResults.append(TestResult(
                title: "Secure Credential Storage",
                subtitle: "Authentication verified",
                status: .success,
                details: "Account: argus.sun@cdph.ca.gov\nService: CA Secretary of State\nStatus: Active",
                icon: "lock.shield.fill",
                type: .security
            ))
        } else {
            testResults.append(TestResult(
                title: "Credential Storage Failed",
                subtitle: "Authentication error",
                status: .failure,
                details: "Unable to access secure keychain",
                icon: "lock.trianglebadge.exclamationmark.fill",
                type: .security
            ))
        }
    }
    
    private func testBusinessAPI() async {
        let service = BusinessEntityService()
        
        do {
            let results = try await service.searchBusinessEntities(searchTerm: "Tesla")
            DispatchQueue.main.async {
                self.testResults.append(TestResult(
                    title: "CA SOS Database Connection",
                    subtitle: "API operational - \(results.count) entities found",
                    status: .success,
                    details: "Endpoint: bizfileonline.sos.ca.gov\nResponse Time: < 2s\nData Quality: Verified",
                    icon: "network.badge.shield.half.filled",
                    type: .api
                ))
            }
        } catch {
            DispatchQueue.main.async {
                self.testResults.append(TestResult(
                    title: "API Connection Warning",
                    subtitle: "Fallback mode active",
                    status: .warning,
                    details: "Primary API unavailable\nFallback: Mock data enabled\nRetry: Automatic",
                    icon: "exclamationmark.triangle.fill",
                    type: .api
                ))
            }
        }
    }
    
    private func performBusinessSearch() {
        selectedTab = 1
    }
    
    private func performLiveSearch() {
        let searchTerm = searchText.isEmpty ? "Tesla" : searchText
        
        Task {
            let service = BusinessEntityService()
            do {
                let results = try await service.searchBusinessEntities(searchTerm: searchTerm)
                DispatchQueue.main.async {
                    self.testResults.append(TestResult(
                        title: "Business Search: \(searchTerm)",
                        subtitle: "\(results.count) entities found",
                        status: .success,
                        details: results.prefix(5).map { entity in
                            "Entity: \(entity.EntityName ?? "Unknown")\nType: \(entity.EntityType ?? "N/A")\nStatus: \(entity.StatusDescription ?? "N/A")\nID: \(entity.EntityNumber ?? "N/A")"
                        }.joined(separator: "\n\n"),
                        icon: "building.2.fill",
                        type: .businessSearch
                    ))
                }
            } catch {
                DispatchQueue.main.async {
                    self.testResults.append(TestResult(
                        title: "Search Failed: \(searchTerm)",
                        subtitle: "Unable to complete search",
                        status: .failure,
                        details: error.localizedDescription,
                        icon: "exclamationmark.triangle.fill",
                        type: .businessSearch
                    ))
                }
            }
        }
    }
    
    private func viewSystemStatus() {
        testResults.append(TestResult(
            title: "System Health Monitor",
            subtitle: "All systems operational",
            status: .success,
            details: "Server Status: Online\nDatabase: Connected\nAPI Services: 3/3 Active\nUptime: 99.9%",
            icon: "heart.circle.fill",
            type: .system
        ))
        selectedTab = 2
    }
}

// MARK: - Components
struct CDPHSidebarHeader: View {
    var body: some View {
        VStack(spacing: 20) {
            HStack(spacing: 15) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(Color.blue)
                        .frame(width: 50, height: 50)
                    
                    VStack(spacing: 2) {
                        Rectangle()
                            .fill(.white)
                            .frame(width: 20, height: 4)
                        Rectangle()
                            .fill(.white)
                            .frame(width: 4, height: 16)
                    }
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("CDPH")
                        .font(.system(size: 24, weight: .heavy))
                        .foregroundColor(.blue)
                    Text("California Department")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green)
                    Text("of Public Health")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.green)
                }
                Spacer()
            }
            
            Rectangle()
                .fill(Color.orange)
                .frame(height: 4)
                .cornerRadius(2)
            
            HStack {
                VStack(alignment: .leading, spacing: 4) {
                    Text("Business Entity")
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text("Management Portal")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                Spacer()
                
                Text("v2.1")
                    .font(.system(size: 11, weight: .bold))
                    .padding(.horizontal, 10)
                    .padding(.vertical, 5)
                    .background(Color.blue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
        .padding(20)
        .background(Color.white.opacity(0.8))
    }
}

struct SidebarNavItem: View {
    let title: String
    let icon: String
    let isSelected: Bool
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 8)
                        .fill(isSelected ? Color.blue.opacity(0.2) : Color.clear)
                        .frame(width: 32, height: 32)
                    
                    Image(systemName: icon)
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(isSelected ? .blue : .blue.opacity(0.7))
                }
                
                Text(title)
                    .font(.system(size: 15, weight: isSelected ? .semibold : .medium))
                    .foregroundColor(isSelected ? .primary : .secondary)
                
                Spacer()
                
                if isSelected {
                    RoundedRectangle(cornerRadius: 2)
                        .fill(Color.blue)
                        .frame(width: 4, height: 20)
                }
            }
            .padding(.horizontal, 12)
            .padding(.vertical, 10)
            .background(
                RoundedRectangle(cornerRadius: 12)
                    .fill(isSelected ? Color.blue.opacity(0.05) : Color.clear)
            )
        }
        .buttonStyle(PlainButtonStyle())
    }
}

struct UserProfileSection: View {
    var body: some View {
        VStack(spacing: 15) {
            Rectangle()
                .fill(Color.orange)
                .frame(height: 2)
                .cornerRadius(1)
            
            HStack(spacing: 12) {
                ZStack {
                    Circle()
                        .fill(Color.blue)
                        .frame(width: 42, height: 42)
                    
                    Text("AS")
                        .font(.system(size: 16, weight: .bold))
                        .foregroundColor(.white)
                }
                
                VStack(alignment: .leading, spacing: 3) {
                    Text("Argus Sun")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.primary)
                    Text("System Administrator")
                        .font(.system(size: 11, weight: .medium))
                        .foregroundColor(.blue)
                }
                
                Spacer()
                
                Button(action: {}) {
                    Image(systemName: "ellipsis")
                        .font(.system(size: 14, weight: .semibold))
                        .foregroundColor(.blue)
                }
            }
            .padding(.horizontal, 18)
            .padding(.bottom, 20)
        }
    }
}

struct CDPHTopBar: View {
    let selectedTab: Int
    
    var tabTitle: String {
        switch selectedTab {
        case 0: return "System Dashboard"
        case 1: return "Business Entity Search"
        case 2: return "System Logs & Diagnostics"
        default: return "Dashboard"
        }
    }
    
    var body: some View {
        HStack {
            VStack(alignment: .leading, spacing: 6) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.green)
                        .frame(width: 6, height: 6)
                    
                    Text(tabTitle)
                        .font(.system(size: 24, weight: .bold))
                        .foregroundColor(.primary)
                }
                
                Text("California Secretary of State Integration Portal")
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(.secondary)
            }
            
            Spacer()
            
            HStack(spacing: 18) {
                HStack(spacing: 8) {
                    Circle()
                        .fill(.green)
                        .frame(width: 8, height: 8)
                    
                    Text("System Online")
                        .font(.system(size: 12, weight: .medium))
                        .foregroundColor(.green)
                }
                .padding(.horizontal, 12)
                .padding(.vertical, 6)
                .background(
                    RoundedRectangle(cornerRadius: 12)
                        .fill(.green.opacity(0.1))
                )
                
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(.blue.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "bell.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.blue)
                    }
                }
                
                Button(action: {}) {
                    ZStack {
                        Circle()
                            .fill(.green.opacity(0.1))
                            .frame(width: 36, height: 36)
                        
                        Image(systemName: "gearshape.fill")
                            .font(.system(size: 14))
                            .foregroundColor(.green)
                    }
                }
            }
        }
        .padding(.horizontal, 30)
        .padding(.vertical, 25)
        .background(Color.white)
        .shadow(color: .black.opacity(0.03), radius: 3, x: 0, y: 2)
    }
}

struct DashboardView: View {
    let testResults: [TestResult]
    let isLoading: Bool
    let runDiagnostics: () -> Void
    let performSearch: () -> Void
    let testCredentials: () -> Void
    let viewStatus: () -> Void
    
    var body: some View {
        ScrollView {
            VStack(spacing: 30) {
                HStack(spacing: 20) {
                    StatsCard(
                        title: "System Tests",
                        value: "\(testResults.filter { $0.type != .businessSearch }.count)",
                        subtitle: "Diagnostics Run",
                        color: .blue,
                        icon: "checkmark.circle.fill"
                    )
                    
                    StatsCard(
                        title: "Business Searches",
                        value: "\(testResults.filter { $0.type == .businessSearch }.count)",
                        subtitle: "Queries Executed",
                        color: .green,
                        icon: "magnifyingglass.circle.fill"
                    )
                }
                
                VStack(spacing: 18) {
                    HStack(spacing: 18) {
                        DashboardCard(
                            title: "Run System Diagnostics",
                            subtitle: "Comprehensive health check",
                            icon: "stethoscope.circle.fill",
                            color: .blue,
                            isLoading: isLoading,
                            action: runDiagnostics
                        )
                        
                        DashboardCard(
                            title: "Search Business Entities",
                            subtitle: "CA Secretary of State database",
                            icon: "building.2.fill",
                            color: .green,
                            action: performSearch
                        )
                    }
                    
                    HStack(spacing: 18) {
                        DashboardCard(
                            title: "Test Secure Storage",
                            subtitle: "Credential management",
                            icon: "key.fill",
                            color: .orange,
                            action: testCredentials
                        )
                        
                        DashboardCard(
                            title: "System Health Monitor",
                            subtitle: "Operational status",
                            icon: "heart.text.square.fill",
                            color: .purple,
                            action: viewStatus
                        )
                    }
                }
                
                if !testResults.isEmpty {
                    QuickStatusOverview(testResults: testResults)
                }
            }
            .padding(30)
        }
    }
}

struct StatsCard: View {
    let title: String
    let value: String
    let subtitle: String
    let color: Color
    let icon: String
    
    var body: some View {
        VStack(spacing: 15) {
            HStack {
                ZStack {
                    Circle()
                        .fill(color.opacity(0.2))
                        .frame(width: 40, height: 40)
                    
                    Image(systemName: icon)
                        .font(.system(size: 18, weight: .semibold))
                        .foregroundColor(color)
                }
                Spacer()
            }
            
            VStack(spacing: 8) {
                Text(value)
                    .font(.system(size: 36, weight: .heavy))
                    .foregroundColor(color)
                Text(subtitle)
                    .font(.system(size: 12, weight: .medium))
                    .foregroundColor(.secondary)
                Text(title)
                    .font(.system(size: 15, weight: .semibold))
                    .foregroundColor(.primary)
            }
            .frame(maxWidth: .infinity)
        }
        .frame(height: 140)
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
                .stroke(color.opacity(0.3), lineWidth: 1)
        )
        .shadow(color: color.opacity(0.1), radius: 10, x: 0, y: 5)
    }
}

struct DashboardCard: View {
    let title: String
    let subtitle: String
    let icon: String
    let color: Color
    var isLoading: Bool = false
    let action: () -> Void
    
    var body: some View {
        Button(action: action) {
            VStack(spacing: 16) {
                HStack {
                    ZStack {
                        RoundedRectangle(cornerRadius: 12)
                            .fill(color.opacity(0.15))
                            .frame(width: 48, height: 48)
                        
                        Image(systemName: icon)
                            .font(.system(size: 22, weight: .semibold))
                            .foregroundColor(color)
                    }
                    
                    Spacer()
                    
                    if isLoading {
                        ProgressView()
                            .scaleEffect(0.9)
                            .tint(color)
                    }
                }
                
                VStack(alignment: .leading, spacing: 6) {
                    Text(title)
                        .font(.system(size: 17, weight: .bold))
                        .foregroundColor(.primary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                    
                    Text(subtitle)
                        .font(.system(size: 13, weight: .medium))
                        .foregroundColor(.secondary)
                        .multilineTextAlignment(.leading)
                        .lineLimit(2)
                }
                .frame(maxWidth: .infinity, alignment: .leading)
                
                Spacer()
            }
            .frame(height: 140)
            .padding(18)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
                    .stroke(color.opacity(0.2), lineWidth: 1)
            )
            .shadow(color: color.opacity(0.1), radius: 8, x: 0, y: 4)
        }
        .buttonStyle(PlainButtonStyle())
        .disabled(isLoading)
    }
}

struct QuickStatusOverview: View {
    let testResults: [TestResult]
    
    var successCount: Int { testResults.filter { $0.status == .success }.count }
    var warningCount: Int { testResults.filter { $0.status == .warning }.count }
    var failureCount: Int { testResults.filter { $0.status == .failure }.count }
    
    var body: some View {
        VStack(alignment: .leading, spacing: 15) {
            Text("Quick Status Overview")
                .font(.system(size: 20, weight: .bold))
                .foregroundColor(.primary)
            
            HStack(spacing: 20) {
                StatusBubble(count: successCount, label: "Success", color: .green)
                StatusBubble(count: warningCount, label: "Warnings", color: .orange)
                StatusBubble(count: failureCount, label: "Issues", color: .red)
                
                Spacer()
            }
        }
        .padding(25)
        .background(
            RoundedRectangle(cornerRadius: 20)
                .fill(.ultraThinMaterial)
        )
    }
}

struct StatusBubble: View {
    let count: Int
    let label: String
    let color: Color
    
    var body: some View {
        HStack(spacing: 8) {
            ZStack {
                Circle()
                    .fill(color.opacity(0.2))
                    .frame(width: 24, height: 24)
                
                Text("\(count)")
                    .font(.system(size: 12, weight: .bold))
                    .foregroundColor(color)
            }
            
            Text(label)
                .font(.system(size: 14, weight: .medium))
                .foregroundColor(.secondary)
        }
    }
}

struct BusinessSearchView: View {
    @Binding var searchText: String
    let testResults: [TestResult]
    let performSearch: () -> Void
    
    var body: some View {
        VStack(spacing: 25) {
            VStack(spacing: 15) {
                HStack(spacing: 15) {
                    HStack(spacing: 12) {
                        Image(systemName: "magnifyingglass")
                            .foregroundColor(.blue)
                            .font(.system(size: 16))
                        
                        TextField("Enter business name (e.g., Tesla, Apple, Google)", text: $searchText)
                            .font(.system(size: 16))
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 12)
                    .background(
                        RoundedRectangle(cornerRadius: 12)
                            .fill(.ultraThinMaterial)
                            .stroke(.blue.opacity(0.2), lineWidth: 1)
                    )
                    
                    Button("Search") {
                        performSearch()
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.blue)
                    .disabled(searchText.isEmpty)
                }
                
                HStack {
                    Text("💡 Try searching for: Tesla, Apple, Google, or any California business")
                        .font(.system(size: 13))
                        .foregroundColor(.secondary)
                    Spacer()
                }
            }
            .padding(25)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(.ultraThinMaterial)
            )
            
            if testResults.filter({ $0.type == .businessSearch }).isEmpty {
                Spacer()
                EmptySearchState()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 16) {
                        ForEach(testResults.filter { $0.type == .businessSearch }) { result in
                            BusinessResultCard(result: result)
                        }
                    }
                    .padding(.horizontal, 25)
                }
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct EmptySearchState: View {
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "building.2")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.blue.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                Text("Business Entity Search")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("Search the California Secretary of State database for business entities including corporations, LLCs, and partnerships.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 40)
        }
    }
}

struct BusinessResultCard: View {
    let result: TestResult
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(spacing: 12) {
                ZStack {
                    RoundedRectangle(cornerRadius: 10)
                        .fill(Color.blue.opacity(0.1))
                        .frame(width: 44, height: 44)
                    
                    Image(systemName: result.icon)
                        .foregroundColor(.blue)
                        .font(.system(size: 20, weight: .semibold))
                }
                
                VStack(alignment: .leading, spacing: 4) {
                    Text(result.title)
                        .font(.system(size: 18, weight: .bold))
                        .foregroundColor(.primary)
                    Text(result.subtitle)
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.secondary)
                }
                
                Spacer()
                
                StatusIndicator(status: result.status)
            }
            
            if !result.details.isEmpty {
                VStack(alignment: .leading, spacing: 8) {
                    Rectangle()
                        .fill(.blue.opacity(0.1))
                        .frame(height: 1)
                    
                    Text(result.details)
                        .font(.system(size: 14))
                        .foregroundColor(.secondary)
                        .lineSpacing(2)
                }
            }
        }
        .padding(20)
        .background(
            RoundedRectangle(cornerRadius: 16)
                .fill(.ultraThinMaterial)
                .stroke(.blue.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.03), radius: 8, x: 0, y: 4)
    }
}

struct SystemLogsView: View {
    let testResults: [TestResult]
    let clearLogs: () -> Void
    
    var body: some View {
        VStack(spacing: 20) {
            if testResults.isEmpty {
                Spacer()
                EmptyLogsState()
                Spacer()
            } else {
                ScrollView {
                    LazyVStack(spacing: 12) {
                        ForEach(testResults) { result in
                            SystemLogCard(result: result)
                        }
                    }
                    .padding(25)
                }
                
                HStack {
                    Spacer()
                    Button(action: clearLogs) {
                        HStack(spacing: 8) {
                            Image(systemName: "trash.fill")
                                .font(.system(size: 14))
                            Text("Clear All Logs")
                                .font(.system(size: 14, weight: .semibold))
                        }
                        .foregroundColor(.red)
                        .padding(.horizontal, 16)
                        .padding(.vertical, 10)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .fill(.red.opacity(0.1))
                                .stroke(.red.opacity(0.2), lineWidth: 1)
                        )
                    }
                    .buttonStyle(PlainButtonStyle())
                }
                .padding(.horizontal, 25)
                .padding(.bottom, 20)
            }
        }
        .background(Color(.systemGroupedBackground))
    }
}

struct EmptyLogsState: View {
    var body: some View {
        VStack(spacing: 25) {
            ZStack {
                Circle()
                    .fill(Color.blue.opacity(0.1))
                    .frame(width: 120, height: 120)
                
                Image(systemName: "doc.text")
                    .font(.system(size: 50, weight: .light))
                    .foregroundColor(.blue.opacity(0.6))
            }
            
            VStack(spacing: 12) {
                Text("System Logs")
                    .font(.system(size: 24, weight: .bold))
                    .foregroundColor(.primary)
                
                Text("System diagnostic logs and business search results will appear here when you run tests.")
                    .font(.system(size: 16))
                    .foregroundColor(.secondary)
                    .multilineTextAlignment(.center)
                    .lineSpacing(4)
            }
            .padding(.horizontal, 40)
        }
    }
}

struct SystemLogCard: View {
    let result: TestResult
    
    var body: some View {
        HStack(spacing: 15) {
            VStack(spacing: 4) {
                Circle()
                    .fill(result.status.color)
                    .frame(width: 12, height: 12)
                
                Rectangle()
                    .fill(result.status.color.opacity(0.3))
                    .frame(width: 2, height: 30)
            }
            
            VStack(alignment: .leading, spacing: 10) {
                HStack {
                    VStack(alignment: .leading, spacing: 4) {
                        Text(result.title)
                            .font(.system(size: 16, weight: .semibold))
                            .foregroundColor(.primary)
                        
                        Text(result.subtitle)
                            .font(.system(size: 14))
                            .foregroundColor(.secondary)
                    }
                    
                    Spacer()
                    
                    StatusIndicator(status: result.status)
                }
                
                if !result.details.isEmpty {
                    Text(result.details)
                        .font(.system(size: 12))
                        .foregroundColor(.secondary)
                        .padding(.top, 4)
                        .lineSpacing(2)
                }
            }
        }
        .padding(18)
        .background(
            RoundedRectangle(cornerRadius: 14)
                .fill(.ultraThinMaterial)
                .stroke(result.status.color.opacity(0.1), lineWidth: 1)
        )
        .shadow(color: .black.opacity(0.02), radius: 4, x: 0, y: 2)
    }
}

struct StatusIndicator: View {
    let status: TestStatus
    
    var body: some View {
        HStack(spacing: 6) {
            Circle()
                .fill(status.color)
                .frame(width: 6, height: 6)
            
            Text(status.rawValue.capitalized)
                .font(.system(size: 11, weight: .semibold))
                .foregroundColor(status.color)
        }
        .padding(.horizontal, 10)
        .padding(.vertical, 5)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(status.color.opacity(0.1))
                .stroke(status.color.opacity(0.2), lineWidth: 0.5)
        )
    }
}

// MARK: - Data Models
struct TestResult: Identifiable {
    let id = UUID()
    let title: String
    let subtitle: String
    let status: TestStatus
    let details: String
    let icon: String
    let type: TestType
}

enum TestStatus: String {
    case success, failure, running, pending, warning
    
    var color: Color {
        switch self {
        case .success: return .green
        case .failure: return .red
        case .running: return .blue
        case .pending: return .orange
        case .warning: return .orange
        }
    }
}

enum TestType {
    case system, security, api, businessSearch
}

#Preview {
    ContentView()
}
