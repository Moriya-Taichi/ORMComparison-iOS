//
//  GRDBSQLPublisherStore.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/12/20.
//

import GRDB

final class GRDBSQLPublisherStore {

    private let databaseQueue: DatabaseQueue

    init () {
        let databasePath = try! FileManager
            .default
            .url(
                for: .applicationSupportDirectory,
                in: .userDomainMask,
                appropriateFor: nil,
                create: true
            )
            .appendingPathComponent("grdbSQLDatabase.sqlite")
            .path
        databaseQueue = try! .init(path: databasePath)

        try? databaseQueue.write { database in
            let createPublishersTableSQL = "CREATE TABLE IF NOT EXISTS publishers (id INTEGER PRIMARY KEY, name TEXT, owner_id INTEGER, foreign key(owner_id) references owners(id));"
            let createPublisherIndexSQL = "CREATE ownerindex INDEX on publishers(owner_id);"
            let createOwnersTableSQL = "CREATE TABLE IF NOT EXISTS owners (id INTEGER PRIMARY KEY, name TEXT, age INTEGER, profile TEXT);"
            let createBooksTableSQL = "CREATE TABLE IF NOT EXISTS books (id INTEGER PRIMARY KEY, name TEXT, price INTEGER, publisher_id INTEGER, foreign key(publisher_id) references publishers(id));"
            let createBooksIndexSQL = "CREATE INDEX publisherindex on books(publisher_id);"
            try? database.execute(sql: createOwnersTableSQL)
            try? database.execute(sql: createPublishersTableSQL)
            try? database.execute(sql: createBooksTableSQL)
            try? database.execute(sql: createPublisherIndexSQL)
            try? database.execute(sql: createBooksIndexSQL)
        }
    }


    func create(publisher: Publisher) {
        let createPublisherSQL = "INSERT INTO publishers (id, name, owner_id) VALUES (?, ?, ?);"
        let createOwnerSQL = "INSERT INTO owners (id, name, age, profile) VALUES (?, ?, ?, ?);"
        let createBooksSQL = "INSERT INTO books (id, name, price, publisher_id) VALUES " +
            Array(
                repeating: "(?, ?, ?, ?)",
                count: publisher.books.count
            )
            .joined(separator: ",") +
            ";"
        let bookValues: StatementArguments = .init(
            publisher.books.map { book -> [DatabaseValueConvertible] in
                return [
                    book.id,
                    book.name,
                    book.price,
                    publisher.id
                ]
            }.flatMap { $0 }
        )
        try? databaseQueue.write { database in
            try? database.execute(
                sql: createOwnerSQL,
                arguments: [
                    publisher.id,
                    publisher.name,
                    publisher.owner.id
                ]
            )
            try? database.execute(
                sql: createPublisherSQL,
                arguments: [
                    publisher.owner.id,
                    publisher.owner.name,
                    publisher.owner.age,
                    publisher.owner.profile
                ]
            )
            try? database.execute(
                sql: createBooksSQL,
                arguments: bookValues
            )
        }
    }

    func read() -> [Publisher] {
        let selectSQL = "SELECT publishers.id, publishers.name, books.id, books.name, books.price, owners.id, owners.name, owners.age, owners.profile FROM publishers " +
            "LEFT JOIN books ON publishers.id == books.publisher_id " +
            "LEFT JOIN owners ON publishers.owner_id == owners.id;"
        return databaseQueue.read { database -> [Publisher] in
            var publishers: [Publisher] = []
            guard
                let rows = try? Row.fetchCursor(database, sql: selectSQL)
            else {
                return []
            }
            var currentPublisher: Publisher? = nil
            var books: [Book] = []
            while let row = try? rows.next() {
                if
                    let publisher = currentPublisher,
                    publisher.id != row[0]
                {
                    publishers.append(publisher)
                    books = []
                }

                let book = Book(
                    id: row[2],
                    name: row[3],
                    price: row[4]
                )
                books.append(book)

                let owner = Owner(
                    id: row[5],
                    name: row[6],
                    age: row[7],
                    profile: row[8]
                )

                currentPublisher = .init(
                    id: row[0],
                    name: row[1],
                    books: books,
                    owner: owner
                )
            }
            return publishers
        }
    }

    func update(publisher: Publisher) {
        let updatePublisherSQL = "UPDATE publishers SET name = ?, owner_id = ? WHERE id = ?;"
        let updateBookSQL =
            "UPDATE books SET name = ?, price = ?, publisher_id = ? WHERE id = ?;"
        let updateOwnerSQL = "UPDATE owners SET name = ?, age = ?, profile = ? WHERE id = ?;"
        try? databaseQueue.write { database in
            try? database.execute(
                sql: updatePublisherSQL,
                arguments: [
                    publisher.name,
                    publisher.owner.id,
                    publisher.id
                ]
            )

            try? database.execute(
                sql: updateOwnerSQL,
                arguments: [
                    publisher.owner.name,
                    publisher.owner.age,
                    publisher.owner.profile,
                    publisher.owner.id
                ]
            )

            publisher.books.forEach { book in
                try? database.execute(
                    sql: updateBookSQL,
                    arguments: [
                        book.name,
                        book.price,
                        publisher.id,
                        book.id
                    ]
                )
            }
        }
    }

    func delete(publisher: Publisher) {
        let deletePublisherSQL =
            "DELETE FROM publishers WHERE id = ?;"
        let deleteBookSQL =
            "DELETE FROM books WHERE publisher_id = ?;"
        try? databaseQueue.write { database in
            try? database.execute(
                sql: deleteBookSQL,
                arguments: [
                    publisher.id
                ]
            )

            try? database.execute(
                sql: deletePublisherSQL,
                arguments: [
                    publisher.id
                ]
            )
        }
    }
}
