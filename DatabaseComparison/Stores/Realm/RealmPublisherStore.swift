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
        guard
            let publisherObject = realm.object(
                ofType: PublisherObject.self,
                forPrimaryKey: publisher.id
            )
        else {
            return
        }
        if realm.isInWriteTransaction {
            updateProcess(publisher: publisher, publisherObject: publisherObject)
        } else {
            try? realm.write {
                updateProcess(publisher: publisher, publisherObject: publisherObject)
            }
        }
    }

    private func updateProcess(publisher: Publisher, publisherObject: PublisherObject) {
        let owner = getOrCreateOwner(owner: publisher.owner)
        owner.age = publisher.owner.age
        owner.name = publisher.owner.name
        owner.profile = publisher.owner.profile

        publisherObject.name = publisher.name
        publisherObject.owner = owner

        //全部消してinsert
        realm.delete(publisherObject.books)
        publisher.books.forEach { book in
            let bookObject = BookObject()
            bookObject.id = book.id
            bookObject.name = book.name
            bookObject.price = book.price
            publisherObject.books.append(bookObject)
        }

        //差分更新
        let differences = publisher
            .books
            .map { $0.id }
            .difference(
                from: publisherObject.books.map { $0.id }
            )

        var insertedBookIDs: Set<Int> = .init()
        var deletedBookIDs: Set<Int> = .init()

        differences.forEach { difference in
            switch difference {
            case let .insert(offset, _, _):
                let book = publisher.books[offset]
                let bookObject = BookObject()
                bookObject.id = book.id
                bookObject.name = book.name
                bookObject.price = book.price
                realm.add(bookObject, update: .all)
                publisherObject.books.append(bookObject)
                insertedBookIDs.insert(book.id)
            case let .remove(offset, _, _):
                let bookObject = publisherObject.books[offset]
                deletedBookIDs.insert(bookObject.id)
                realm.delete(bookObject)
            }
        }

        zip(
            publisher.books.filter { !insertedBookIDs.contains($0.id) },
            publisherObject.books.filter { !deletedBookIDs.contains($0.id) }
        )
        .forEach { book, bookObject in
            bookObject.name = book.name
            bookObject.price = book.price
        }

        //検索条件とかを活用する方法
        realm.delete(realm
                        .objects(BookObject.self)
                        .filter(
                            NSPredicate(
                                format: "NOT id IN %@", publisher.books.map { $0.id }
                            )
                        )
        )

        publisher.books.forEach { book in
            let bookObject = BookObject()
            bookObject.id = book.id
            bookObject.name = book.name
            bookObject.price = book.price
            realm.add(bookObject, update: .all)
            publisherObject.books.append(bookObject)
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
