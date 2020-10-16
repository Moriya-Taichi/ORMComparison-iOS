import Foundation
import FMDB

struct FMDBTestObject {
    let id: Int
    let name: String
    let age: Int
    let profile: String
    let position: String
}

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

final class FmdbStore {

    private let wrapper: DatabaseWrapper

    private let createTableSQL =
        "CREATE TABLE IF NOT EXISTS test_object (" +
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

    func create(object: FMDBTestObject) {
        try? wrapper.database.executeUpdate(
            insertSQL,
            values: [
                object.name,
                object.age,
                object.profile,
                object.position
            ]
        )
    }

    func read () -> [FMDBTestObject] {
        var objects: [FMDBTestObject] = []
        if
            let result = try? wrapper.database.executeQuery(
                selectSQL,
                values: nil
        ) {
            while result.next() {
                let object = FMDBTestObject(
                    id: result.long(forColumnIndex: 0),
                    name: result.string(forColumnIndex: 1) ?? "",
                    age: result.long(forColumnIndex: 2),
                    profile: result.string(forColumnIndex: 3) ?? "",
                    position: result.string(forColumnIndex: 4) ?? ""
                )
                objects.append(object)
            }
        }
        return objects
    }

    func update (object: FMDBTestObject) {
        try? wrapper.database.executeUpdate(
            updateSQL,
            values: [
                object.name,
                object.age,
                object.profile,
                object.position,
                object.id
            ]
        )
    }

    func delete (id: Int) {
        try? wrapper.database.executeUpdate(deleteSQL, values: [id])
    }


}
