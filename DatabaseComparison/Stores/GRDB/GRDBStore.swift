import Foundation
import GRDB

final class GRDBPublisherStore {

    private let databaseQueue: DatabaseQueue

    init (databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
    }

    func create(publisher: Publisher) {
        try? databaseQueue.write { database in
            var owner = publisher.owner
            try? owner.insert(database)
            publisher.books.forEach { book in
                var book = book
                try? book.insert(database)
            }
            var publisherInfo = GRDBStoredPublisher(
                id: publisher.id,
                name: publisher.name,
                ownerId: publisher.owner.id
            )
            try? publisherInfo.insert(database)
        }
    }

    func read() {

    }

    func update(publisher: Publisher) {

    }

    func delete(publisher: Publisher) {
        
    }
}
