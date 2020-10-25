//
//  CoreDataAbstractObjectStore.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/10/25.
//

import Foundation
import CoreData

//Example: Store Abstract Object Comformed to NSManagedObject
final class CoreDataAbstractObjectStore {

    private let container: NSPersistentContainer

    init (container: NSPersistentContainer) {
        self.container = container
    }

    func create<T: NSManagedObject>() -> T {
        let context = container.viewContext
        return T(context: context)
    }

    func insert<T: NSManagedObject>(object: T) {
        let context = container.viewContext
        context.insert(object)
        saveContext()
    }

    func delete<T: NSManagedObject>(object: T) {
        let context = container.viewContext
        context.delete(object)
        saveContext()
    }
    func read<T: NSManagedObject>() -> NSFetchedResultsController<T> {
        let context = container.viewContext
        let request: NSFetchRequest<T> = .init(entityName: String(describing: T.self))
        let controller = NSFetchedResultsController(
            fetchRequest: request,
            managedObjectContext: context,
            sectionNameKeyPath: nil,
            cacheName: nil
        )
        do {
            try controller.performFetch()
        }
        catch {
            print(error)
        }
        return controller
    }

    func saveContext() {
        let context = container.viewContext
        if context.hasChanges {
            do {
                try context.save()
            }
            catch {
                print(error)
            }
        }
    }
}

