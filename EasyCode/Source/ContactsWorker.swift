//
//  ContactsWorker.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import Foundation
import Contacts

/// A class responsible for managing contacts in the address book.
public class ContactsWorker {

    /// A structure representing a contact.
    public struct Contact: Hashable {

        var name = ""
        var surname = ""
        var fullName = ""
        var phoneNumber = ""

        public func hash(into hasher: inout Hasher) { hasher.combine(phoneNumber) }

        public static func == (lhs: Contact, rhs: Contact) -> Bool { lhs.phoneNumber == rhs.phoneNumber }
    }

    public init() {}

    /// An array to store contacts.
    public var contacts: [Contact] = []

    /// Requests access to the contacts.
    ///
    /// - Parameter completion: A closure to be called with the result of the access request.
    ///
    /// # Example:
    /// ``` swift
    /// let contactsWorker = ContactsWorker()
    /// contactsWorker.requestAccessForContacts { granted in
    ///     print("Access granted: \(granted)")
    /// }
    /// ```
    public func requestAccessForContacts(completion: @escaping (Bool) -> Void) {
        switch CNContactStore.authorizationStatus(for: .contacts) {
        case .authorized: completion(true)
        case .denied: completion(false)
        case .restricted, .notDetermined:
            CNContactStore().requestAccess(for: .contacts) { granted, _  in
                DispatchQueue.main.async { completion(granted) }
            }
        default: break
        }
    }

    /// Adds a contact to the address book.
    ///
    /// - Parameter contactToAdd: The contact to be added.
    ///
    /// # Example:
    /// ``` swift
    /// let contactsWorker = ContactsWorker()
    /// let contact = ContactsWorker.Contact(name: "John", surname: "Doe", phoneNumber: "1234567890")
    /// contactsWorker.addContactToAddressBook(contact)
    /// ```
    public func addContactToAddressBook(_ contactToAdd: Contact) {
        let contact = CNMutableContact()
        contact.givenName = contactToAdd.name
        contact.familyName = contactToAdd.surname

        let homePhone = CNLabeledValue(
            label: CNLabelHome,
            value: CNPhoneNumber(stringValue: contactToAdd.phoneNumber)
        )
        contact.phoneNumbers = [homePhone]

        let saveRequest = CNSaveRequest()
        saveRequest.add(contact, toContainerWithIdentifier: nil)

        do {
            try CNContactStore().execute(saveRequest)
        } catch {
            dump(error, name: "ContactsWorker")
        }
    }

    /// Updates a contact in the address book by phone number.
    ///
    /// - Parameters:
    ///   - phoneNumber: The phone number of the contact to be updated.
    ///   - newContact: The new contact information.
    /// - Returns: A boolean indicating whether the update was successful.
    ///
    /// # Example:
    /// ``` swift
    /// let contactsWorker = ContactsWorker()
    /// let updatedContact = ContactsWorker.Contact(name: "John", surname: "Smith", phoneNumber: "1234567890")
    /// let success = contactsWorker.updateContact(by: "1234567890", with: updatedContact)
    /// print("Update successful: \(success)")
    /// ```
    @discardableResult
    public func updateContact(by phoneNumber: String, with newContact: Contact) -> Bool {
        let contactStore = CNContactStore()
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]

        guard let contacts = try? contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch),
              let contact = contacts.first,
              let mutableContact = contact.mutableCopy() as? CNMutableContact else {
            return false
        }
        mutableContact.givenName = newContact.name
        mutableContact.familyName = newContact.surname
        mutableContact.phoneNumbers = [
            CNLabeledValue(
                label: CNLabelHome,
                value: CNPhoneNumber(stringValue: newContact.phoneNumber)
            )
        ]

        let saveRequest = CNSaveRequest()
        saveRequest.update(mutableContact)

        do {
            try contactStore.execute(saveRequest)
            return true
        } catch {
            return false
        }
    }

    /// Deletes a contact from the address book by phone number.
    ///
    /// - Parameter phoneNumber: The phone number of the contact to be deleted.
    /// - Returns: A boolean indicating whether the deletion was successful.
    ///
    /// # Example:
    /// ``` swift
    /// let contactsWorker = ContactsWorker()
    /// let success = contactsWorker.deleteContact(by: "1234567890")
    /// print("Delete successful: \(success)")
    /// ```
    @discardableResult
    public func deleteContact(by phoneNumber: String) -> Bool {
        let contactStore = CNContactStore()
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]

        guard let contacts = try? contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch),
              let contact = contacts.first,
              let mutableContact = contact.mutableCopy() as? CNMutableContact else {
            return false
        }
        let saveRequest = CNSaveRequest()
        saveRequest.delete(mutableContact)

        do {
            try contactStore.execute(saveRequest)
            return true
        } catch {
            dump(error, name: "ContactsWorker")
            return false
        }
    }

    /// Loads contacts from the phone book.
    ///
    /// - Parameters:
    ///   - isOnlyUniqueRequired: A boolean indicating whether only unique contacts should be loaded.
    ///   - isNeedToSort: A boolean indicating whether the contacts should be sorted.
    ///   - completion: A closure to be called when the loading is complete.
    ///
    /// # Example:
    /// ``` swift
    /// let contactsWorker = ContactsWorker()
    /// contactsWorker.loadPhoneBookContacts(isOnlyUniqueRequired: true, isNeedToSort: true) {
    ///     print("Contacts loaded: \(contactsWorker.contacts)")
    /// }
    /// ```
    public func loadPhoneBookContacts(
        isOnlyUniqueRequired: Bool = false,
        isNeedToSort: Bool = true,
        completion: @escaping () -> Void
    ) {
        let keys = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey]
        let request = CNContactFetchRequest(keysToFetch: keys as [CNKeyDescriptor])
        let contactStore = CNContactStore()

        contacts.removeAll()
        DispatchQueue.global(qos: .userInitiated).async {
            do {
                try contactStore.enumerateContacts(with: request) { [weak self] contact, _ in
                    guard let self else { return }

                    let fullName = [contact.givenName, contact.familyName]
                        .filter { !$0.isEmpty }
                        .joined(separator: " ")
                        .replacingOccurrences(of: "\\s+$", with: "", options: .regularExpression)

                    self.contacts += contact.phoneNumbers
                        .compactMap { phoneNumber in
                            return Contact(
                                name: contact.givenName,
                                surname: contact.familyName,
                                fullName: fullName,
                                phoneNumber: phoneNumber.value.stringValue
                            )
                        }
                    if isOnlyUniqueRequired {
                        self.contacts = self.contacts.uniqued(on: \.phoneNumber)
                    }
                    if isNeedToSort {
                        self.contacts.sort { (lhs: Contact, rhs: Contact) -> Bool in
                            return lhs.name.compare(
                                rhs.name,
                                options: [.caseInsensitive, .diacriticInsensitive]
                            ) == .orderedAscending
                        }
                    }
                }
                DispatchQueue.main.async {
                    completion()
                }
            } catch {
                dump(error, name: "ContactsWorker")
            }
        }
    }
}
