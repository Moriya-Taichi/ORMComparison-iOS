import FMDB

final class FMDBOwnerStore {

    let databaseWrapper: FMDBDatabaseWrapeer

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS owners (" +
        "id INTEGER PRIMARY KEY, " +
        "name TEXT, " +
        "age INTEGER, " +
        "profile TEXT" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "owners (name, age, profile) " +
        "VALUES " +
        "(?, ?, ?);"

    private let selectSQL =
        "SELECT " +
        "id, name, age, profile " +
        "FROM " +
        "owners;" +
        "ORDER BY name;"

    private let updateSQL =
        "UPDATE " +
        "owners " +
        "SET " +
        "name = ?, age = ?, profile = ? " +
        "WHERE " +
        "id = ?;"

    private let deleteSQL =
        "DELETE FROM owners WHERE id = ?;"

    init(databaseWrapper: FMDBDatabaseWrapeer) {
        self.databaseWrapper = databaseWrapper
    }

    func create(object: Owner) {

    }

    func read() -> [Owner] {
        var result: [Owner] = []
        return result
    }

    func update(object: Owner) {

    }

    func delete(object: Owner) {
        
    }
}
