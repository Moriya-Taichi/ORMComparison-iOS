import Foundation
import FMDB

final class DatabaseWrapper {

    let database: FMDatabase

    init () {
        let databasePath = try! FileManager.default
                .url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                .appendingPathComponent("test.sqlite")
        database = FMDatabase(url: databasePath)
        database.open()
    }

    deinit {
        database.close()
    }
}

final class FMDBShopStore: ShopStore {

    private let wrapper: DatabaseWrapper

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


    init (wrapper: DatabaseWrapper) {
        self.wrapper = wrapper
        try? wrapper.database.executeUpdate(createTableSQL, values: nil)
    }

    func create(object: Shop) {
        try? wrapper.database.executeUpdate(
            insertSQL,
            values: [
                object.identifier
            ]
        )
    }

    func read () -> [Shop]? {
        var objects: [Shop] = []
        if
            let result = try? wrapper.database.executeQuery(
                selectSQL,
                values: nil
        ) {
            while result.next() {

            }
        }
        return objects
    }

    func update (object: Shop) {
        try? wrapper.database.executeUpdate(
            updateSQL,
            values: [
            ]
        )
    }

    func delete(object: Shop) {
        try? wrapper.database.executeUpdate(deleteSQL, values: [])
    }
}
