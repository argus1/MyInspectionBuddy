//
//  APIService.swift
//  udiSearch
//
//  Created by Nicole Tang on 7/29/25.
//

import Foundation

struct KeyValue: Identifiable {
    let id = UUID()
    let key: String
    let value: String
}

class APIService {
    static let shared = APIService()
    
    private let includedKeys: [String] = [
        "productCodes[0].deviceName",
        "gudid.device.devicePublishDate",
        "gudid.device.contacts.customerContact[0].email",
        "gudid.device.contacts.customerContact[0].phone",
        "gudid.device.MRISafetyStatus",
        "gudid.device.productCodes.fdaProductCode[0].productCodeName",
        "gudid.device.versionModelNumber",
        "gudid.device.companyName",
        "gudid.device.deviceCommDistributionStatus",
        "gudid.device.publicVersionDate",
        "gudid.device.identifiers.identifier[0].deviceId",
        "gudid.device.dunsNumber",
        "gudid.device.publicDeviceRecordKey",
        "gudid.device.gmdnTerms.gmdn[0].gmdnPTDefinition",
        "gudid.device.catalogNumber",
        "gudid.device.deviceDescription",
        "gudid.device.brandName"
    ]

    func fetchFilteredKeyValues(di: String, completion: @escaping (Result<[KeyValue], Error>) -> Void) {
        let urlString = "https://accessgudid.nlm.nih.gov/api/v2/devices/lookup.json?di=\(di)"
        guard let url = URL(string: urlString) else {
            completion(.failure(NSError(domain: "Invalid URL", code: 0)))
            return
        }

        URLSession.shared.dataTask(with: url) { data, _, error in
            if let error = error {
                completion(.failure(error))
                return
            }

            guard let data = data else {
                completion(.failure(NSError(domain: "No data", code: 0)))
                return
            }

            do {
                let jsonObject = try JSONSerialization.jsonObject(with: data, options: [])
                let filtered = self.flattenJSON(jsonObject: jsonObject)
                    .filter { self.includedKeys.contains($0.key) }
                completion(.success(filtered))
            } catch {
                completion(.failure(error))
            }
        }.resume()
    }

    private func flattenJSON(jsonObject: Any, parentKey: String = "") -> [KeyValue] {
        var result: [KeyValue] = []

        if let dict = jsonObject as? [String: Any] {
            for (key, value) in dict {
                let newKey = parentKey.isEmpty ? key : "\(parentKey).\(key)"
                result.append(contentsOf: flattenJSON(jsonObject: value, parentKey: newKey))
            }
        } else if let array = jsonObject as? [Any] {
            for (index, value) in array.enumerated() {
                let newKey = "\(parentKey)[\(index)]"
                result.append(contentsOf: flattenJSON(jsonObject: value, parentKey: newKey))
            }
        } else {
            result.append(KeyValue(key: parentKey, value: "\(jsonObject)"))
        }

        return result
    }
}
