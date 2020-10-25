import Foundation
import CoreData

final class CorePublisherDataStore {

    private let container: NSPersistentContainer

    init (container: NSPersistentContainer) {
        self.container = container
    }

    func create(publisher: Publisher) {
        let context = container.viewContext
        let publisherEntity = PublisherEntity(context: context)
        publisherEntity.id = Int64(publisher.owner.id)
        publisherEntity.name = publisher.name

        let ownerEntity = OwnerEntity(context: context)
        ownerEntity.id = Int64(publisher.owner.id)
        ownerEntity.name = publisher.owner.name
        ownerEntity.profile = publisher.owner.profile
        ownerEntity.age = Int32(publisher.owner.age)

        publisher.books.forEach { book in
            let bookEntity = BookEntity(context: context)
            bookEntity.id = Int64(book.id)
            bookEntity.name = book.name
            bookEntity.price = Int64(book.price)
            publisherEntity.addToBooks(bookEntity)
        }
        context.insert(publisherEntity)
        saveContext()
    }

    func read() -> [Publisher] {
        let context = container.viewContext
        let request: NSFetchRequest<PublisherEntity> = PublisherEntity.fetchRequest()
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
