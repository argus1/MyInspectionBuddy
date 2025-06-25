
import Foundation
import Combine

enum APIError: Error {
    case invalidURL
    case requestFailed(Error)
    case decodingFailed(Error)
    case noResults
}

class FDARecallService {
    
    static let shared = FDARecallService()
    private let baseURLString = "https://api.fda.gov/device/enforcement.json"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    func searchRecalls(firm: String?, number: String?, classification: String?, fromDate: Date?, toDate: Date?) -> AnyPublisher<[Recall], APIError> {
        
        guard var components = URLComponents(string: baseURLString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var searchTerms: [String] = []
        
        if let firm = firm, !firm.trimmingCharacters(in: .whitespaces).isEmpty {
            searchTerms.append("recalling_firm:\"\(firm)\"")
        }
        
        if let number = number, !number.trimmingCharacters(in: .whitespaces).isEmpty {
            searchTerms.append("recall_number:\"\(number)\"")
        }
        
        if let classification = classification, classification != "Any" {
            searchTerms.append("classification:\"\(classification)\"")
        }
        
        if let fromDate = fromDate, let toDate = toDate {
            let fromDateString = dateFormatter.string(from: fromDate)
            let toDateString = dateFormatter.string(from: toDate)
            searchTerms.append("report_date:[\(fromDateString)+TO+\(toDateString)]")
        }
        
        guard !searchTerms.isEmpty else {
            return Fail(error: APIError.noResults).eraseToAnyPublisher()
        }
        
        let searchQuery = searchTerms.joined(separator: " AND ")
        
        // Set the query items on the URLComponents object.
        components.queryItems = [
            URLQueryItem(name: "search", value: searchQuery),
            URLQueryItem(name: "limit", value: "100")
        ]
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        print("Requesting URL: \(url)")
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .mapError { error in
                print("Network request failed with error: \(error)")
                return APIError.requestFailed(error)
            }
            .map(\.data)
            .decode(type: RecallAPIResponse.self, decoder: JSONDecoder())
            .mapError { error in
                print("JSON decoding failed with error: \(error)")
                return APIError.decodingFailed(error)
            }
            .map(\.results)
            .eraseToAnyPublisher()
    }
}
