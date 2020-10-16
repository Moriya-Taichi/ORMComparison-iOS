import FMDB

final class FMDBShopStore: FMDBShopStoreType {

    let databaseWrapper: FMDBDatabaseWrapeer

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS shop (" +
        "id INTEGER PRIMARY KEY AUTOINCREMENT, " +
        "name TEXT, " +
        "age INTEGER, " +
        "profile TEXT," +
        "position TEXT" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "test_object (name, age, profile, position) " +
        "VALUES " +
        "(?, ?, ?, ?);"

    private let selectSQL =
        "SELECT " +
        "id, name, age, profile, position " +
        "FROM " +
        "test_object;" +
        "ORDER BY name;"

    private let updateSQL =
        "UPDATE " +
        "test_object " +
        "SET " +
        "name = ?, age = ?, profile = ?, position = ? " +
        "WHERE " +
        "id = ?;"

    private let deleteSQL =
        "DELETE FROM test_object WHERE id = ?;"


    init (databaseWrapper: FMDBDatabaseWrapeer) {
        self.databaseWrapper = databaseWrapper
        try? databaseWrapper
            .database
            .executeUpdate(createTableSQL, values: nil)
    }

    func create(object: Shop) {
        try? databaseWrapper
            .database
            .executeUpdate(
            insertSQL,
            values: [
                object.identifier
            ]
        )
    }

    func read () -> [Shop]? {
        var objects: [Shop] = []
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

    func update (object: Shop) {
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
