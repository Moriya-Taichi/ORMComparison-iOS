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
        guard
            let publisherEntities = try? context.fetch(request)
        else {
            return []
        }
        let publishers: [Publisher] = publisherEntities.compactMap { publisherEntity in
            guard let ownerEntity = publisherEntity.owner else {
                return nil
            }
            let bookEntities = publisherEntity.books == nil ? [] : publisherEntity.books!
            let books: [Book] = bookEntities.compactMap { entity in
                guard let bookEntity = entity as? BookEntity else {
                    return nil
                }
                let book = Book(
                    id: Int(bookEntity.id),
                    name: bookEntity.name ?? "",
                    price: Int(bookEntity.price)
                )
                return book
            }
            let owner: Owner = Owner(
                id: Int(ownerEntity.id),
                name: ownerEntity.name ?? "",
                age: Int(ownerEntity.age),
                profile: ownerEntity.profile ?? ""
            )
            return Publisher(
                id: Int(publisherEntity.id),
                name: publisherEntity.name ?? "",
                books: books,
                owner: owner
            )
        }
        return publishers
    }

    func update(publisher: Publisher) {
        let context = container.viewContext
        let request: NSFetchRequest<PublisherEntity> = PublisherEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id = %@", publisher.id)
        guard
            let objcet = try? context.fetch(request).first
        else {
            return
        }
        objcet.id = Int64(publisher.owner.id)
        objcet.name = publisher.name
        objcet.owner?.id = Int64(publisher.owner.id)
        objcet.owner?.age = Int32(publisher.owner.age)
        objcet.owner?.name = publisher.owner.name
        objcet.owner?.profile = publisher.owner.profile
        let bookEntities = publisher.books.map { book -> BookEntity in
            let bookEntity = BookEntity(context: context)
            bookEntity.id = Int64(book.id)
            bookEntity.name = book.name
            bookEntity.price = Int64(book.price)
            return bookEntity
        }
        let newBooks: NSSet = .init(array: bookEntities)
        objcet.books = newBooks
        saveContext()
    }

    func delete(publisher: Publisher) {
        let context = container.viewContext
        let request: NSFetchRequest<PublisherEntity> = PublisherEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id = %@", publisher.id)
        guard
            let objcet = try? context.fetch(request).first
        else {
            return
        }
        context.delete(objcet)
        saveContext()
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
