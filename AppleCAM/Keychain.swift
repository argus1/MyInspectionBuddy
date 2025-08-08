import Security
import Foundation

// MARK: - Keychain Service
class KeychainService {
    
    static let shared = KeychainService()
    private init() {}
    
    func savePassword(account: String, service: String, password: String) -> Bool {
        guard let passwordData = password.data(using: .utf8) else {
            print("Error: Could not convert password to data")
            return false
        }
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecValueData as String: passwordData
        ]
        
        // Remove any existing item
        SecItemDelete(query as CFDictionary)
        
        // Add the new item
        let status = SecItemAdd(query as CFDictionary, nil)
        
        if status == errSecSuccess {
            print("Password saved successfully to Keychain.")
            return true
        } else {
            print("Error saving password to Keychain. Status: \(status)")
            return false
        }
    }
    
    func getPassword(account: String, service: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service,
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var item: CFTypeRef?
        let status = SecItemCopyMatching(query as CFDictionary, &item)
        
        guard status == errSecSuccess,
              let data = item as? Data,
              let password = String(data: data, encoding: .utf8) else {
            print("Error retrieving password from Keychain. Status: \(status)")
            return nil
        }
        
        return password
    }
    
    func deletePassword(account: String, service: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: account,
            kSecAttrService as String: service
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        
        if status == errSecSuccess {
            print("Password deleted successfully from Keychain.")
            return true
        } else {
            print("Error deleting password from Keychain. Status: \(status)")
            return false
        }
    }
}

// MARK: - California SOS Credentials Manager
class CaliforniaSOSCredentials {
    private let service = "calico.sos.ca.gov"
    private let account = "argus.sun@cdph.ca.gov"
    
    func saveCredentials() {
        let success = KeychainService.shared.savePassword(
            account: account,
            service: service,
            password: "VedOcilac2025!"
        )
        
        if success {
            print("✅ SOS credentials saved to keychain")
        } else {
            print("❌ Failed to save SOS credentials")
        }
    }
    
    func getStoredPassword() -> String? {
        return KeychainService.shared.getPassword(
            account: account,
            service: service
        )
    }
    
    func removeCredentials() {
        let success = KeychainService.shared.deletePassword(
            account: account,
            service: service
        )
        
        if success {
            print("✅ SOS credentials removed from keychain")
        } else {
            print("❌ Failed to remove SOS credentials")
        }
    }
}
