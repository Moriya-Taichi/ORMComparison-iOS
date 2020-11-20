
import FMDB

final class FMDBBookStore {

    private let databaseWrapper: FMDBDatabaseWrapeer

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS books (" +
        "id INTEGER PRIMARY KEY, " +
        "name TEXT, " +
        "price INTEGER, " +
        "publisher_id INTEGER" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "books (id, name, price, publisher_id) " +
        "VALUES " +
        "(?, ?, ?, ?);"

    private let selectSQL =
        "SELECT " +
        "id, name, price, publisher_id " +
        "FROM " +
        "books;" +
        "ORDER BY id;"

    private let updateSQL =
        "UPDATE " +
        "books " +
        "SET " +
        "name = ?, price = ?, publisher_id = ? " +
        "WHERE " +
        "id = ?;"

    private let deleteSQL =
        "DELETE FROM books WHERE id = ?;"

    init(
        databaseWrapper: FMDBDatabaseWrapeer
    ) {
        self.databaseWrapper = databaseWrapper
    }

    func create(book: Book, publisherID: Int) {
        try? databaseWrapper.executeUpdate(
            insertSQL,
            values: [
                book.id,
                book.name,
                book.price,
                publisherID
            ]
        )
    }

    func createBooks(books: [Book], publisherID: Int) {
        let sql = "INSERT INTO books (id, name, price, publisher_id) VALUES "
        let queryValue = Array(repeating: "(?,?,?,?)", count: books.count).joined(separator: ",")
        let query = sql + queryValue + ";"
        try? databaseWrapper.executeUpdate(
            query,
            values: books.map { book -> [Any] in
                [
                    book.id,
                    book.name,
                    book.price,
                    publisherID
                ]
            }.flatMap { $0 }
        )
    }

    func read() -> [Book] {
        var books: [Book] = []
        if
            let result = try? databaseWrapper.executeQuery(
                selectSQL,
                values: nil
            ) {
            let book = Book(
                id: result.long(forColumnIndex: 0),
                name: result.string(forColumnIndex: 1) ?? "",
                price: result.long(forColumnIndex: 2)
            )
            books.append(book)
        }
        return books
    }

    func readBooksByID(publisherID: Int) -> [Book] {
        var books: [Book] = []
        let query = "SELECT * FROM books WHERE publisher_id = ?;"
        if
            let result = try? databaseWrapper.executeQuery(
                query,
                values: [publisherID]
            ) {
            while result.next() {
                let book = Book(
                    id: result.long(forColumnIndex: 0),
                    name: result.string(forColumnIndex: 1) ?? "",
                    price: result.long(forColumnIndex: 2)
                )
                books.append(book)
            }
        }
        return books
    }

    func readBooksWithIDByPublisherIDs(_ ids:[Int]) -> [(book: Book, id: Int)] {
        var books: [(Book, Int)] = []
        let params = Array(repeating: "?", count: ids.count).joined(separator: ",")
        let query = "SELECT * FROM books WHERE publisher_id IN (" + params + ");"
        if
            let result = try? databaseWrapper.executeQuery(
                query,
                values: ids
            ) {
            while result.next() {
                let book = Book(
                    id: result.long(forColumnIndex: 0),
                    name: result.string(forColumnIndex: 1) ?? "",
                    price: result.long(forColumnIndex: 2)
                )
                books.append((book, result.long(forColumnIndex: 3)))
            }
        }
        return books
    }

    func update(book: Book, publisherID: Int) {
        try? databaseWrapper.executeUpdate(
            updateSQL,
            values: [
                book.name,
                book.price,
                publisherID,
                book.id
            ]
        )
    }

    func updateByBooks(books: [Book], publisherID: Int) {
        try? databaseWrapper.executeBlockWithTransaction { [weak self] in
            guard let self = self else { return }
            books.forEach { book in
                try? self.databaseWrapper.executeUpdateWithoutOpen(
                    self.updateSQL,
                    values: [
                        book.name,
                        book.price,
                        publisherID,
                        book.id
                    ]
                )
            }
        }
    }

    func delete(book: Book) {
        try? databaseWrapper.executeUpdate(
            deleteSQL,
            values: [
                book.id
            ]
        )
    }
}
