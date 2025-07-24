//
//  FDARegistration.swift
//  Defines data models for decoding FDA registration API responses, including registration details and product data.
//
//  Updated by ChatGPT on 7/10/25.
//

import Foundation

// MARK: - Top-level API wrapper
// Represents the full JSON response from the FDA API, including metadata and a list of registrations.
struct FDAResponse: Decodable {
    // Metadata containing total number of results.
    let meta: Meta
    // Array of FDARegistration objects decoded from the API response.
    let results: [FDARegistration]

    // Nested metadata structure inside the top-level response.
    struct Meta: Decodable {
        // Contains total count of results returned by the API.
        let results: MetaResults
        struct MetaResults: Decodable {
            // Total number of results available.
            let total: Int
        }
    }
}

// MARK: - One registration record
// Represents one registration entry with registration details and associated products.
struct FDARegistration: Identifiable, Decodable {
    // Raw JSON fields decoded directly from the response.
    /// Proprietary names associated with the registration.
    let proprietaryName: [String]?
    /// Types of establishment for the registration.
    let establishmentType: [String]?
    /// Core registration details nested inside each FDARegistration.
    let registration: Core?
    /// List of products associated with the registration.
    let products: [Product]?

    // Computed properties used for filtering and UI display.
    /// Returns the registration number or "Unknown".
    var registrationNumber: String {
        registration?.registrationNumber ?? "Unknown"
    }
    /// Returns the FEI number or "Unknown".
    var feiNumber: String {
        registration?.feiNumber ?? "Unknown"
    }
    /// Returns the registration name or "Unknown".
    var registrationName: String {
        registration?.name ?? "Unknown"
    }
    /// Returns the U.S. agent name or "Unknown".
    var usAgentName: String {
        registration?.usAgent?.name ?? "Unknown"
    }
    /// Returns the U.S. agent state or "Unknown".
    var usAgentStateCode: String {
        registration?.usAgent?.stateCode ?? "Unknown"
    }
    /// Returns the created date of the first product or "Unknown".
    var creationDate: String {
        products?.first?.createdDate ?? "Unknown"
    }
    /// Returns the device class of the first product or "Unknown".
    var deviceClass: String {
        products?.first?.openfda?.deviceClass ?? "Unknown"
    }

    // Optional fields shown in the detailed view.
    /// Expiry year of the registration.
    var expiryYear: String? {
        registration?.regExpiryDateYear
    }
    /// Firm name of the owner/operator.
    var ownerOperatorFirmName: String? {
        registration?.ownerOperator?.firmName
    }

    // Composite ID composed of registration number and product code to ensure uniqueness.
    var id: String {
        let code = products?.first?.productCode ?? UUID().uuidString
        return "\(registrationNumber)-\(code)"
    }

    // Maps Swift property names to JSON keys for decoding.
    enum CodingKeys: String, CodingKey {
        case proprietaryName   = "proprietary_name"
        case establishmentType = "establishment_type"
        case registration      = "registration"
        case products
    }

    // MARK: - Nested “registration” JSON object
    // Holds core registration details nested inside each FDARegistration.
    struct Core: Decodable {
        /// The unique registration number assigned.
        let registrationNumber: String?
        /// The name associated with the registration.
        let name:                String?
        /// Facility Establishment Identifier number.
        let feiNumber:           String?
        /// State code where the facility is located.
        let stateCode:           String?
        /// ISO country code of the facility location.
        let isoCountryCode:      String?
        /// U.S. agent details for the registration.
        let usAgent:             UsAgent?
        /// Year the registration expires.
        let regExpiryDateYear:   String?
        /// Owner or operator firm information.
        let ownerOperator:       OwnerOperator?

        enum CodingKeys: String, CodingKey {
            case registrationNumber = "registration_number"
            case name
            case feiNumber          = "fei_number"
            case stateCode          = "state_code"
            case isoCountryCode     = "iso_country_code"
            case usAgent            = "us_agent"
            case regExpiryDateYear  = "reg_expiry_date_year"
            case ownerOperator      = "owner_operator"
        }

        struct UsAgent: Decodable {
            /// Name of the U.S. agent.
            let name: String?
            /// State code of the U.S. agent.
            let stateCode: String?    // US Agent's state code

            enum CodingKeys: String, CodingKey {
                case name
                case stateCode = "state_code"
            }
        }

        struct OwnerOperator: Decodable {
            /// Firm name of the owner or operator.
            let firmName: String?
            enum CodingKeys: String, CodingKey {
                case firmName = "firm_name"
            }
        }
    }

    // MARK: - Product subtype
    // Represents a product entry within an FDA registration.
    struct Product: Decodable {
        /// Code identifying the product.
        let productCode: String?
        /// Date the product record was created.
        let createdDate: String?
        /// Additional FDA-specific product information.
        let openfda:     OpenFDA?

        enum CodingKeys: String, CodingKey {
            case productCode = "product_code"
            case createdDate = "created_date"
            case openfda
        }

        struct OpenFDA: Decodable {
            /// Name of the device.
            let deviceName:       String?
            /// Regulation number associated with the device.
            let regulationNumber: String?
            /// Device classification.
            let deviceClass:      String?

            enum CodingKeys: String, CodingKey {
                case deviceName       = "device_name"
                case regulationNumber = "regulation_number"
                case deviceClass      = "device_class"
            }
        }
    }
}
