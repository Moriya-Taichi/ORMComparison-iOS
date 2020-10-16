import FMDB

final class FMDBPublisherStore: FMDBPublisherStoreType {

    let databaseWrapper: FMDBDatabaseWrapeer

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS shop (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "name TEXT, " +
        "owner_id INTEGER" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "shop (name, age, profile, position) " +
        "VALUES " +
        "(?, ?, ?, ?);"

    private let selectSQL =
        "SELECT " +
        "id, name, age, profile, position " +
        "FROM " +
        "shop;" +
        "ORDER BY name;"

    private let updateSQL =
        "UPDATE " +
        "shop " +
        "SET " +
        "name = ?, age = ?, profile = ?, position = ? " +
        "WHERE " +
        "id = ?;"

    private let deleteSQL =
        "DELETE FROM shop WHERE id = ?;"


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

    func delete(object: Shop) {
        try? databaseWrapper.database.executeUpdate(deleteSQL, values: [])
    }
}
