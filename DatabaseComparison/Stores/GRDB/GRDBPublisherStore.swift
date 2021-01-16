import Foundation
import GRDB

final class GRDBPublisherStore: PublisherStore {

    private let databaseQueue: DatabaseQueue

    init (databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
        try? databaseQueue.write { database in
            try? database.create(
                table: Owner.databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer)
                    .notNull()
                    .indexed()
                    .primaryKey()
                table.column("name", .text).notNull()
                table.column("age", .integer).notNull()
                table.column("profile", .text).notNull()
            }

            try? database.create(
                table: GRDBObject
                    .Publisher
                    .databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer)
                    .indexed()
                    .notNull()
                    .primaryKey()
                table.column("name", .text).notNull()
                table.column("ownerId", .integer)
                    .notNull()
                    .indexed()
                    .references(
                        Owner.databaseTableName
                    )
            }

            try? database.create(
                table: GRDBObject
                    .Book
                    .databaseTableName,
                temporary: false,
                ifNotExists: true
            ){ table in
                table.column("id", .integer)
                    .indexed()
                    .notNull()
                    .primaryKey()
                table.column("name", .text).notNull()
                table.column("price", .integer).notNull()
                table.column("publisherId", .integer)
                    .notNull()
                    .indexed()
                    .references(
                        GRDBObject.Publisher.databaseTableName,
                        onDelete: .cascade
                    )
            }

        }
    }

    func create(publisher: Publisher) {
        try? databaseQueue.write { database in
            var owner = publisher.owner
            try? owner.insert(database)
            let publisherObject = GRDBObject.Publisher(
                id: publisher.id,
                name: publisher.name,
                ownerId: publisher.owner.id
            )
            try? publisherObject.insert(database)
            publisher.books.forEach { book in
                let bookObject = GRDBObject.Book(
                    id: book.id,
                    name: book.name,
                    price: book.price,
                    publisherId: publisher.id
                )
                try? bookObject.insert(database)
            }
        }
    }

    func read() -> [Publisher] {
        return databaseQueue.read { database in
            let books = GRDBObject.Publisher.books.forKey("books")
            let request = GRDBObject.Publisher
                .including(all: books)
                .including(required: GRDBObject.Publisher.owner)
            return (try? Publisher.fetchAll(database, request)) ?? []
        }
    }

    func update(publisher: Publisher) {
        try? databaseQueue.write { database in
            try? publisher.owner.update(database)

            publisher.books.forEach { book in
                let bookObject = GRDBObject.Book(
                    id: book.id,
                    name: book.name,
                    price: book.price,
                    publisherId: publisher.id
                )
                try? bookObject.save(database)
            }

            try? GRDBObject.Book
                    .filter(
                        !publisher.books.map { $0.id }.contains(Column("id")) &&
                        Column("publisherId") == publisher.id
                    )
                    .deleteAll(database)

            let publisherObject = GRDBObject.Publisher(
                id: publisher.id,
                name: publisher.name,
                ownerId: publisher.owner.id
            )
            try? publisherObject.update(database)
        }
    }

    func delete(publisher: Publisher) {
        try? databaseQueue.write { database in
            try? GRDBObject.Publisher
                .filter(Column("id") == publisher.id)
                .deleteAll(database)
            try? publisher.owner.delete(database)
        }
    }
}
