import Foundation

final class FMDBBookTagStore {

    let databaseWrapper: FMDBDatabaseWrapeer

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS book_tags (" +
        "id INTEGER PRIMARY KEY, " +
        "name TEXT, " +
        "price INTEGER, " +
        "publisher_id TEXT" +
      ");"

    private let insertSQL =
        "INSERT INTO " +
        "book_tags (name, price, publisher_id) " +
        "VALUES " +
        "(?, ?, ?);"

    private let selectSQL =
        "SELECT " +
        "id, name, age, profile " +
        "FROM " +
        "book_tags;" +
        "ORDER BY name;"

    private let updateSQL =
        "UPDATE " +
        "book_tags " +
        "SET " +
        "name = ?, age = ?, profile = ? " +
        "WHERE " +
        "id = ?;"

    private let deleteSQL =
        "DELETE FROM book_tags WHERE id = ?;"

    init (databaseWrapper: FMDBDatabaseWrapeer) {
        self.databaseWrapper = databaseWrapper
        try? databaseWrapper.executeQuery(createTableSQL, values: [])
    }

    func create() {
        
    }

    func read() -> [String]? {
        var results: [String] = []
        if let result = try? databaseWrapper.executeQuery("", values: []) {
            while result.next() {
                let tag = result.string(forColumnIndex: 1) ?? ""
                results.append(tag)
            }
        }
        return results
    }

    func update() {

    }

    func delete() {

    }
}
