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
                var book = GRDBStoredBook(
                    id: book.id,
                    name: book.name,
                    price: book.price,
                    publisherId: publisher.id
                )
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

    func read() -> [Publisher]? {
        return databaseQueue.read { database in
            let request = GRDBStoredPublisher
                .including(all: GRDBStoredPublisher.books)
                .including(required: GRDBStoredPublisher.owner)
            return try? Publisher.fetchAll(database, request)
        }
    }

    func update(publisher: Publisher) {
        try? databaseQueue.write { database in
            try? publisher.owner.update(database)
            publisher.books.forEach { book in
                let book = GRDBStoredBook(
                    id: book.id,
                    name: book.name,
                    price: book.price,
                    publisherId: publisher.id
                )
                try? book.update(database)
            }
            let publisherInfo = GRDBStoredPublisher(
                id: publisher.id,
                name: publisher.name,
                ownerId: publisher.owner.id
            )
            try? publisherInfo.update(database)
        }
    }

    func delete(publisher: Publisher) {
        try? databaseQueue.write { database in
            try? publisher.owner.delete(database)
            publisher.books.forEach { book in
                let book = GRDBStoredBook(
                    id: book.id,
                    name: book.name,
                    price: book.price,
                    publisherId: publisher.id
                )
                try? book.delete(database)
            }
            let publisherInfo = GRDBStoredPublisher(
                id: publisher.id,
                name: publisher.name,
                ownerId: publisher.owner.id
            )
            try? publisherInfo.delete(database)
        }
    }
}
