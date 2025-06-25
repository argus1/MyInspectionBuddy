import SwiftUI

struct Service: Identifiable {
    let id = UUID()
    let name: String
    let iconName: String
    let color: Color
}

//Can search icon name from "SF Symbol" APP
let services: [Service] = [
    .init(name: "FDA Enforcement", iconName: "doc.text.magnifyingglass", color: .blue),
    .init(name: "510(k)", iconName: "doc.badge.gearshape", color: .cyan),
    .init(name: "MAUDE", iconName: "exclamationmark.triangle.fill", color: .orange),
    .init(name: "FDA Warning Letters", iconName: "envelope.open.fill", color: .red),
    .init(name: "CDPH Medical Device Safety Page", iconName: "safari.fill", color: .teal),
    .init(name: "Historical Docs", iconName: "archivebox.fill", color: .purple),
    .init(name: "CA Business Search", iconName: "building.2.fill", color: .brown),
    .init(name: "DA Office Contacts", iconName: "person.2.fill", color: .indigo),
    .init(name: "SAP Travel Info", iconName: "airplane", color: .green),
    .init(name: "License Search", iconName: "person.text.rectangle.fill", color: .pink),
    .init(name: "Privacy Policy", iconName: "lock.shield.fill", color: .gray),
    .init(name: "Help", iconName: "questionmark.circle.fill", color: .mint)
]

struct HomePageView: View {

    let columns: [GridItem] = [
        GridItem(.adaptive(minimum: 200))
    ]

    var body: some View {
            NavigationView {
                ScrollView {
                    VStack(spacing: 24) {
                        Button(action: {
                            print("Device Detection Tapped")
                        }) {
                            HStack {
                                Image(systemName: "camera.viewfinder")
                                    .font(.largeTitle)
                                Text("Device Detection")
                                    .font(.title)
                                    .fontWeight(.bold)
                            }
                            .frame(maxWidth: .infinity, minHeight: 80)
                            .padding()
                            .background(Color.accentColor)
                            .foregroundColor(.white)
                            .cornerRadius(20)
                            .shadow(radius: 5)
                        }
                        .padding(.horizontal)

                        LazyVGrid(columns: columns, spacing: 20) {
                            ForEach(services) { service in
                                ServiceTile(service: service)
                            }
                        }
                        .padding()
                    }
                    .padding(.top)
                }
                .background(Color(.systemGroupedBackground))
                .navigationTitle("My Inspection Buddy")
            }
            
            .navigationViewStyle(StackNavigationViewStyle())
        }
}

struct ServiceTile: View {
    let service: Service
    
    @ViewBuilder
    private var tileContent: some View {
        VStack {
            Image(systemName: "circle.fill")
                .font(.system(size: 60))
                .foregroundColor(service.color.opacity(0.2))
                .overlay(
                    Image(systemName: service.iconName)
                        .font(.title)
                        .foregroundColor(service.color)
                )
            
            Spacer()
            
            Text(service.name)
                .font(.headline)
                .fontWeight(.medium)
                .foregroundColor(.primary)
                .multilineTextAlignment(.center)
        }
        .padding()
        .frame(height: 160)
        .frame(maxWidth: .infinity)
        .background(Color(.secondarySystemGroupedBackground))
        .cornerRadius(20)
        .shadow(color: Color.black.opacity(0.05), radius: 5, x: 0, y: 5)
    }
    
    //link to CDPH safety page
    var body: some View {
        if service.name == "CDPH Medical Device Safety Page" {
            Link(destination: URL(string: "https://www.cdph.ca.gov/Programs/CEH/DFDCS/Pages/FDBPrograms/DeviceRecalls.aspx")!) {
                tileContent
            }
            .buttonStyle(PlainButtonStyle())
        } else {
            NavigationLink(destination: destinationView(for: service)) {
                tileContent
            }
            .buttonStyle(PlainButtonStyle())
        }
    }
    
    @ViewBuilder
    private func destinationView(for service: Service) -> some View {
        if service.name == "FDA Enforcement" {
            FDASearchView()
        } else {
            Text("Placeholder view for \(service.name)")
                .navigationTitle(service.name)
        }
    }
}

struct HomePageView_Previews: PreviewProvider {
    static var previews: some View {
        HomePageView()
            .previewDevice("iPad Air (5th generation)")
    }
}

