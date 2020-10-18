import FMDB

final class FMDBDatabaseWrapeer {

    private let database: FMDatabase

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

    func executeQuery(_ sql: String, values: [Any]?) throws -> FMResultSet {
        database.open()
        let result = try database.executeQuery(sql, values: values)
        database.close()
        return result
    }

    func executeUpdate(_ sql: String, values: [Any]?) throws {
        database.open()
        try database.executeUpdate(sql, values: values)
        database.close()
    }
}
