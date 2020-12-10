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

public final class Benchmarker {

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
    public func benchmarkInsertSimpleByCoreData() {
        let context = container.viewContext
        Array(0..<1000).forEach { index in
            let object = SimplyEntity(context: context)
            object.id = Int64(index)
            object.name = "simple object id" + String(index)
            context.insert(object)
        }
    }

    public func benchmarkInsertOneToOneByCoreData() {
        let context = container.viewContext
        Array(0..<1000).forEach { index in
            let object = OneToOneEntity(context: context)
            object.id = Int64(index)
            object.name = "one to one parent object id" + String(index)
            let childObject = SimplyEntity(context: context)
            childObject.id = Int64(index)
            childObject.name = "one to one child object id" + String(index)
            object.relationship = childObject
            context.insert(object)
        }
    }

    public func benchmarkInsertOneToManyByCoreData() {
        let context = container.viewContext
        Array(0..<1000).forEach { index in
            let object = OneToManyEntity(context: context)
            object.id = Int64(index)
            object.name = "one to many parent object id" + String(index)
            Array(0..<10).forEach { childIndex in
                let id = childIndex + index * 10
                let childObject = SimplyEntity(context: context)
                childObject.id = Int64(id)
                childObject.name = "one to many child object id" + String(id)
                object.addToRelationship(childObject)
            }
            context.insert(object)
        }
    }

    public func benchmarkInsertSimpleByGRDB() {
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

    public func benchmarkInsertOneToOneByGRDB() {
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

    public func benchmarkInsertOneToManyByGRDB() {
        try? databasePool.write { database in
            Array(0..<1000).forEach { index in
                let parentObject = GRDBObject.OneToManyObject(
                    id: index,
                    name: "one to many parent object id" + String(index)
                )
                try? parentObject.insert(database)

                Array(0..<10).forEach { childIndex in
                    let id = childIndex + index * 10
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

    public func benchmarkInsertSimpleByRealm() {
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

    public func benchmarkInsertOneToOneByRealm() {
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

    public func benchmarkInsertOneToManyByRealm() {
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

    public func benchmarkInsertSimpleByFMDB() {

    }

    public func benchmarkInsertOneToOneByFMDB() {

    }

    public func benchmarkInsertOneToManyByFMDB() {

    }

    public func clearRealm() {
        if realm.isInWriteTransaction {
            realm.delete(realm.objects(RealmObject.SimplyObject.self))
            realm.delete(realm.objects(RealmObject.OneToOneObject.self))
            realm.delete(realm.objects(RealmObject.OneToManyObject.self))
        } else {
            try? realm.write {
                realm.delete(realm.objects(RealmObject.SimplyObject.self))
                realm.delete(realm.objects(RealmObject.OneToOneObject.self))
                realm.delete(realm.objects(RealmObject.OneToManyObject.self))
            }
        }
    }

    public func clearCoreData() {
        let context = container.viewContext

        let simplyEntityRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
            entityName: String(describing: SimplyEntity.self)
        )
        let simplyEntitydeleteRequest = NSBatchDeleteRequest(fetchRequest: simplyEntityRequest)

        let oneToOneEntityRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
            entityName: String(describing: OneToOneEntity.self)
        )
        let oneToOneEntitydeleteRequest = NSBatchDeleteRequest(fetchRequest: oneToOneEntityRequest)

        let oneToManyEntityRequest: NSFetchRequest<NSFetchRequestResult> = NSFetchRequest(
            entityName: String(describing: OneToManyEntity.self)
        )
        let oneToManyEntitydeleteRequest = NSBatchDeleteRequest(fetchRequest: oneToManyEntityRequest)

        let _ = try? context.execute(simplyEntitydeleteRequest)
        let _ = try? context.execute(oneToOneEntitydeleteRequest)
        let _ = try? context.execute(oneToManyEntitydeleteRequest)
    }

    public func clearGRDB() {
        try? databasePool.write { database in
            let _ = try? GRDBObject.OneToManyObject.deleteAll(database)
            let _ = try? GRDBObject.OneToOneObject.deleteAll(database)
            let _ = try? SimplyObject.deleteAll(database)
        }
    }

    public func clearFMDB() {

    }
}

extension Benchmarker {
    public func benchmarkReadSimpleByCoreData() {
        let context = container.viewContext
        let request: NSFetchRequest<SimplyEntity> = SimplyEntity.fetchRequest()
        let objects = try? context.fetch(request)
    }

    public func benchmarkReadOneToOneByCoreData() {
        let context = container.viewContext
        let request: NSFetchRequest<OneToOneEntity> = OneToOneEntity.fetchRequest()
        let objects = try? context.fetch(request)
    }

    public func benchmarkReadOneToManyByCoreData() {
        let context = container.viewContext
        let request: NSFetchRequest<OneToManyEntity> = OneToManyEntity.fetchRequest()
        let objects = try? context.fetch(request)
    }

    public func benchmarkReadSimpleByGRDB() {
        let objects = try? databasePool.read { database in
            return try? SimplyObject.fetchAll(database)
        }
    }

    public func benchmarkReadOneToOneByGRDB() {
        let objects = try? databasePool.read { database in
            return try? GRDBObject.OneToOneObject.fetchAll(database)
        }
    }

    public func benchmarkReadOneToManyByGRDB() {
        let objects = try? databasePool.read { database in
            return try? GRDBObject.OneToManyObject.fetchAll(database)
        }
    }

    public func benchmarkReadSimpleByRealm() {
        let objects = realm.objects(RealmObject.SimplyObject.self)
    }

    public func benchmarkReadOneToOneByRealm() {
        let objects = realm.objects(RealmObject.OneToOneObject.self)
    }

    public func benchmarkReadOneToManyByRealm() {
        let objects = realm.objects(RealmObject.OneToManyObject.self)
    }

    public func benchmarkReadSimpleByFMDB() {

    }

    public func benchmarkReadOneToOneByFMDB() {

    }

    public func benchmarkReadOneToManyByFMDB() {

    }
}