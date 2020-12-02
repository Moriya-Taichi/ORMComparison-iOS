//
//  Benchmarker.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/27.
//

import RealmSwift
import CoreData
import GRDB
import FMDB

final class Benchmarker {

    private let fmDatabasePool: FMDatabasePool
    private let databasePool: DatabasePool
    private let userDefaults: UserDefaults
    private let container: NSPersistentContainer
    private let realm: Realm

    init(
        fmDatabasePool: FMDatabasePool,
        databasePool: DatabasePool,
        userDefaults: UserDefaults,
        container: NSPersistentContainer,
        realm: Realm
    ) {
        self.fmDatabasePool = fmDatabasePool
        self.databasePool = databasePool
        self.userDefaults = userDefaults
        self.container = container
        self.realm = realm

        try? databasePool.write { database in
            try? database.create(
                table: SimplyObject.databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer)
                    .notNull()
                    .indexed()
                table.column("name", .text).notNull()
                table.primaryKey(["id"])
            }

            try? database.create(
                table: GRDBObject
                    .OneToOneObject
                    .databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer)
                    .notNull()
                    .indexed()
                table.column("name", .text).notNull()
                table.primaryKey(["id"])
            }

            try? database.create(
                table: GRDBObject
                    .OneToOneChildObject
                    .databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer).notNull()
                table.column("name", .text).notNull()
                table.column("oneToOneObjectId", .integer)
                    .notNull()
                    .indexed()
                    .references(
                        GRDBObject
                            .OneToOneObject
                            .databaseTableName
                    )
                table.primaryKey(["id"])
            }

            try? database.create(
                table: GRDBObject
                    .OneToManyObject
                    .databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer)
                    .notNull()
                    .indexed()
                table.column("name", .text).notNull()
                table.primaryKey(["id"])
            }

            try? database.create(
                table: GRDBObject
                    .OneToManyChildObject
                    .databaseTableName,
                temporary: false,
                ifNotExists: true
            ) { table in
                table.column("id", .integer).notNull()
                table.column("name", .text).notNull()
                table.column("oneToManyObjectId", .integer)
                    .notNull()
                    .indexed()
                    .references(
                        GRDBObject
                            .OneToManyObject
                            .databaseTableName
                    )
                table.primaryKey(["id"])
            }
        }

        fmDatabasePool.inExclusiveTransaction { fmDatabase, _ in
            let parentTableSQL = "CREATE TABLE IF NOT EXISTS parents (id INTEGER PRIMARY KEY, name TEXT);"
            let childTableSQL = "CREATE TABLE IF NOT EXISTS children (id INTEGER PRIMARY KEY, name TEXT, parent_id INTEGER, foreign key(parent_id) references parent(id));"
            fmDatabase.open()
            try? fmDatabase.executeUpdate(
                parentTableSQL,
                values: nil
            )
            try? fmDatabase.executeUpdate(
                childTableSQL,
                values: nil
            )
            fmDatabase.close()
        }
    }
}

extension Benchmarker {
    func benchmarkInsertSimpleByCoreData() {

    }

    func benchmarkInsertOneToOneByCoreData() {

    }

    func benachmarkInsertOneToManyByCoreData() {

    }

    func benchmarkInsertSimpleByGRDB() {

    }

    func benchmarkInsertOneToOneByGRDB() {

    }

    func benachmarkInsertOneToManyByGRDB() {

    }

    func benchmarkInsertSimpleByRealm() {

    }

    func benchmarkInsertOneToOneByRealm() {

    }

    func benachmarkInsertOneToManyByRealm() {

    }

    func benchmarkInsertSimpleByFMDB() {

    }

    func benchmarkInsertOneToOneByFMDB() {

    }

    func benachmarkInsertOneToManyByFMDB() {

    }
}

extension Benchmarker {
    func benchmarkReadSimpleByCoreData() {

    }

    func benchmarkReadOneToOneByCoreData() {

    }

    func benchmarkReadOneToManyByCoreData() {

    }

    func benchmarkReadSimpleByGRDB() {

    }

    func benchmarkReadOneToOneByGRDB() {

    }

    func benchmarkReadOneToManyByGRDB() {

    }

    func benchmarkReadSimpleByRealm() {

    }

    func benchmarkReadOneToOneByRealm() {

    }

    func benchmarkReadOneToManyByRealm() {

    }

    func benchmarkReadSimpleByFMDB() {

    }

    func benchmarkReadOneToOneByFMDB() {

    }

    func benchmarkReadOneToManyByFMDB() {

    }
}
