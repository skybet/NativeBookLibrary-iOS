//
//  KeychainItem.swift
//  NativeBookLibrary
//
//  Created by Matthew Gallagher on 21/03/2022.
//

import Foundation

struct KeychainItem {
    // MARK: - Properties
    private(set) var account: String
    let accessGroup: String?

    private static var bundleIdentifier = Bundle.main.bundleIdentifier!

    // MARK: - Intialisation
    init(account: String, accessGroup: String? = nil) {
        self.account = account
        self.accessGroup = accessGroup
    }

    /// Build a query to find the item that matches the bundle identifier, account and access group.
    func readItem() throws -> String {
        var query = KeychainItem.keychainQuery(account: account, accessGroup: accessGroup)
        query[kSecMatchLimit as String] = kSecMatchLimitOne
        query[kSecReturnAttributes as String] = kCFBooleanTrue
        query[kSecReturnData as String] = kCFBooleanTrue

        // Try to fetch the existing keychain item that matches the query
        var queryResult: AnyObject?
        let status = withUnsafeMutablePointer(to: &queryResult) {
            SecItemCopyMatching(query as CFDictionary, UnsafeMutablePointer($0))
        }

        // Check the return status and throw an error if appropriate
        guard status != errSecItemNotFound else { throw KeychainError.noPassword }
        guard status == noErr else { throw KeychainError.unhandledError }

        // Parse the password string from the query result
        guard
            let existingItem = queryResult as? [String: AnyObject],
            let passwordData = existingItem[kSecValueData as String] as? Data,
            let password = String(data: passwordData, encoding: String.Encoding.utf8)
        else { throw KeychainError.unexpectedPasswordData }

        return password
    }

    /// Encode the password into an Data object.
    func saveItem(_ password: String) throws {
        guard let encodedPassword = password.data(using: String.Encoding.utf8) else { throw KeychainError.unhandledError }

        do {
            // Check for an existing item in the keychain
            try _ = readItem()

            // Update the existing item with the new password.
            var attributesToUpdate = [String: AnyObject]()
            attributesToUpdate[kSecValueData as String] = encodedPassword as AnyObject?

            let query = KeychainItem.keychainQuery(account: account, accessGroup: accessGroup)
            let status = SecItemUpdate(query as CFDictionary, attributesToUpdate as CFDictionary)

            // Throw an error if an unexpected status was returned
            guard status == noErr else { throw KeychainError.unhandledError }
        } catch KeychainError.noPassword {
            // No password was found in the keychain. Create a dictionary to save as a new keychain item
            var newItem = KeychainItem.keychainQuery(account: account, accessGroup: accessGroup)
            newItem[kSecValueData as String] = encodedPassword as AnyObject?

            // Add a the new item to the keychain.
            let status = SecItemAdd(newItem as CFDictionary, nil)

            // Throw an error if an unexpected status was returned.
            guard status == noErr else { throw KeychainError.unhandledError }
        }
    }

    /// Delete the existing item from the keychain.
    func deleteItem() throws {
        let query = KeychainItem.keychainQuery(account: account, accessGroup: accessGroup)
        let status = SecItemDelete(query as CFDictionary)

        // Throw an error if an unexpected status was returned.
        guard status == noErr || status == errSecItemNotFound else { throw KeychainError.unhandledError }
    }

    private static func keychainQuery(account: String? = nil, accessGroup: String? = nil) -> [String: AnyObject] {
        var query: [String: AnyObject] = [:]
        query[kSecClass as String] = kSecClassGenericPassword
        query[kSecAttrService as String] = Self.bundleIdentifier as AnyObject?

        if let account = account {
            query[kSecAttrAccount as String] = account as AnyObject?
        }

        if let accessGroup = accessGroup {
            query[kSecAttrAccessGroup as String] = accessGroup as AnyObject?
        }

        return query
    }

    static var currentUserIdentifier: String {
        do {
            let storedIdentifier = try KeychainItem(account: "userIdentifier").readItem()
            return storedIdentifier
        } catch {
            return ""
        }
    }

    static func deleteUserIdentifier() {
        do { 
            try KeychainItem(account: "userIdentifier").deleteItem()
        } catch {
            print("⛔️ Unable to delete userIdentifier from Keychain")
        }
    }

    // MARK: - KeychainError
    enum KeychainError: Error {
        case noPassword
        case unexpectedPasswordData
        case unexpectedItemData
        case unhandledError
    }
}
