import Foundation
import CoreData

final class CoreDataPublisherStore: PublisherStore {

    private let container: NSPersistentContainer

    init (container: NSPersistentContainer) {
        self.container = container
        container.loadPersistentStores { _,_ in }
        container.viewContext.mergePolicy = NSMergeByPropertyObjectTrumpMergePolicy
    }

    func create(publisher: Publisher) {
        let context = container.viewContext
        let publisherEntity = PublisherEntity(context: context)

        publisherEntity.id = Int64(publisher.id)
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
            let publisherEntity = try? context.fetch(publisherRequest).first,
            let bookEntities = publisherEntity.books?
                .compactMap({ $0 as? BookEntity })
                .sorted(by: { lhs, rhs -> Bool in
                    return lhs.id < rhs.id
                })
        else {
            return
        }

        publisherEntity.name = publisher.name
        let ownerEntity = getOrCreateOwner(publisher.owner)
        ownerEntity.name = publisher.owner.name
        ownerEntity.age = Int32(publisher.owner.age)
        ownerEntity.profile = publisher.owner.profile
        publisherEntity.owner = ownerEntity

        //CollectionDIffing(Swift5.1から)を使って差分から更新する方法
        let differences = publisher
            .books
            .map { $0.id }
            .difference(
                from: bookEntities.map { Int($0.id) }
            )
        var insertedBookIDs: Set<Int> = .init()
        var deletedBookIDs: Set<Int64> = .init()
        differences.forEach { difference in
            switch difference {
            case let .insert(offset, _, _):
                let newBookEntity = BookEntity(context: context)
                newBookEntity.id = Int64(publisher.books[offset].id)
                newBookEntity.name = publisher.books[offset].name
                newBookEntity.price = Int64(publisher.books[offset].price)

                context.insert(newBookEntity)
                publisherEntity.addToBooks(newBookEntity)

                insertedBookIDs.insert(publisher.books[offset].id)
            case let .remove(offset, _, _):
                deletedBookIDs.insert(bookEntities[offset].id)
                publisherEntity.removeFromBooks(bookEntities[offset])
                context.delete(bookEntities[offset])
            }
        }

        zip(
            publisher.books.filter { !insertedBookIDs.contains($0.id) },
            bookEntities.filter { !deletedBookIDs.contains($0.id) }
        )
        .forEach { book, bookEntity in
            bookEntity.name = book.name
            bookEntity.price = Int64(book.price)
        }
        //mergePolicyがNSMergeByPropertyObjectTrumpMergePolicyなので重複を気にせずこれでもよい
        publisher.books.forEach { book in
            let bookEntity = BookEntity(context: context)
            bookEntity.id = Int64(book.id)
            bookEntity.name = book.name
            bookEntity.price = Int64(book.price)
            context.insert(bookEntity)
            publisherEntity.addToBooks(bookEntity)
        }

        //全部消してinsertし直す方法
        bookEntities.forEach { bookEntity in
            publisherEntity.removeFromBooks(bookEntity)
            context.delete(bookEntity)
        }

        publisher.books.forEach { book in
            let bookEntity = BookEntity(context: context)
            bookEntity.id = Int64(book.id)
            bookEntity.name = book.name
            bookEntity.price = Int64(book.price)
            context.insert(bookEntity)
            publisherEntity.addToBooks(bookEntity)
        }

        //Requestを活用する方法
        let bookEntityFetchRequest: NSFetchRequest<NSFetchRequestResult> = .init(entityName: .init(describing: BookEntity.self))
        bookEntityFetchRequest.predicate = .init(
            format: "publisher == %@ AND NOT id IN %@",
            publisherEntity,
            publisher.books.map { $0.id }
        )
        let bookEntityDeleteRequest = NSBatchDeleteRequest(fetchRequest: bookEntityFetchRequest)
        try? context.execute(bookEntityDeleteRequest)

        publisher.books.forEach { book in
            let bookEntity = BookEntity(context: context)
            bookEntity.id = Int64(book.id)
            bookEntity.name = book.name
            bookEntity.price = Int64(book.price)
            context.insert(bookEntity)
            publisherEntity.addToBooks(bookEntity)
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
