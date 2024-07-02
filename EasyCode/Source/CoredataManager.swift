//
//  CoredataManager.swift
//  EasyCode
//
//  Created by Zhanibek Lukpanov on 02.07.2024.
//

import CoreData

public class CoreDataManager {

    public enum DataBaseName: String {
        case `default`
    }

    private let databaseName: DataBaseName

    public init(databaseName: DataBaseName) {
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

    public func create<T: NSManagedObject>(isSaveRequired: Bool, completion: (T) -> Void) {
        let object = T(context: context)
        completion(object)

        if isSaveRequired {
            saveContext()
        }
    }

    public func object<T: NSManagedObject>(with predicate: NSPredicate) throws -> T? {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate

        let result = try context.fetch(request)
        return result.first
    }

    public func update<T: NSManagedObject>(with predicate: NSPredicate, completion: (T) -> Void) throws {
        guard let object: T = try object(with: predicate) else { return }
        completion(object)
        saveContext()
    }

    public func all<T: NSManagedObject>(
        with predicate: NSPredicate? = nil,
        sortDescriptors: [NSSortDescriptor]? = nil
    ) throws -> [T] {
        let request: NSFetchRequest<T> = NSFetchRequest<T>(entityName: String(describing: T.self))
        request.predicate = predicate
        request.sortDescriptors = sortDescriptors
        request.returnsObjectsAsFaults = false

        let result = try context.fetch(request)
        return result
    }

    public func delete<T: NSManagedObject>(object: T) {
        context.delete(object)
        saveContext()
    }

    public func deleteAll<T: NSManagedObject>(type: T.Type) throws {
        let objects: [T] = try all()
        objects.forEach { delete(object: $0) }
    }

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
}
