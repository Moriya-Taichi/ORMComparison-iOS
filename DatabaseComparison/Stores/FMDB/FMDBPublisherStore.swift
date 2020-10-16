import FMDB

final class FMDBPublisherStore: FMDBPublisherStoreType {

    let databaseWrapper: FMDBDatabaseWrapeer

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


    init (databaseWrapper: FMDBDatabaseWrapeer) {
        self.databaseWrapper = databaseWrapper
        try? databaseWrapper
            .database
            .executeUpdate(createTableSQL, values: nil)
    }

    func create(object: Publisher) {
        try? databaseWrapper
            .database
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
                .database
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
            .database
            .executeUpdate(
            updateSQL,
            values: [
            ]
        )
    }

    func delete(object: Publisher) {
        try? databaseWrapper.database.executeUpdate(deleteSQL, values: [])
    }
}
