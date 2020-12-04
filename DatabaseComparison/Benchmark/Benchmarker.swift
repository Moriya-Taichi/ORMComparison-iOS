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
        try? databasePool.write { database in
            Array(0..<1000).forEach { index in
                let simpleObject = SimplyObject(
                    id: index,
                    name: "simple object id" + String(index)
                )
                try? simpleObject.insert(database)
            }
        }
    }

    func benchmarkInsertOneToOneByGRDB() {
        try? databasePool.write { database in
            Array(0..<1000).forEach { index in
                let parentObject = GRDBObject.OneToOneObject(
                    id: index,
                    name: "one to one parent object id" + String(index)
                )

                let childObject = GRDBObject.OneToOneChildObject(
                    id: index,
                    name: "one to one child object id" + String(index),
                    oneToOneObjectId: index
                )

                try? parentObject.insert(database)
                try? childObject.insert(database)
            }
        }
    }

    func benachmarkInsertOneToManyByGRDB() {
        try? databasePool.write { database in
            Array(0..<1000).forEach { index in
                let parentObject = GRDBObject.OneToManyObject(
                    id: index,
                    name: "one to many parent object id" + String(index)
                )
                try? parentObject.insert(database)

                Array(0..<10).forEach { childObjectIndex in
                    let id = childObjectIndex + index * 10
                    let childObject = GRDBObject
                        .OneToManyChildObject(
                            id: id,
                            name: "one to many child object id" + String(id),
                            oneToManyObjectId: index
                        )
                    try? childObject.insert(database)
                }
            }
        }
    }

    func benchmarkInsertSimpleByRealm() {
        if realm.isInWriteTransaction {
            Array(0..<1000).forEach { index in
                let object = RealmObject.SimplyObject()
                object.id = index
                object.name = "simple object id" + String(index)
                try? realm.add(object)
            }
        } else {
            try? realm.write {
                Array(0..<1000).forEach { index in
                    let object = RealmObject.SimplyObject()
                    object.id = index
                    object.name = "simple object id" + String(index)
                    try? realm.add(object)
                }
            }
        }
    }

    func benchmarkInsertOneToOneByRealm() {
        if realm.isInWriteTransaction {
            Array(0..<1000).forEach { index in
                let object = RealmObject.OneToOneObject()
                object.id = index
                object.name = "one to one parent object id" + String(index)
                let childObject = RealmObject.SimplyObject()
                object.id = index
                object.name = "one to one child object id" + String(index)
                object.relationObject = childObject
                try? realm.add(object)
            }
        } else {
            try? realm.write {
                Array(0..<1000).forEach { index in
                    let object = RealmObject.OneToOneObject()
                    object.id = index
                    object.name = "one to one parent object id" + String(index)
                    let childObject = RealmObject.SimplyObject()
                    object.id = index
                    object.name = "one to one child object id" + String(index)
                    object.relationObject = childObject
                    try? realm.add(object)
                }
            }
        }
    }

    func benachmarkInsertOneToManyByRealm() {
        if realm.isInWriteTransaction {
            Array(0..<1000).forEach { index in
                let object = RealmObject.OneToManyObject()
                object.id = index
                object.name = "one to many parent object id" + String(index)
                Array(0..<10).forEach { childIndex in
                    let id = childIndex + index * 10
                    let childObject = RealmObject.SimplyObject()
                    childObject.id = id
                    childObject.name = "one to many child object id" + String(id)
                    object.relationObjects.append(childObject)
                }
                try? realm.add(object)
            }
        } else {
            try? realm.write {
                Array(0..<1000).forEach { index in
                    let object = RealmObject.OneToManyObject()
                    object.id = index
                    object.name = "one to many child object id" + String(index)
                    Array(0..<10).forEach { childIndex in
                        let id = childIndex + index * 10
                        let childObject = RealmObject.SimplyObject()
                        childObject.id = id
                        childObject.name = "one to many child object id" + String(id)
                        object.relationObjects.append(childObject)
                    }
                    try? realm.add(object)
                }
            }
        }
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
