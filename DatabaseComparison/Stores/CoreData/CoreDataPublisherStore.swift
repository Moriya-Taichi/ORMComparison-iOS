import Foundation
import CoreData

final class CorePublisherDataStore {

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

    func deleteAll<T: NSManagedObject>(objectType: T.Type) {
        let context = container.viewContext
        let fetchRequest = objectType.fetchRequest()
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: fetchRequest)
        do {
            try context.execute(deleteRequest)
            try context.save()
        }
        catch {
            print(error)
        }
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
