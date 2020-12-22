import FMDB

final class FMDBPublisherStore: PublisherStore {

    private let fmDatabaseQueue: FMDatabaseQueue

    init (
        fmDatabaseQueue: FMDatabaseQueue
    ) {
        self.fmDatabaseQueue = fmDatabaseQueue
        fmDatabaseQueue.inDatabase { database in
            let createPublisherTableSQL = "CREATE TABLE IF NOT EXISTS publishers (id INTEGER PRIMARY KEY, name TEXT, owner_id INTEGER, foreign key(owner_id) references owners(id));"
            let createBooksTableSQL = "CREATE TABLE IF NOT EXISTS books (id INTEGER PRIMARY KEY, name TEXT, price INTEGER, publisher_id INTEGER, foreign key(publisher_id) references publishers(id));"
            let createOwnersTableSQL = "CREATE TABLE IF NOT EXISTS owners (id INTEGER PRIMARY KEY, name TEXT, age INTEGER, profile TEXT);"
            database.open()
            try? database.executeUpdate(
                createOwnersTableSQL,
                values: nil
            )

            try? database.executeUpdate(
                createPublisherTableSQL,
                values: nil
            )

            try? database.executeUpdate(
                createBooksTableSQL,
                values: nil
            )
            database.close()
        }
    }

    func create(publisher: Publisher) {
        let createPublisherSQL = "INSERT INTO publishers (id, name, owner_id) VALUES (?, ?, ?);"
        let createBookSQL = "INSERT INTO books (id, name, price, publisher_id) VALUES " +
            Array(
                repeating: "(?, ?, ?, ?)",
                count: publisher.books.count
            )
            .joined(separator: ",") +
            ";"
        let createOwnerSQL = "INSERT INTO owners (id, name, age, profile) VALUES (?, ?, ?, ?);"
        fmDatabaseQueue.inDatabase { database in
            try? database.executeUpdate(
                createOwnerSQL,
                values: [
                    publisher.owner.id,
                    publisher.owner.name,
                    publisher.owner.age,
                    publisher.owner.profile
                ]
            )

            try? database.executeUpdate(
                createPublisherSQL,
                values: [
                    publisher.id,
                    publisher.name,
                    publisher.owner.id
                ]
            )

            try? database.executeUpdate(
                createBookSQL,
                values: publisher.books.map { book -> [Any] in
                    return [
                        book.id,
                        book.name,
                        book.price,
                        publisher.id
                    ]
                }.flatMap { $0 }
            )
        }
    }

    func readByLazyLoading () -> [Publisher] {
        let selectPublishersSQL = "SELECT * FROM publishers;"
        var publishers: [Publisher] = []
        fmDatabaseQueue.inDatabase { database in
            database.open()
            var rowPublishers: [(id: Int, name: String, ownerID: Int)] = []
            var rowBooks: [(id: Int, name: String, price: Int, publisherID: Int)] = []
            var rowOwners: [(id: Int, name: String, age: Int, profile: String)] = []
            if let result = try? database.executeQuery(
                selectPublishersSQL,
                values: nil
            ) {
                while result.next() {
                    rowPublishers.append(
                        (
                            id: Int(result.int(forColumnIndex: 0)),
                            name: result.string(forColumnIndex: 1) ?? "",
                            ownerID: Int(result.int(forColumnIndex: 2))
                         )
                    )
                }
            }

            guard !rowPublishers.isEmpty else {
                return
            }

            let selectOwnersSQL = "SELECT * FROM owners WHERE id IN (" +
                Array(
                    repeating: "?",
                    count: rowPublishers.count
                ).joined(separator: ",") +
                ");"
            let selectBooksSQL = "SELECT * FROM books WHERE publisher_id IN (" +
                Array(
                    repeating: "?",
                    count: rowPublishers.count
                )
                .joined(separator: ",") +
                ");"

            if let result = try? database.executeQuery(
                selectOwnersSQL,
                values: nil
            ) {
                while result.next() {
                    rowOwners.append(
                        (
                            id: Int(result.int(forColumnIndex: 0)),
                            name: result.string(forColumnIndex: 1) ?? "",
                            age: Int(result.int(forColumnIndex: 2)),
                            profile: result.string(forColumnIndex: 3) ?? ""
                         )
                    )
                }
            }

            if let result = try? database.executeQuery(
                selectBooksSQL,
                values: nil
            ) {
                while result.next() {
                    rowBooks.append(
                        (
                            id: Int(result.int(forColumnIndex: 0)),
                            name: result.string(forColumnIndex: 1) ?? "",
                            price: Int(result.int(forColumnIndex: 2)),
                            publisherID: Int(result.int(forColumnIndex: 3))
                         )
                    )
                }
            }

            rowPublishers.forEach { publisher in
                let rowOwner = rowOwners.first { owner -> Bool in
                    return owner.id == publisher.ownerID
                }!

                let owner = Owner(
                    id: rowOwner.id,
                    name: rowOwner.name,
                    age: rowOwner.age,
                    profile: rowOwner.profile
                )
                let books = rowBooks
                    .filter { $0.publisherID == publisher.id }
                    .map { Book(id: $0.id, name: $0.name, price: $0.price) }
                publishers.append(
                    .init(
                        id: publisher.id,
                        name: publisher.name,
                        books: books,
                        owner: owner
                    )
                )
            }

            database.close()
        }
        return publishers
    }

    func read() -> [Publisher] {
        var publishers: [Publisher] = []
        let query = "SELECT publishers.id, publishers.name, books.id, books.name, books.price, owners.id, owners.name, owners.age, owners.profile FROM publishers " +
            "LEFT JOIN books ON publishers.id == books.publisher_id " +
            "LEFT JOIN owners ON publishers.owner_id == owners.id;"
        fmDatabaseQueue.inDatabase { database in
            if
                let result = try? database.executeQuery(
                    query,
                    values: nil
                ) {
                var currentPublisher: Publisher? = nil
                var books: [Book] = []
                while result.next() {
                    if
                        let publisher = currentPublisher,
                        publisher.id != Int(result.int(forColumnIndex: 0))
                    {
                        publishers.append(publisher)
                        books = []
                    }

                    let book = Book(
                        id: Int(result.int(forColumnIndex: 2)),
                        name: result.string(forColumnIndex: 3) ?? "",
                        price: Int(result.int(forColumnIndex: 4))
                    )
                    books.append(book)

                    currentPublisher = Publisher(
                        id: Int(result.int(forColumnIndex: 0)),
                        name: result.string(forColumnIndex: 1) ?? "",
                        books: books,
                        owner: .init(
                            id: Int(result.int(forColumnIndex: 5)),
                            name: result.string(forColumnIndex: 6) ?? "",
                            age: Int(result.int(forColumnIndex: 7)),
                            profile: result.string(forColumnIndex: 8) ?? ""
                        )
                    )
                }
            }
        }
        return publishers
    }

    func update (publisher: Publisher) {
        let updataPublisherSQL = "UPDATE publishers SET name = ?, owner_id = ? WHERE id = ?;"
        let updateBookSQL =
            "UPDATE books SET name = ?, price = ?, publisher_id = ? WHERE id = ?;"
        let updateOwnerSQL = "UPDATE owners SET name = ?, age = ?, profile = ? WHERE id = ?;"
        fmDatabaseQueue.inDatabase { database in
            try? database
                .executeUpdate(
                updataPublisherSQL,
                values: [
                    publisher.name,
                    publisher.owner.id,
                    publisher.id
                ]
            )

            try? database
                .executeUpdate(
                    updateOwnerSQL,
                    values: [
                        publisher.owner.name,
                        publisher.owner.age,
                        publisher.owner.profile,
                        publisher.owner.id
                    ]
                )

            if database.beginTransaction() {
                publisher.books.forEach { book in
                    try? database.executeUpdate(
                        updateBookSQL,
                        values: [
                            book.name,
                            book.price,
                            publisher.id,
                            book.id
                        ]
                    )
                }
                database.commit()
            }
        }
    }

    func delete(publisher: Publisher) {
        let deletePublisherSQL =
            "DELETE FROM publishers WHERE id = ?;"
        let deleteBookSQL =
            "DELETE FROM books WHERE publisher_id = ?;"
        fmDatabaseQueue.inDatabase { database in
            try? database.executeUpdate(
                deletePublisherSQL,
                values: [
                    publisher.id
                ]
            )

            try? database.executeUpdate(
                deleteBookSQL,
                values: [
                    publisher.id
                ]
            )
        }
    }
}
