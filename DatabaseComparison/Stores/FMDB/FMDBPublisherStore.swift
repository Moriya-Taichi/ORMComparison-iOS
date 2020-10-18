import FMDB

final class FMDBPublisherStore {

    private let databaseWrapper: FMDBDatabaseWrapeer
    private let bookStore: FMDBBookStore
    private let ownerStore: FMDBOwnerStore

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS publishers (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "name TEXT, " +
        "owner_id INTEGER" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "publishers (name, owner_id) " +
        "VALUES " +
        "(?, ?);"

    private let selectSQL =
        "SELECT " +
        "id, name, owner_id " +
        "FROM " +
        "publishers;" +
        "ORDER BY name;"

    private let updateSQL =
        "UPDATE " +
        "publishers " +
        "SET " +
        "name = ?, owner_id = ? " +
        "WHERE " +
        "id = ?;"

    private let deleteSQL =
        "DELETE FROM publishers WHERE id = ?;"


    init (
        databaseWrapper: FMDBDatabaseWrapeer,
        bookStore: FMDBBookStore,
        ownerStore: FMDBOwnerStore
    ) {
        self.databaseWrapper = databaseWrapper
        self.bookStore = bookStore
        self.ownerStore = ownerStore
        try? databaseWrapper
            .executeUpdate(createTableSQL, values: nil)
    }

    func create(object: Publisher) {
        try? databaseWrapper
            .executeUpdate(
            insertSQL,
            values: [
            ]
        )
    }

    func read () -> [Publisher]? {
        var objects: [Publisher] = []
        if
            let result = try? databaseWrapper
                .executeQuery(
                selectSQL,
                values: nil
        ) {
            while result.next() {

            }
        }
        return objects
    }

    func update (object: Publisher) {
        try? databaseWrapper
            .executeUpdate(
            updateSQL,
            values: [
            ]
        )
    }

    func delete(object: Publisher) {
        try? databaseWrapper.executeUpdate(deleteSQL, values: [])
    }
}
