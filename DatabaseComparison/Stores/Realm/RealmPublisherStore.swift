import Foundation
import RealmSwift

class PublisherObject: Object {
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var owner: OwnerObject?
    let books = List<BookObject>()

    static override func primaryKey() -> String? {
        return "id"
    }
}

class BookObject: Object {
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var price: Int = -1

    static override func primaryKey() -> String? {
        return "id"
    }
}

class OwnerObject: Object {
    @objc dynamic var id: Int = -1
    @objc dynamic var name: String = ""
    @objc dynamic var age: Int = -1
    @objc dynamic var profile: String = ""

    static override func primaryKey() -> String? {
        return "id"
    }
}

final class RealmPublisherStore: PublisherStore {

    let realm: Realm

    init (realm: Realm) {
        self.realm = realm
    }

    func create (publisher: Publisher) {
        if realm.isInWriteTransaction {
            createProcess(publisher: publisher)
        } else {
            try? realm.write {
                createProcess(publisher: publisher)
            }
        }
    }

    private func createProcess(publisher: Publisher) {
        let newPublisher = PublisherObject()
        newPublisher.id = publisher.id
        newPublisher.name = publisher.name

        let owner = getOrCreateOwner(owner: publisher.owner)
        newPublisher.owner = owner

        let books = getOrCreateBooks(books: publisher.books)
        books.forEach { book in
            newPublisher.books.append(book)
        }

        try? realm.add(newPublisher)
    }

    func read() -> [Publisher] {
        let publishers = realm.objects(PublisherObject.self)
        return publishers.compactMap { object -> Publisher? in
            guard let ownerObject = object.owner else {
                return nil
            }

            let owner = Owner(
                id: ownerObject.id,
                name: ownerObject.name,
                age: ownerObject.age,
                profile: ownerObject.profile
            )

            let books: [Book] = object.books.map { bookObeject -> Book in
                .init(
                    id: bookObeject.id,
                    name: bookObeject.name,
                    price: bookObeject.price
                )
            }

            return .init(
                id: object.id,
                name: object.name,
                books: books,
                owner: owner
            )
        }
    }

    func update(publisher: Publisher) {
        guard let storedPublisher = realm.object(
                ofType: PublisherObject.self,
                forPrimaryKey: publisher.id
        ) else {
            return
        }
        if realm.isInWriteTransaction {
            updateProcess(publisher: publisher, storedPublisher: storedPublisher)
        } else {
            try? realm.write {
                updateProcess(publisher: publisher, storedPublisher: storedPublisher)
            }
        }
    }

    private func updateProcess(publisher: Publisher, storedPublisher: PublisherObject) {
        let owner = getOrCreateOwner(owner: publisher.owner)
        owner.age = publisher.owner.age
        owner.name = publisher.owner.name
        owner.profile = publisher.owner.profile

        storedPublisher.name = publisher.name
        storedPublisher.owner = owner

        let bookObjects = getOrCreateBooks(books: publisher.books)

        zip(
            bookObjects.sorted { $0.id < $1.id },
            publisher.books
        )
        .forEach { bookObject, book in
            bookObject.name = book.name
            bookObject.price = book.price
        }
    }

    func delete(publisher: Publisher) {
        guard let storedPublisher = realm.object(
                ofType: PublisherObject.self,
                forPrimaryKey: publisher.id)
        else {
            return
        }
        if realm.isInWriteTransaction {
            try? realm.delete(storedPublisher)
        } else {
            try? realm.write {
                try? realm.delete(storedPublisher)
            }
        }
    }

    private func getOrCreateOwner(owner: Owner) -> OwnerObject {
        if let ownerObject = realm.object(
            ofType: OwnerObject.self,
            forPrimaryKey: owner.id
        ) {
            return ownerObject
        }

        let newOwnerObject = OwnerObject()
        newOwnerObject.id = owner.id
        newOwnerObject.name = owner.name
        newOwnerObject.profile = owner.profile
        newOwnerObject.age = owner.age

        if realm.isInWriteTransaction {
            realm.add(newOwnerObject)
        } else {
            try? realm.write {
                realm.add(newOwnerObject)
            }
        }

        return newOwnerObject
    }

    private func getOrCreateBooks(books: [Book]) -> [BookObject] {
        let predicate = NSPredicate(format: "id IN @%", books.map { $0.id })
        let bookObjects: [BookObject] = realm.objects(BookObject.self).filter(predicate).map { $0 }
        if books.count == bookObjects.count {
            return bookObjects
        } else {
            let difference = books
                .map { $0.id }
                .differenceIndex(
                    from: bookObjects.map { $0.id }
                )

            let newBookObjects = difference.insertedIndex.map { index -> BookObject in
                let newBookObject = BookObject()
                let book = books[index]
                newBookObject.id = book.id
                newBookObject.name = book.name
                newBookObject.price = book.price
                return newBookObject
            }

            if realm.isInWriteTransaction {
                newBookObjects.forEach { newBookObject in
                    realm.add(newBookObject)
                }
            } else {
                try? realm.write {
                    newBookObjects.forEach { newBookObject in
                        realm.add(newBookObject)
                    }
                }
            }

            return bookObjects + newBookObjects

        }
    }
}
