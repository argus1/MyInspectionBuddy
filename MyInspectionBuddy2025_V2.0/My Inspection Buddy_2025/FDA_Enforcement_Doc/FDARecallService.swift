import Foundation
import Combine

class FDARecallService {
    
    static let shared = FDARecallService()
    private let baseURLString = "https://api.fda.gov/device/enforcement.json"
    
    private let dateFormatter: DateFormatter = {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyyMMdd"
        return formatter
    }()
    
    func searchRecalls(firm: String?, number: String?, classification: String?, fromDate: Date?, toDate: Date?) -> AnyPublisher<[FDAEnforcementRecord], APIError> {
        
        guard var components = URLComponents(string: baseURLString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var searchTerms: [String] = []
        if let firm = firm, !firm.trimmingCharacters(in: .whitespaces).isEmpty { searchTerms.append("recalling_firm:\"\(firm)\"") }
        if let number = number, !number.trimmingCharacters(in: .whitespaces).isEmpty { searchTerms.append("recall_number:\"\(number)\"") }
        if let classification = classification, classification != "Any" { searchTerms.append("classification:\"\(classification)\"") }
        if let fromDate = fromDate, let toDate = toDate {
            let fromDateString = dateFormatter.string(from: fromDate)
            let toDateString = dateFormatter.string(from: toDate)
            searchTerms.append("report_date:[\(fromDateString)+TO+\(toDateString)]")
        }
        
        guard !searchTerms.isEmpty else {
            return Fail(error: APIError.apiError("Please provide at least one search criterion.")).eraseToAnyPublisher()
        }
        
        components.queryItems = [
            URLQueryItem(name: "search", value: searchTerms.joined(separator: " AND ")),
            URLQueryItem(name: "limit", value: "100")
        ]
        
        guard let url = components.url else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        return URLSession.shared.dataTaskPublisher(for: url)
            .map(\.data)
            // The JSON is decoded into the same response type
            .decode(type: FDAEnforcementResponse.self, decoder: JSONDecoder())
            .tryMap { response in
                // Check if the API returned a specific error message
                if let apiError = response.error {
                    // Use the message from the renamed FDAErrorPayload
                    throw APIError.apiError(apiError.message)
                }
                return response.results ?? []
            }
            .mapError { error in
                return error as? APIError ?? APIError.decodingFailed(error)
            }
            .eraseToAnyPublisher()
    }
}

