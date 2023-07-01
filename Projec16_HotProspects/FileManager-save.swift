//
//  FileManager-save.swift
//  Projec16_HotProspects
//
//  Created by admin on 30/06/2023.
//

import Foundation

extension FileManager {
    static var documentsDirectory: URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]

    }
    func getDocumentsDirectory() -> URL {
        let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return path[0]

    }

    func writeData(text message: [Prospect]) -> Void {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: true)
                .appendingPathExtension("pastData.json")
            
            try JSONEncoder().encode(message)
                .write(to: fileURL)
        } catch {
            print("Error wrighting data")
            print(error.localizedDescription)
        }
    }
    
    func getData() -> [Prospect] {
        do {
            let fileURL = try FileManager.default
                .url(for: .documentDirectory, in: .userDomainMask, appropriateFor: nil, create: false)
                .appendingPathExtension("pastData.json")
            
            let data = try Data(contentsOf: fileURL)
            let decoded = try JSONDecoder().decode([Prospect].self, from: data)
            return decoded
            
        } catch {
            print("Error reading data")
            print(error.localizedDescription)
            return []
        }
    }
}
