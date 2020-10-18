
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

    func create(object: Book) {

    }

    func read() -> [Book] {
        var result: [Book] = []
        return result
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

    func update(object: Book) {

    }

    func delete(object: Book) {

    }
}
