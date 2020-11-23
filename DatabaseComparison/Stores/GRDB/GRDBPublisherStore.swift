import Foundation
import GRDB

final class GRDBPublisherStore: PublisherStore {

    private let databaseQueue: DatabaseQueue

    init (databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
        try? databaseQueue.write { database in
            try? database.create(
                table: GRDBStoredPublisher.databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer).notNull()
                table.primaryKey(["id"])
                table.column("name", .text).notNull()
                table.column("ownerId", .integer).notNull()
            }

            try? database.create(
                table: GRDBStoredBook.databaseTableName,
                temporary: false,
                ifNotExists: true
            ){ table in
                table.column("id", .integer).notNull()
                table.primaryKey(["id"])
                table.column("name", .text).notNull()
                table.column("price", .integer).notNull()
                table.column("publisherId", .integer).notNull()
            }

            try? database.create(
                table: Owner.databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer).notNull()
                table.primaryKey(["id"])
                table.column("name", .text).notNull()
                table.column("age", .integer).notNull()
                table.column("profile", .text).notNull()
            }

        }
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

    func read() -> [Publisher] {
        return databaseQueue.read { database in
            let request = GRDBStoredPublisher
                .including(all: GRDBStoredPublisher.books)
                .including(required: GRDBStoredPublisher.owner)
            return (try? Publisher.fetchAll(database, request)) ?? []
        }
    }

    func update(publisher: Publisher) {
        try? databaseQueue.write { database in
            let storedBooks: [GRDBStoredBook]? = try? GRDBStoredBook
                .filter(
                    GRDBStoredBook.Columns.publisherId == publisher.id
                )
                .fetchAll(database)
            try? publisher.owner.update(database)

            if let storedBooks = storedBooks {
                let difference = publisher.books.map { $0.id }
                    .differenceIndex(from: storedBooks.map { $0.id })
                difference.deletedIndex.forEach { index in
                    let book = GRDBStoredBook(
                        id: publisher.books[index].id,
                        name: publisher.books[index].name,
                        price: publisher.books[index].price,
                        publisherId: publisher.id
                    )
                    try? book.delete(database)
                }
            }
            publisher.books.forEach { book in
                var book = GRDBStoredBook(
                    id: book.id,
                    name: book.name,
                    price: book.price,
                    publisherId: publisher.id
                )
                try? book.save(database)
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
