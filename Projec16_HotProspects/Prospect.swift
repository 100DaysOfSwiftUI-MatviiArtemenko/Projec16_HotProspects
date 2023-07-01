//
//  Prospect.swift
//  Projec16_HotProspects
//
//  Created by admin on 07/03/2023.
//

import Foundation

class Prospect: Identifiable, Codable {
    var id = UUID()
    var name = "Anonymus"
    var emailAddress = ""
    var isContacted = false
}

@MainActor class Prospects: ObservableObject {
    @Published private(set) var people: [Prospect]
    let saveKey = "SavedData"

    init() {
        people = FileManager.default.getData()
            
    }

    func add(_ prospect: Prospect) {
        FileManager.default.writeData(text: people)
        people.insert(prospect, at: 0)
    }
    
    func delete(at index: IndexSet) {
        people.remove(atOffsets: index)
        FileManager.default.writeData(text: people)

    }

    func toggle(_ prospect: Prospect) {
        objectWillChange.send()
        FileManager.default.writeData(text: people)
        prospect.isContacted.toggle()
    }
}
