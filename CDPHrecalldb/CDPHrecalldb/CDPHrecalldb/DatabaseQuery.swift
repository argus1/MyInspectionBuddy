//
//  DatabaseQuery.swift
//  CDPHrecalldb
//
//  Created by Nicole Tang on 6/25/25.
//

import Foundation
import SQLite3

struct DatabaseQuery {

    static func fetchAllRecalls() -> [Recall] {
        var recalls: [Recall] = []
        var db: OpaquePointer?

        let dbPath = "/Users/nicoletang/Desktop/CDPH/MyInspectionBuddy/CDPHrecallDB/CDPHrecalldb/CDPHrecalldb/device_recalls.db"

        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("❌ Failed to open database.")
            return []
        }

        defer { sqlite3_close(db) }

        let query = "SELECT id, item, month, year, recall_url FROM recalls"
        var stmt: OpaquePointer?

        if sqlite3_prepare_v2(db, query, -1, &stmt, nil) == SQLITE_OK {
            var count = 0
            while sqlite3_step(stmt) == SQLITE_ROW {
                let id = Int(sqlite3_column_int(stmt, 0))
                let item = String(cString: sqlite3_column_text(stmt, 1))
                let month = String(cString: sqlite3_column_text(stmt, 2))
                let year = String(cString: sqlite3_column_text(stmt, 3))
                let url = String(cString: sqlite3_column_text(stmt, 4))

                recalls.append(Recall(id: id, item: item, month: month, year: year, recallURL: url))
                count += 1
            }
            sqlite3_finalize(stmt)
            print("✅ query made 1 — \(count) total rows")
        } else {
            print("❌ Failed to prepare fetchAllRecalls query.")
        }

        return recalls
    }

    static func search(month: String, year: String, company: String, device: String) -> [[String: String]] {
        var results: [[String: String]] = []
        var db: OpaquePointer?

        let dbPath = "/Users/nicoletang/Desktop/CDPH/MyInspectionBuddy/CDPHrecallDB/CDPHrecalldb/CDPHrecalldb/device_recalls.db"

        if sqlite3_open(dbPath, &db) != SQLITE_OK {
            print("❌ Failed to open database.")
            return []
        }

        defer { sqlite3_close(db) }

        let cleanMonth = month.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanYear = year.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanCompany = company.trimmingCharacters(in: .whitespacesAndNewlines)
        let cleanDevice = device.trimmingCharacters(in: .whitespacesAndNewlines)

        var conditions: [String] = []

        if !cleanMonth.isEmpty {
            conditions.append("month = '\(cleanMonth)'")
        }
        if !cleanYear.isEmpty {
            conditions.append("year = '\(cleanYear)'")
        }
        if !cleanCompany.isEmpty {
            conditions.append("LOWER(item) LIKE '%\(cleanCompany.lowercased())%'")
        }
        if !cleanDevice.isEmpty {
            conditions.append("LOWER(item) LIKE '%\(cleanDevice.lowercased())%'")
        }

        let whereClause = conditions.isEmpty ? "" : " WHERE " + conditions.joined(separator: " AND ")
        let finalQuery = "SELECT item, month, year, recall_url FROM recalls" + whereClause

        print("📋 SQL Query: \(finalQuery)")

        var stmt: OpaquePointer?
        if sqlite3_prepare_v2(db, finalQuery, -1, &stmt, nil) == SQLITE_OK {
            var rowCount = 0
            while sqlite3_step(stmt) == SQLITE_ROW {
                let item = String(cString: sqlite3_column_text(stmt, 0))
                let month = String(cString: sqlite3_column_text(stmt, 1))
                let year = String(cString: sqlite3_column_text(stmt, 2))
                let url = String(cString: sqlite3_column_text(stmt, 3))

                results.append([
                    "item": item,
                    "month": month,
                    "year": year,
                    "recall_url": url
                ])
                rowCount += 1
            }

            sqlite3_finalize(stmt)
            print("✅ query complete — \(rowCount) matches found")
        } else {
            print("❌ SQL error: \(String(cString: sqlite3_errmsg(db)))")
        }

        return results
    }
}
