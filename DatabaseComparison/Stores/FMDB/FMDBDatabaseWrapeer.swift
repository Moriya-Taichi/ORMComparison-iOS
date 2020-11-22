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

    func executeUpdate(_ sql: String, withArgumentsIn: [Any]) -> Bool {
        database.open()
        let isSucceed = database.executeUpdate(sql, withArgumentsIn: withArgumentsIn)
        database.close()
        return isSucceed
    }

    func executeUpdateWithoutOpen(_ sql: String, values: [Any]?) throws {
        if database.isOpen {
            try database.executeUpdate(sql, values: values)
        }
    }

    func executeBlockWithTransaction( _ block: @escaping () -> Void) {
        database.open()
        if database.beginTransaction() {
            block()
            database.commit()
        }
        database.close()
    }
}
