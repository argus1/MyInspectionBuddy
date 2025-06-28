import Foundation
import Combine

class MaudeAPIService {
    static let shared = MaudeAPIService()
    
    private let baseURLString = "http://172.20.10.9:80/maude"

    struct RequestBody: Codable {
        let deviceName: String
        let fromDate: String
        let toDate: String
    }
    
    func searchMaudeEvents(deviceName: String, fromDate: Date, toDate: Date) -> AnyPublisher<[MaudeEvent], APIError> {
        
        guard let url = URL(string: baseURLString) else {
            return Fail(error: APIError.invalidURL).eraseToAnyPublisher()
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = "yyyy-MM-dd"
        
        let body = RequestBody(
            deviceName: deviceName,
            fromDate: dateFormatter.string(from: fromDate),
            toDate: dateFormatter.string(from: toDate)
        )
        
        do {
            request.httpBody = try JSONEncoder().encode(body)
        } catch {
            // The return statement is now active. If encoding fails, the app gets an error.
            return Fail(error: APIError.encodingFailed(error)).eraseToAnyPublisher()
        }

        print("Requesting MAUDE URL: \(url)")
        
        return URLSession.shared.dataTaskPublisher(for: request)
            .map(\.data)
            .decode(type: MaudeAPIResponse.self, decoder: JSONDecoder())
            .map(\.results)
            .mapError { error -> APIError in
                if let decodingError = error as? DecodingError {
                    print("Decoding Error: \(decodingError)")
                    return .decodingFailed(decodingError)
                } else {
                    return .requestFailed(error)
                }
            }
            .eraseToAnyPublisher()
    }
}
