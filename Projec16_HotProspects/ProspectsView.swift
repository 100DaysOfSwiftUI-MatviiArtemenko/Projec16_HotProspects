//
//  SwiftUIView.swift
//  Projec16_HotProspects
//
//  Created by admin on 07/03/2023.
//

import CodeScanner
import SwiftUI
import UserNotifications

struct ProspectsView: View {
    enum FilterType {
        case none
        case contacted
        case uncontacted
    }
    enum SortType: String, CaseIterable {
        case mostRecent
        case byName
    }
    
    @EnvironmentObject var prospects: Prospects
    
    @State private var isShowingScanner = false
    let filter: FilterType
    @State var sort: SortType = .mostRecent
    var body: some View {
        NavigationView {
            List {
                ForEach(filteredProspects) { prospect in
                    HStack {
                        VStack(alignment: .leading) {
                            Text(prospect.name)
                                .font(.headline)
                            Text(prospect.emailAddress)
                                .foregroundColor(.secondary)
                                .font(.caption)
                        }
                        Spacer()
                        Image(systemName: prospect.isContacted ? "person.crop.circle.fill.badge.checkmark" : "person.crop.circle.badge.xmark")
                            .foregroundColor(prospect.isContacted ? .green : .secondary.opacity(0.4))
                    }
                    .swipeActions {
                        if prospect.isContacted {
                            Button {
                                withAnimation {
                                    prospects.toggle(prospect)
                                }
                            } label: {
                                Label("Mark Uncontacted", systemImage: "person.crop.circle.badge.xmark")
                            }
                            .tint(.blue)
                        } else {
                            Button {
                                withAnimation {
                                    prospects.toggle(prospect)
                                }
                            } label: {
                                Label("Mark Contacted", systemImage: "person.crop.circle.fill.badge.checkmark")
                            }
                            .tint(.green)
                            
                            Button {
                                addNotification(for: prospect)
                            } label: {
                                Label("Remind me", systemImage: "bell")
                            }
                            .tint(.yellow)
                        }
                    }
                    
                }
                
            }
            .navigationTitle(title)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button {
                        withAnimation {
                            if sort == .byName {
                                sort = .mostRecent
                            } else {
                                sort = .byName
                            }
                        }
                        
                    } label: {
                        Label {
                            Text(sort == .byName ? "by name" : "recent")
                        } icon: {
                            Image(systemName: sort == .byName ? "a.circle" : "chevron.up.circle")
                        }

                    }
                }
                ToolbarItem {
                    Button {
                        isShowingScanner = true
                    } label: {
                        Label("Scan", systemImage: "qrcode.viewfinder")
                    }
                }
                
            }
            .sheet(isPresented: $isShowingScanner) {
                CodeScannerView(codeTypes: [.qr], simulatedData: "Matvii Artemenko\nartemenko.box@gmail.com", completion: handleScan)
            }
        }
        .toolbar {
            
        }
    }
    
    var title: String {
        switch filter {
        case .none:
            return "Everyone"
        case .contacted:
            return "Contacted people"
        case .uncontacted:
            return "Uncontacted people"
        }
    }
    
    var filteredProspects: [Prospect] {
        switch sort {
        case .mostRecent:
            switch filter {
            case .none:
                return prospects.people
                
            case .contacted:
                return prospects.people.filter { $0.isContacted }
                
            case .uncontacted:
                return prospects.people.filter { !$0.isContacted }
            }
        case .byName:
            switch filter {
            case .none:
                return prospects.people.sorted { $0.name < $1.name }
                
            case .contacted:
                return prospects.people.filter { $0.isContacted }.sorted { $0.name < $1.name }
                
            case .uncontacted:
                return prospects.people.filter { !$0.isContacted }.sorted { $0.name < $1.name }
            }
        }
    }
    
    func handleScan(result: Result<ScanResult, ScanError>) {
        isShowingScanner = false
        
        switch result {
        case .success(let success):
            let details = success.string.components(separatedBy: "\n")
            guard details.count == 2 else {
                return
            }
            
            let person = Prospect()
            person.name = details[0]
            person.emailAddress = details[1]
            prospects.add(person)
            
        case .failure(let error):
            print("failure scanind QR code: \(error.localizedDescription)")
        }
    }
    
    func addNotification(for prospect: Prospect) {
        let center = UNUserNotificationCenter.current()
        
        let addRequest = {
            let content = UNMutableNotificationContent()
            content.title = "Contact \(prospect.name)"
            content.subtitle = prospect.emailAddress
            content.sound = .default
            
            var dateComponents = DateComponents()
            dateComponents.hour = 9
            
            let trigger = UNTimeIntervalNotificationTrigger(timeInterval: 10, repeats: false)
            
            let request = UNNotificationRequest(identifier: UUID().uuidString, content: content, trigger: trigger)
            center.add(request)
        }
        
        center.getNotificationSettings { settings in
            if settings.authorizationStatus == .authorized {
                addRequest()
            } else {
                center.requestAuthorization(options: [.sound, .alert, .badge]) { success, _ in
                    if success {
                        addRequest()
                    } else {
                        print("d`oh!")
                    }
                }
            }
        }
    }
}

struct ProspectsView_Previews: PreviewProvider {
    static var previews: some View {
        ProspectsView(filter: .none, sort: .mostRecent)
            .environmentObject(Prospects())
    }
}
