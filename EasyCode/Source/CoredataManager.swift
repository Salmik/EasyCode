//
//  CoredataManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import CoreData

public protocol DataBaseNameProtocol {
    var rawValue: String { get }
}

public class CoreDataManager {

    private let databaseName: DataBaseNameProtocol

    public init(databaseName: DataBaseNameProtocol) {
        self.databaseName = databaseName
    }

    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: databaseName.rawValue.capitalized)
        container.loadPersistentStores { _, error in
            if let error = error as NSError? {
                dump("Unresolved error \(error), \(error.userInfo)", name: "CoreDataManager")
            }
        }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
        return container
    }()

    private var context: NSManagedObjectContext { persistentContainer.viewContext }

    /**
     Saves the current context if there are any changes.
     */
    public func saveContext() {
        if context.hasChanges {
            do {
                try context.save()
            } catch {
                context.rollback()
                let nserror = error as NSError
                dump("Unresolved error \(nserror), \(nserror.userInfo)", name: "CoreDataManager")
            }
        }
    }

    /**
     Creates a new instance of the specified `NSManagedObject` type.

     - Parameters:
       - isSaveRequired: A Boolean value that indicates whether the context should be saved after creation.
       - completion: A closure that provides the created object.

      # Example:
     ``` swift
     coreDataManager.create(isSaveRequired: true) { (user: User) in
         user.name = "John Doe"
     }
     ```
     */
    public func create<T: NSManagedObject>(isSaveRequired: Bool, completion: (T) -> Void) {
        let object = T(context: context)
        completion(object)

        if isSaveRequired {
            saveContext()
        }
    }

    /**
     Fetches a single `NSManagedObject` that matches the given predicate.

     - Parameters:
       - predicate: The predicate to apply to the fetch request.

     - Returns: The first object that matches the predicate or `nil` if no match is found.

     - Throws: An error if the fetch request fails.

      # Example:
     ``` swift
     let predicate = NSPredicate(format: "name == %@", "John Doe")
     let user: User? = try coreDataManager.object(with: predicate)
     ```
     */
    public func object<T: NSManagedObject>(with predicate: NSPredicate) throws -> T? {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate

        let result = try context.fetch(request)
        return result.first
    }

    /**
     Updates an `NSManagedObject` that matches the given predicate.

     - Parameters:
       - predicate: The predicate to apply to the fetch request.
       - completion: A closure that provides the object to be updated.

     - Throws: An error if the fetch request fails.

      # Example:
     ``` swift
     let predicate = NSPredicate(format: "name == %@", "John Doe")
     try coreDataManager.update(with: predicate) { (user: User) in
         user.age = 30
     }
     ```
     */
    public func update<T: NSManagedObject>(with predicate: NSPredicate, completion: (T) -> Void) throws {
        guard let object: T = try object(with: predicate) else { return }
        completion(object)
        saveContext()
    }

    /**
     Performs a background fetch with the specified parameters.

     - Parameters:
       - predicate: The predicate to apply to the fetch request (optional).
       - sortDescriptors: An array of sort descriptors to apply to the fetch request (optional).
       - fetchLimit: The maximum number of objects to return (optional).
       - fetchOffset: The offset of the first object to return (optional).
       - completion: A closure that is called with the results of the fetch.

      # Example:
     ``` swift
     let predicate = NSPredicate(format: "age > %d", 20)
     coreDataManager.performBackgroundTask(predicate: predicate) { (result: Result<[User], Error>) in
         switch result {
         case .success(let users):
             print(users)
         case .failure(let error):
             print(error)
         }
     }
     ```
     */
    public func performBackgroundTask<T: NSManagedObject>(
        predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil,
        fetchLimit: Int? = nil,
        fetchOffset: Int? = nil,
        completion: @escaping (Result<[T], Error>) -> Void
    ) {
        persistentContainer.performBackgroundTask { context in
            let request = NSFetchRequest<T>(entityName: String(describing: T.self))
            request.predicate = predicate
            request.sortDescriptors = sortDescriptors
            request.returnsObjectsAsFaults = false
            if let fetchLimit {
                request.fetchLimit = fetchLimit
            }
            if let fetchOffset {
                request.fetchOffset = fetchOffset
            }
            do {
                let result = try context.fetch(request)
                completion(.success(result))
            } catch {
                completion(.failure(error))
            }
        }
    }

    /**
     Counts the number of objects that match the given predicate.

     - Parameters:
       - entity: The type of the `NSManagedObject`.
       - predicate: The predicate to apply to the fetch request (optional).

     - Returns: The number of objects that match the predicate.

     - Throws: An error if the fetch request fails.

     # Example:
     ``` swift
     let count = try coreDataManager.count(entity: User.self, predicate: NSPredicate(format: "age > %d", 20))
     print("Number of users older than 20: \(count)")
     ```
     */
    public func count<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate? = nil) throws -> Int {
        let fetchRequest = NSFetchRequest<T>(entityName: String(describing: T.self))
        fetchRequest.predicate = predicate
        return try context.count(for: fetchRequest)
    }

    /**
     Fetches all objects that match the given predicate.

     - Parameters:
       - predicate: The predicate to apply to the fetch request (optional).
       - sortDescriptors: An array of sort descriptors to apply to the fetch request (optional).

     - Returns: An array of objects that match the predicate.

     - Throws: An error if the fetch request fails.

     # Example:
     ``` swift
     let users: [User] = try coreDataManager.all(with: NSPredicate(format: "age > %d", 20))
     print(users)
     ```
     */
    public func all<T: NSManagedObject>(
        with predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [T] {
        let request = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.returnsObjectsAsFaults = false

        let result = try context.fetch(request)
        return result
    }

    /**
     Deletes the specified object from the context.

     - Parameters:
       - object: The object to be deleted.

     - Example:
     ``` swift
     coreDataManager.delete(object: user)
     ```
     */
    public func delete<T: NSManagedObject>(object: T) {
        context.delete(object)
        saveContext()
    }

    /**
     Deletes all objects of the specified type.

     - Parameters:
       - type: The type of the `NSManagedObject`.

     - Throws: An error if the fetch request fails.

     # Example:
     ``` swift
     try coreDataManager.deleteAll(type: User.self)
     ```
     */
    public func deleteAll<T: NSManagedObject>(type: T.Type) throws {
        let objects: [T] = try all()
        objects.forEach { delete(object: $0) }
    }

    /**
     Recreates the database by destroying and re-adding the persistent store.

     # Example:
     ``` swift
     coreDataManager.recreateDatabase()
     ```
     */
    public func recreateDatabase() {
        guard let url = persistentContainer.persistentStoreDescriptions.first?.url else { return }

        do {
            let coordinator = persistentContainer.persistentStoreCoordinator
            try coordinator.destroyPersistentStore(at: url, ofType: NSSQLiteStoreType)
            try coordinator.addPersistentStore(ofType: NSSQLiteStoreType, configurationName: nil, at: url)
        } catch {
            dump(error, name: "CoreDataManager")
        }
    }

    /**
     Performs a batch insert of the specified objects.

     - Parameters:
       - entity: The type of the `NSManagedObject`.
       - objects: An array of dictionaries, each representing an object to insert.

     - Throws: An error if the batch insert fails.

     # Example:
     ``` swift
     let objects = [
         ["name": "John Doe", "age": 30],
         ["name": "Jane Smith", "age": 25]
     ]
     try coreDataManager.batchInsert(entity: User.self, objects: objects)
     ```
     */
    public func batchInsert<T: NSManagedObject>(entity: T.Type, objects: [[String: Any]]) throws {
        let batchRequest = NSBatchInsertRequest(entity: T.entity(), objects: objects)
        batchRequest.resultType = .statusOnly
        do {
            let result = try context.execute(batchRequest) as? NSBatchInsertResult
            if result?.result as? Bool == true {
                print("Batch insert was successful.")
            }
        } catch {
            throw error
        }
    }

    /**
     Performs a batch update of the specified objects.

     - Parameters:
       - entity: The type of the `NSManagedObject`.
       - predicate: The predicate to apply to the batch update request (optional).
       - propertiesToUpdate: A dictionary of properties to update.

     - Throws: An error if the batch update fails.

     # Example:
     ``` swift
     try coreDataManager.batchUpdate(
         entity: User.self,
         predicate: NSPredicate(format: "age > %d", 20),
         propertiesToUpdate: ["age": 21]
     )
     ```
     */
    public func batchUpdate<T: NSManagedObject>(
        entity: T.Type,
        predicate: NSPredicate?,
        propertiesToUpdate: [String: Any]
    ) throws {
        let batchRequest = NSBatchUpdateRequest(entityName: String(describing: T.self))
        batchRequest.predicate = predicate
        batchRequest.propertiesToUpdate = propertiesToUpdate
        batchRequest.resultType = .updatedObjectsCountResultType
        do {
            let result = try context.execute(batchRequest) as? NSBatchUpdateResult
            print("Updated \(result?.result ?? 0) records")
        } catch {
            throw error
        }
    }

    /**
     Performs a batch delete of the specified objects.

     - Parameters:
       - entity: The type of the `NSManagedObject`.
       - predicate: The predicate to apply to the batch delete request (optional).

     - Throws: An error if the batch delete fails.

     # Example:
     ``` swift
     try coreDataManager.batchDelete(entity: User.self, predicate: NSPredicate(format: "age > %d", 20))
     ```
     */
    public func batchDelete<T: NSManagedObject>(entity: T.Type, predicate: NSPredicate?) throws {
        let fetchRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(entityName: String(describing: entity))
        fetchRequest.predicate = predicate
        let batchRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        batchRequest.resultType = .resultTypeObjectIDs
        do {
            let result = try context.execute(batchRequest) as? NSBatchDeleteResult
            let objectIDArray = result?.result as? [NSManagedObjectID]
            let changes = [NSDeletedObjectsKey: objectIDArray ?? []]
            NSManagedObjectContext.mergeChanges(fromRemoteContextSave: changes, into: [context])
        } catch {
            throw error
        }
    }
}
