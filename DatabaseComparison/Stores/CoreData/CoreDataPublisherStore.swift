import Foundation
import CoreData

final class CoreDataPublisherStore: PublisherStore {

    private let container: NSPersistentContainer

    init (container: NSPersistentContainer) {
        self.container = container
    }

    func create(publisher: Publisher) {
        let context = container.viewContext
        let request: NSFetchRequest<PublisherEntity> = PublisherEntity.fetchRequest()
        request.fetchLimit = 1
        request.predicate = .init(format: "id = %@", publisher.id)
        let storedPublisher = try? context.fetch(request)
        guard storedPublisher == nil else {
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

        let bookEntities = getOrCreateBooks(publisher.books, publisher.id)
            .sorted { lhs, rhs -> Bool in
                return lhs.id < rhs.id
            }
        zip(
            bookEntities,
            publisher.books
        )
        .forEach { bookEntity, book in
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

        let publisherRequest: NSFetchRequest<PublisherEntity> = PublisherEntity.fetchRequest()
        publisherRequest.fetchLimit = 1
        publisherRequest.predicate = .init(format: "id = %@", publisher.id)

        guard
            let publisherEntity = try? context.fetch(publisherRequest).first
        else {
            return
        }

        publisherEntity.name = publisher.name
        publisherEntity.owner = getOrCreateOwner(publisher.owner)

        let ownerEntity = getOrCreateOwner(publisher.owner)
        ownerEntity.name = publisher.owner.name
        ownerEntity.age = Int32(publisher.owner.age)
        ownerEntity.profile = publisher.owner.profile

        let bookEntities = getOrCreateBooks(publisher.books, publisher.id)
            .sorted { lhs, rhs -> Bool in
                return lhs.id < rhs.id
            }
        zip(
            bookEntities,
            publisher.books
        )
        .forEach { bookEntity, book in
            bookEntity.name = book.name
            bookEntity.price = Int64(book.price)
            publisherEntity.addToBooks(bookEntity)
        }

        if let relataionBooks = publisherEntity.books {
            let differenceFromRelation = bookEntities
                .differenceElements(
                    from: relataionBooks.compactMap { $0 as? BookEntity }
                )

            differenceFromRelation.insertedElements.forEach { element in
                publisherEntity.addToBooks(element)
            }

            differenceFromRelation.deletedElements.forEach { element in
                publisherEntity.removeFromBooks(element)
            }
        }


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

    private func getOrCreateOwner(_ owner: Owner) -> OwnerEntity {
        let context = container.viewContext
        let request: NSFetchRequest<OwnerEntity> = OwnerEntity.fetchRequest()
        request.predicate = .init(format: "id = %@", owner.id)
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

    private func getOrCreateBooks(_ books: [Book], _ publisherID: Int) -> [BookEntity] {
        let context = container.viewContext
        let request: NSFetchRequest<BookEntity> = BookEntity.fetchRequest()
        request.predicate = .init(format: "id IN %@", argumentArray: books.map { $0.id })
        guard let bookEntities = try? context.fetch(request) else {
            return books.map { book -> BookEntity in
                let newBookEntity = BookEntity(context: context)
                newBookEntity.id = Int64(book.id)
                newBookEntity.name = book.name
                newBookEntity.price = Int64(book.price)
                newBookEntity.publisherId = Int64(publisherID)
                context.insert(newBookEntity)
                saveContext()
                return newBookEntity
            }
        }

        if bookEntities.count == books.count {
            return bookEntities
        } else {
            let difference = books.map { $0.id }
                .differenceIndex(
                    from: bookEntities.map { Int($0.id) }
                )
            let insertedElements = difference.insertedIndex.map { index -> BookEntity in
                let book = books[index]
                let newBookEntity = BookEntity(context: context)
                newBookEntity.id = Int64(book.id)
                newBookEntity.name = book.name
                newBookEntity.price = Int64(book.price)
                newBookEntity.publisherId = Int64(publisherID)
                context.insert(newBookEntity)
                return newBookEntity
            }
            saveContext()
            return bookEntities + insertedElements
        }
    }
}
