import Foundation
import CoreData

final class CoreDataPublisherStore: PublisherStore {

    private let container: NSPersistentContainer

    init (container: NSPersistentContainer) {
        self.container = container
        container.loadPersistentStores { _,_ in }
    }

    func create(publisher: Publisher) {
        let context = container.viewContext
        let request: NSFetchRequest<PublisherEntity> = PublisherEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id = %@", NSNumber(value: publisher.id))
        let storedPublisher = try? context.fetch(request)
        guard
            storedPublisher == nil ||
            storedPublisher?.isEmpty ?? true
        else {
            update(publisher: publisher)
            return
        }
        let publisherEntity = PublisherEntity(context: context)

        publisherEntity.id = Int64(publisher.owner.id)
        publisherEntity.name = publisher.name

        let ownerEntity = getOrCreateOwner(publisher.owner)
        ownerEntity.name = publisher.owner.name
        ownerEntity.age = Int32(publisher.owner.age)
        ownerEntity.profile = publisher.owner.profile
        publisherEntity.owner = ownerEntity

        publisher.books.forEach { book in
            let bookEntity = BookEntity(context: context)
            bookEntity.id = Int64(book.id)
            bookEntity.name = book.name
            bookEntity.price = Int64(book.price)
            publisherEntity.addToBooks(bookEntity)
            context.insert(bookEntity)
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

        let publisherRequest: NSFetchRequest<PublisherEntity> = PublisherEntity.fetchRequest()
        publisherRequest.fetchLimit = 1
        publisherRequest.predicate = .init(format: "id = %@", NSNumber(value: publisher.id))

        guard
            let publisherEntity = try? context.fetch(publisherRequest).first
        else {
            return
        }

        publisherEntity.name = publisher.name
        let ownerEntity = getOrCreateOwner(publisher.owner)
        ownerEntity.name = publisher.owner.name
        ownerEntity.age = Int32(publisher.owner.age)
        ownerEntity.profile = publisher.owner.profile
        publisherEntity.owner = ownerEntity

        if let relataionBooks = publisherEntity.books?.compactMap({ $0 as? BookEntity }) {
            let difference = publisher
                .books
                .map { $0.id }
                .differenceIndex(
                    from: relataionBooks.map { Int($0.id) }
                )

            difference.insertedIndex.forEach { index in
                let book = publisher.books[index]
                let bookEntity = BookEntity(context: context)
                bookEntity.id = Int64(book.id)
                bookEntity.name = book.name
                bookEntity.price = Int64(book.price)
                publisherEntity.addToBooks(bookEntity)
                context.insert(bookEntity)
            }

            difference.deletedIndex.forEach { index in
                let bookEntity = relataionBooks[index]
                publisherEntity.removeFromBooks(bookEntity)
            }

            zip(
                difference.noChangedIndex.map { publisher.books[$0] },
                difference.noChangedOldIndex.map { relataionBooks[$0] }
            )
            .forEach { book, bookEntity in
                bookEntity.id = Int64(book.id)
                bookEntity.name = book.name
                bookEntity.price = Int64(book.price)
            }
        }


        saveContext()
    }

    func delete(publisher: Publisher) {
        let context = container.viewContext
        let request: NSFetchRequest<PublisherEntity> = PublisherEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id = %@", NSNumber(value: publisher.id))
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

    private func getOrCreateOwner(_ owner: Owner) -> OwnerEntity {
        let context = container.viewContext
        let request: NSFetchRequest<OwnerEntity> = OwnerEntity.fetchRequest()
        request.predicate = .init(format: "id = %@", NSNumber(value: owner.id))
        request.fetchLimit = 1
        if let ownerEntity = try? context.fetch(request).first {
            return ownerEntity
        } else {
            let newOwnerEntity = OwnerEntity(context: context)
            newOwnerEntity.id = Int64(owner.id)
            newOwnerEntity.age = Int32(owner.age)
            newOwnerEntity.name = owner.name
            newOwnerEntity.profile = owner.profile
            context.insert(newOwnerEntity)
            return newOwnerEntity
        }
    }
}
