//
//  GRDBMigrator.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/10/22.
//

import GRDB

final class GRDBMigrator {

    private var migrator = DatabaseMigrator()
    private let database: DatabaseQueue

    init (database: DatabaseQueue) {
        self.database = database
    }

    func migrate() {
        migrateV1()
        migrateV2()
        do {
            try migrator.migrate(database)
        }
        catch {
            print(error)
        }
    }

    private func migrateV1() {
        migrator.registerMigration("v1") { database in
            // something do on v1
        }
    }

    private func migrateV2() {

    }
}


