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

    func readByIDs(_ ids: [Int]) -> [Owner]{
        var results: [Owner] = []
        let params = Array(repeating: "?", count: ids.count).joined(separator: ",")
        let query = "SELECT * FROM owners WHERE id IN (" + params + ");"
        if
            let result = try? databaseWrapper.executeQuery(
                query,
                values: ids
            ) {
            while result.next() {
                let owner = Owner(
                    id: result.long(forColumnIndex: 0),
                    name: result.string(forColumnIndex: 1) ?? "",
                    age: result.long(forColumnIndex: 2),
                    profile: result.string(forColumnIndex: 3) ?? ""
                )
                results.append(owner)
            }
        }
        return results
    }

    func update(object: Owner) {

    }

    func delete(object: Owner) {
        
    }
}
