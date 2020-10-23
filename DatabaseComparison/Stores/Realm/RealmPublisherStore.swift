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

final class RealmPublisherStore {

    let realm: Realm

    init (realm: Realm) {
        self.realm = realm
    }

    func create (publisher: Publisher) {

    }

    func read() {

    }

    func update(publisher: Publisher) {
        guard let storedPublisher = realm.objects(PublisherObject.self).filter("", publisher.id).first else {
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
        let owner = OwnerObject()
        owner.age = publisher.owner.age
        owner.name = publisher.owner.name
        owner.profile = publisher.owner.profile
        storedPublisher.name = publisher.name
        storedPublisher.owner = owner
        storedPublisher.books.removeAll()
        publisher.books.map { book -> BookObject in
            let object = BookObject()
            object.id = book.id
            object.name = book.name
            object.price = book.price
            return object
        }.forEach {
            storedPublisher.books.append($0)
        }
    }

    func delete(publisher: Publisher) {
        guard let storedPublisher = realm.objects(PublisherObject.self).filter("", publisher.id).first else {
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
}
