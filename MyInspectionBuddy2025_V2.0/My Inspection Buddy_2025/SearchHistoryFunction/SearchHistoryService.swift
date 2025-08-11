//
//  SearchHistoryService.swift
//  My Inspection Buddy_MergeV1.0
//
//  Created by Rae Wang on 8/11/25.
//
import Foundation

class SearchHistoryService {
    
    private static func historyKey(for searchType: String) -> String { "history_\(searchType)" }
    
    static func getHistory(for searchType: String) -> [HistoryItem] {
        let key = historyKey(for: searchType)
        guard let data = UserDefaults.standard.data(forKey: key) else { return [] }
        if let history = try? JSONDecoder().decode([HistoryItem].self, from: data) {
            let thirtyDaysAgo = Calendar.current.date(byAdding: .day, value: -30, to: Date()) ?? Date()
            return history.filter { $0.createdAt > thirtyDaysAgo }
        }
        return []
    }
    
    private static func saveHistory(for searchType: String, history: [HistoryItem]) {
        let key = historyKey(for: searchType)
        if let data = try? JSONEncoder().encode(history) {
            UserDefaults.standard.set(data, forKey: key)
        }
    }
    
    static func saveSearch(for searchType: String, item: HistoryItem) {
        var history = getHistory(for: searchType)
        history.removeAll { $0.searchTerm.lowercased() == item.searchTerm.lowercased() && $0.docType == item.docType }
        history.insert(item, at: 0)
        
        if history.count > 10 {
            history = Array(history.prefix(10))
        }
        saveHistory(for: searchType, history: history)
    }
    
    static func clearHistory(for searchType: String) {
        let key = historyKey(for: searchType)
        UserDefaults.standard.removeObject(forKey: key)
    }
}
