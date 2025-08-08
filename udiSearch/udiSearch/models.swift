//
//  GUDIDResponse.swift
//  udiSearch
//
//  Created by Nicole Tang on 7/29/25.
//


import Foundation

struct GUDIDResponse: Codable {
    let gudid: Gudid
    let productCodes: [ProductCode]
}

struct Gudid: Codable {
    let device: Device
}

struct Device: Codable {
    let publicDeviceRecordKey: String
    let publicVersionStatus: String
    let deviceRecordStatus: String
    let publicVersionNumber: Int
    let publicVersionDate: String
    let devicePublishDate: String
    let deviceCommDistributionEndDate: String?
    let deviceCommDistributionStatus: String
    let identifiers: Identifiers
    let brandName: String
    let versionModelNumber: String
    let catalogNumber: String
    let dunsNumber: String
    let companyName: String
    let deviceCount: Int
    let deviceDescription: String
    let DMExempt: Bool
    let premarketExempt: Bool
    let deviceHCTP: Bool
    let deviceKit: Bool
    let deviceCombinationProduct: Bool
    let singleUse: Bool
    let lotBatch: Bool
    let serialNumber: Bool
    let manufacturingDate: Bool
    let expirationDate: Bool
    let donationIdNumber: Bool
    let labeledContainsNRL: Bool
    let labeledNoNRL: Bool
    let MRISafetyStatus: String
    let rx: Bool
    let otc: Bool
    let contacts: Contacts
    let gmdnTerms: GMDNTerms
    let productCodes: ProductCodes
    let deviceSizes: String?
    let environmentalConditions: EnvironmentalConditions
    let sterilization: Sterilization
}

struct Identifiers: Codable {
    let identifier: [Identifier]
}

struct Identifier: Codable {
    let deviceId: String
    let deviceIdType: String
    let deviceIdIssuingAgency: String
    let containsDINumber: String?
    let pkgQuantity: String?
    let pkgDiscontinueDate: String?
    let pkgStatus: String?
    let pkgType: String?
}

struct Contacts: Codable {
    let customerContact: [CustomerContact]
}

struct CustomerContact: Codable {
    let phone: String
    let phoneExtension: String?
    let email: String
}

struct GMDNTerms: Codable {
    let gmdn: [GMDN]
}

struct GMDN: Codable {
    let gmdnPTName: String
    let gmdnPTDefinition: String
}

struct ProductCodes: Codable {
    let fdaProductCode: [FDAProductCode]
}

struct FDAProductCode: Codable {
    let productCode: String
    let productCodeName: String
}

struct EnvironmentalConditions: Codable {
    let storageHandling: [StorageHandling]
}

struct StorageHandling: Codable {
    let storageHandlingType: String
    let storageHandlingHigh: StorageHandlingValue
    let storageHandlingLow: StorageHandlingValue
    let storageHandlingSpecialConditionText: String?
}

struct StorageHandlingValue: Codable {
    let unit: String
    let value: String
}

struct Sterilization: Codable {
    let deviceSterile: Bool
    let sterilizationPriorToUse: Bool
    let methodTypes: String?
}

struct ProductCode: Codable {
    let productCode: String
    let physicalState: String?
    let deviceClass: String
    let thirdPartyFlag: String
    let definition: String
    let submissionTypeID: String
    let reviewPanel: String
    let gmpExemptFlag: String
    let technicalMethod: String?
    let reviewCode: String?
    let lifeSustainSupportFlag: String
    let unclassifiedReason: String?
    let implantFlag: String
    let targetArea: String?
    let regulationNumber: String?
    let deviceName: String
    let medicalSpecialty: String?
}
