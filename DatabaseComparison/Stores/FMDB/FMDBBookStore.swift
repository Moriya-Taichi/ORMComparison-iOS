
import FMDB

final class FMDBBookStore {

    private let databaseWrapper: FMDBDatabaseWrapeer
    private let bookTagStore: FMDBBookTagStore

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS books (" +
        "id INTEGER PRIMARY KEY, " +
        "name TEXT, " +
        "price INTEGER, " +
        "publisher_id TEXT" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "owner (name, price, publisher_id) " +
        "VALUES " +
        "(?, ?, ?);"

    private let selectSQL =
        "SELECT " +
        "id, name, age, profile " +
        "FROM " +
        "owner;" +
        "ORDER BY name;"

    private let updateSQL =
        "UPDATE " +
        "owner " +
        "SET " +
        "name = ?, age = ?, profile = ? " +
        "WHERE " +
        "id = ?;"

    private let deleteSQL =
        "DELETE FROM owner WHERE id = ?;"

    init(
        databaseWrapper: FMDBDatabaseWrapeer,
        bookTagStore: FMDBBookTagStore
    ) {
        self.databaseWrapper = databaseWrapper
        self.bookTagStore = bookTagStore
    }

    func create(object: Book) {

    }

    func read() -> [Book] {
        var result: [Book] = []
        return result
    }

    func update(object: Book) {

    }

    func delete(object: Book) {

    }
}
