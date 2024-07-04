//
//  ContactsWorker.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 04.07.2024.
//

import Foundation
import Contacts

public class ContactsWorker {

    public struct Contact: Hashable {

        var name = ""
        var surname = ""
        var fullName = ""
        var phoneNumber = ""

        public func hash(into hasher: inout Hasher) { hasher.combine(phoneNumber) }

        public static func == (lhs: Contact, rhs: Contact) -> Bool { lhs.phoneNumber == rhs.phoneNumber }
    }

    public init() {}

    public var contacts: [Contact] = []

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

    @discardableResult
    public func updateContact(by phoneNumber: String, with newContact: Contact) -> Bool {
        let contactStore = CNContactStore()
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]

        do {
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            guard let contact = contacts.first,
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
                Logger.print("Failed to update contact: \(error)")
                return false
            }
        } catch {
            Logger.print("Failed to fetch contact for update: \(error)")
            return false
        }
    }

    @discardableResult
    public func deleteContact(by phoneNumber: String) -> Bool {
        let contactStore = CNContactStore()
        let predicate = CNContact.predicateForContacts(matching: CNPhoneNumber(stringValue: phoneNumber))
        let keysToFetch = [CNContactGivenNameKey, CNContactFamilyNameKey, CNContactPhoneNumbersKey] as [CNKeyDescriptor]

        do {
            let contacts = try contactStore.unifiedContacts(matching: predicate, keysToFetch: keysToFetch)
            guard let contact = contacts.first,
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
        } catch {
            dump(error, name: "ContactsWorker")
            return false
        }
    }

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

                    DispatchQueue.main.async { completion() }
                }
            } catch {
                dump(error, name: "ContactsWorker")
            }
        }
    }
}
