import FMDB

final class FMDBOwnerStore: FMDBOwnerStoreType {

    let databaseWrapper: FMDBDatabaseWrapeer

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS owner (" +
        "id INTEGER PRIMARY KEY, " +
        "name TEXT, " +
        "age INTEGER, " +
        "profile TEXT" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "owner (name, age, profile) " +
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

    init(databaseWrapper: FMDBDatabaseWrapeer) {
        self.databaseWrapper = databaseWrapper
    }

    func create(object: Owner) {

    }

    func read() -> [Owner]? {

    }

    func update(object: Owner) {

    }

    func delete(object: Owner) {
        
    }
}
