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

        publisher.books.forEach { book in
            let bookObject = BookObject()
            bookObject.id = book.id
            bookObject.name = book.name
            bookObject.price = book.price
            newPublisher.books.append(bookObject)
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

        let difference = publisher
            .books
            .map { $0.id }
            .differenceIndex(
                from: storedPublisher.books.map { $0.id }
            )

        difference.deletedIndex.forEach { index in
            storedPublisher.books.remove(at: index)
        }

        difference.insertedIndex.forEach { index in
            let newBookObject = BookObject()
            let book = publisher.books[index]
            newBookObject.id = book.id
            newBookObject.name = book.name
            newBookObject.price = book.price
            storedPublisher.books.append(newBookObject)
        }

        zip(
            difference.noChangedIndex.map { publisher.books[$0] },
            difference.noChangedOldIndex.map { storedPublisher.books[$0] }
        )
        .forEach { book, bookObject in
            bookObject.id = book.id
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
}
