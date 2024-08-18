//
//  SearchController.swift
//  Ledger
//
//  Created by Avi Sanchez on 8/7/24.
//

import Foundation
import SwiftUI

@Observable
class SearchController {
    
    var searchResults = [CDAccountEntry]()
    
    var searchSuggestions = [String]()
    
    init() { }
    
    enum SearchScopes {
        case all
        case date
        case notes
        case debitAmount
        case creditAmount
        case posted
    }
    
    func search(_ input: String, in scopes: [SearchScopes] = [.all]) {
        let acceptedVariables: Set<String> = ["date", "notes", ""]
        
        let dict: Dictionary<String, Set<String>> = ["date": [">", "<"]]
        // parse predicate
        if input.hasPrefix("#") {
            input.split(separator: "")
        }
        
//        switch scope {
//        case .date, .all:
//            let formatter = DateFormatter(dateFormat: "MM/dd/YYYY")
//            formatter.date(from: <#T##String#>)
//            print("date")
//        case .notes, .all:
//            print("notes")
//        case .:
//            print("hi")
//        }
    }
    
    func updateSuggestions(from oldInput: String, to newInput: String) {
        
        guard let fetchedObjects = FRC.shared.fetchedObjects else { return }
        
        let oldInput = oldInput.lowercased()
        let newInput = newInput.lowercased()
        
        if !oldInput.isEmpty && newInput.hasPrefix(oldInput) {
            searchSuggestions = searchSuggestions.filter {
                $0.contains(newInput)
            }
            return
        }
        
        searchSuggestions = []
        
        var uniqueLowercasedNotes = Set<String>()
        
        fetchedObjects.forEach { entry in
            
            let lowercasedNote = entry.notes.lowercased()
            
            if lowercasedNote.contains(newInput),
               uniqueLowercasedNotes.insert(lowercasedNote).inserted {
                searchSuggestions.append(lowercasedNote)
            }
        }
    }
    
    func search(using searchTerm: String) {
        var uniqueNotes: Set<String> = []
        
        let results = FRC.shared.fetchedObjects?.filter({ entry in
            let lowercasedNote = entry.notes.lowercased()
            
            if !uniqueNotes.contains(lowercasedNote) && lowercasedNote.contains(searchTerm.lowercased()) {
                uniqueNotes.insert(lowercasedNote)
                return true
            }
            return false
        })
        
        self.searchResults = results ?? []
    }
    
    func search(using predicate: Predicate<CDAccountEntry>) {
        let results = try? FRC.shared.fetchedObjects?.filter(predicate)
        self.searchResults = results ?? []
    }
    
    func submitSearch(_ account: CDAccount, notes: String) {
        let predicate = NSPredicate(format: "owner == %@ && notes_ MATCHES[c] %@", account, notes)
        FRC.shared.updateFetch(using: predicate)
    }
}
