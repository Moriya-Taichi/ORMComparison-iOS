import Foundation
import GRDB

final class GRDBPublisherStore: PublisherStore {

    private let databaseQueue: DatabaseQueue

    init (databaseQueue: DatabaseQueue) {
        self.databaseQueue = databaseQueue
        try? databaseQueue.write { database in
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
                table.primaryKey(["id"])
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
                table.primaryKey(["id"])
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

            try? database.create(
                table: Owner.databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer)
                    .notNull()
                    .indexed()
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
                var book = GRDBObject.Book(
                    id: book.id,
                    name: book.name,
                    price: book.price,
                    publisherId: publisher.id
                )
                try? book.insert(database)
            }
            var publisherInfo = GRDBObject.Publisher(
                id: publisher.id,
                name: publisher.name,
                ownerId: publisher.owner.id
            )
            try? publisherInfo.insert(database)
        }
    }

    func read() -> [Publisher] {
        return databaseQueue.read { database in
            let temporalKey = GRDBObject.Publisher.books.forKey("books")
            let request = GRDBObject.Publisher
                .including(all: temporalKey)
                .including(required: GRDBObject.Publisher.owner)
            return (try? Publisher.fetchAll(database, request)) ?? []
        }
    }

    func update(publisher: Publisher) {
        try? databaseQueue.write { database in
            let request = GRDBObject.Publisher
                .filter(
                    GRDBObject.Publisher.Columns.id == publisher.id
                )
                .including(all: GRDBObject.Publisher.books)
                .including(required: GRDBObject.Publisher.owner)
            guard let storedPublisher = try? Publisher.fetchOne(database, request) else {
                return
            }
            try? publisher.owner.update(database)

            let difference = publisher
                .books
                .differenceElements(
                    from: storedPublisher.books
                )

            difference.deletedElements.forEach { element in
                let book = GRDBObject.Book(
                    id: element.id,
                    name: element.name,
                    price: element.price,
                    publisherId: publisher.id
                )
                try? book.delete(database)
            }

            difference.insertedElements.forEach { element in
                var book = GRDBObject.Book(
                    id: element.id,
                    name: element.name,
                    price: element.price,
                    publisherId: publisher.id
                )
                try? book.insert(database)
            }

            difference.noChangedElements.forEach { element in
                var book = GRDBObject.Book(
                    id: element.id,
                    name: element.name,
                    price: element.price,
                    publisherId: publisher.id
                )
                try? book.update(database)
            }
            let publisherInfo = GRDBObject.Publisher(
                id: publisher.id,
                name: publisher.name,
                ownerId: publisher.owner.id
            )
            try? publisherInfo.update(database)
        }
    }

    func delete(publisher: Publisher) {
        try? databaseQueue.write { database in
            let publisherInfo = GRDBObject.Publisher(
                id: publisher.id,
                name: publisher.name,
                ownerId: publisher.owner.id
            )
            try? publisherInfo.delete(database)
        }
    }
}
