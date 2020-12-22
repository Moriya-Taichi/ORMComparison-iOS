//
//  Benchmarker.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/27.
//

import DatabaseComparison
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

    typealias SimplyEntity = DatabaseComparison.SimplyEntity
    typealias OneToOneEntity = DatabaseComparison.OneToOneEntity
    typealias OneToManyEntity = DatabaseComparison.OneToManyEntity

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

        let parentTableSQL = "CREATE TABLE IF NOT EXISTS parents (id INTEGER PRIMARY KEY, name TEXT);"
        let childTableSQL = "CREATE TABLE IF NOT EXISTS children (id INTEGER PRIMARY KEY, name TEXT, parent_id INTEGER, foreign key(parent_id) references parents(id));"

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

            try? database.execute(sql: parentTableSQL)
            try? database.execute(sql: childTableSQL)
        }

        fmDatabasePool.inDatabase { fmDatabase in
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

        container.loadPersistentStores { _, _ in }
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

    public func benchmarkInsertSimpleByGRDBSQL() {
        let sql = "INSERT INTO parents (id, name) VALUES " +
            Array(repeating: "(?, ?)", count: 1000).joined(separator: ",") +
            ";"
        try? databasePool.write { database in
            try? database.execute(
                sql: sql,
                arguments: .init(
                    Array(0..<1000)
                        .map { index -> [DatabaseValueConvertible] in
                            return [
                                index,
                                "simple object id" + String(index)
                            ]
                        }
                        .flatMap { $0 }
                )
            )
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

    public func benchmarkInsertOneToOneByGRDBSQL() {
        let parentSQL = "INSERT INTO parents (id, name) VALUES " +
            Array(
                repeating: "(?, ?)",
                count: 1000
            )
            .joined(separator: ",") +
            ";"
        let childSQL = "INSERT INTO children (id, name, parent_id) VALUES " +
            Array(
                repeating: "(?, ?, ?)",
                count: 1000
            )
            .joined(separator: ",") +
            ";"
        try? databasePool.write { database in
            try? database.execute(
                sql: parentSQL,
                arguments: .init(
                    Array(0..<1000)
                        .map { index -> [DatabaseValueConvertible] in
                            return [
                                index,
                                "simple object id" + String(index)
                            ]
                        }
                        .flatMap { $0 }
                )
            )

            try? database.execute(
                sql: childSQL,
                arguments: .init(
                    Array(0..<1000)
                        .map { index -> [DatabaseValueConvertible] in
                            return [
                                index,
                                "child object id" + String(index),
                                index
                            ]
                        }
                        .flatMap { $0 }
                )
            )
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
                let object = SimplyRealmObject()
                object.id = index
                object.name = "simple object id" + String(index)
                try? realm.add(object)
            }
        } else {
            try? realm.write {
                Array(0..<1000).forEach { index in
                    let object = SimplyRealmObject()
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
                let object = OneToOneRealmObject()
                object.id = index
                object.name = "one to one parent object id" + String(index)
                let childObject = SimplyRealmObject()
                childObject.id = index
                childObject.name = "one to one child object id" + String(index)
                object.relationObject = childObject
                try? realm.add(object)
            }
        } else {
            try? realm.write {
                Array(0..<1000).forEach { index in
                    let object = OneToOneRealmObject()
                    object.id = index
                    object.name = "one to one parent object id" + String(index)
                    let childObject = SimplyRealmObject()
                    childObject.id = index
                    childObject.name = "one to one child object id" + String(index)
                    object.relationObject = childObject
                    try? realm.add(object)
                }
            }
        }
    }

    public func benchmarkInsertOneToManyByRealm() {
        if realm.isInWriteTransaction {
            Array(0..<1000).forEach { index in
                let object = OneToManyRealmObject()
                object.id = index
                object.name = "one to many parent object id" + String(index)
                Array(0..<10).forEach { childIndex in
                    let id = childIndex + index * 10
                    let childObject = SimplyRealmObject()
                    childObject.id = id
                    childObject.name = "one to many child object id" + String(id)
                    object.relationObjects.append(childObject)
                }
                try? realm.add(object)
            }
        } else {
            try? realm.write {
                Array(0..<1000).forEach { index in
                    let object = OneToManyRealmObject()
                    object.id = index
                    object.name = "one to many parent object id" + String(index)
                    Array(0..<10).forEach { childIndex in
                        let id = childIndex + index * 10
                        let childObject = SimplyRealmObject()
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
        fmDatabasePool.inDatabase { database in
            database.open()
            let sql = "INSERT INTO parents (id, name) VALUES " +
                Array(
                    repeating: "(?, ?)",
                    count: 1000
                )
                .joined(separator: ",") +
                ";"
            try? database.executeUpdate(
                sql,
                values: Array(0..<1000)
                    .map { index in
                        return [
                            index,
                            "simple object id" + String(index)
                        ]
                    }
                    .flatMap { $0 }
            )
            database.close()
        }
    }

    public func benchmarkInsertOneToOneByFMDB() {
        fmDatabasePool.inDatabase { database in
            database.open()
            let parentSql = "INSERT INTO parents (id, name) VALUES " +
                Array(
                    repeating: "(?, ?)",
                    count: 1000
                )
                .joined(separator: ",") +
                ";"
            let childSql = "INSERT INTO children (id, name, parent_id) VALUES " +
                Array(
                    repeating: "(?, ?, ?)",
                    count: 1000
                )
                .joined(separator: ",") +
                ";"
            try? database.executeUpdate(
                parentSql,
                values: Array(0..<1000)
                    .map { index in
                        return [
                            index,
                            "simple object id" + String(index)
                        ]
                    }
                    .flatMap { $0 }
            )
            try? database.executeUpdate(
                childSql,
                values: Array(0..<1000)
                    .map { index in
                        return [
                            index,
                            "child object id" + String(index),
                            index
                        ]
                    }
                    .flatMap { $0 }
            )
            database.close()
        }
    }

    public func benchmarkInsertOneToManyByFMDB() {
        fmDatabasePool.inDatabase { database in
            database.open()
            let parentSql = "INSERT INTO parents (id, name) VALUES " +
                Array(
                    repeating: "(?, ?)",
                    count: 1000
                )
                .joined(separator: ",") +
                ";"
            let childSql = "INSERT INTO children (id, name, parent_id) VALUES " +
                Array(
                    repeating: "(?, ?, ?)",
                    count: 10000
                )
                .joined(separator: ",") +
                ";"
            try? database.executeUpdate(
                parentSql,
                values: Array(0..<1000)
                    .map { index in
                        return [
                            index,
                            "simple object id" + String(index)
                        ]
                    }
                    .flatMap { $0 }
            )

            try? database.executeUpdate(
                childSql,
                values: Array(0..<1000)
                    .map { index -> [Any] in
                        let children = Array(0..<10).map { childIndex -> [Any] in
                            let id = index * 10 + childIndex
                            return [
                                id,
                                "child object id" + String(id),
                                index
                            ]
                        }
                        .flatMap { $0 }
                        return children
                    }
                    .flatMap { $0 }
            )
            database.close()
        }
    }

    public func clearRealm() {
        if realm.isInWriteTransaction {
            realm.delete(realm.objects(SimplyRealmObject.self))
            realm.delete(realm.objects(OneToOneRealmObject.self))
            realm.delete(realm.objects(OneToManyRealmObject.self))
        } else {
            try? realm.write {
                realm.delete(realm.objects(SimplyRealmObject.self))
                realm.delete(realm.objects(OneToOneRealmObject.self))
                realm.delete(realm.objects(OneToManyRealmObject.self))
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
            let deleteParentsSQL = "DELETE FROM parents;"
            let deleteChildrentSQL = "DELETE FROM children;"
            try? GRDBObject.OneToManyObject.deleteAll(database)
            try? GRDBObject.OneToOneObject.deleteAll(database)
            try? SimplyObject.deleteAll(database)
            try? database.execute(sql: deleteChildrentSQL)
            try? database.execute(sql: deleteParentsSQL)
        }
    }

    public func clearFMDB() {
        let deleteParentsSQL = "DELETE FROM parents;"
        let deleteChildrentSQL = "DELETE FROM children;"
        fmDatabasePool.inDatabase { database in
            database.open()
            try? database.executeUpdate(deleteChildrentSQL, values: nil)
            try? database.executeUpdate(deleteParentsSQL, values: nil)
            database.close()
        }
    }
}

extension Benchmarker {
    public func benchmarkReadSimpleByCoreData() {
        let context = container.viewContext
        let request: NSFetchRequest<SimplyEntity> = SimplyEntity.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \SimplyEntity.id, ascending: true)]
        let objects = try? context.fetch(request)
    }

    public func benchmarkReadOneToOneByCoreData() {
        let context = container.viewContext
        let request: NSFetchRequest<OneToOneEntity> = OneToOneEntity.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \OneToOneEntity.id, ascending: true)]
        let objects = try? context.fetch(request)
    }

    public func benchmarkReadOneToManyByCoreData() {
        let context = container.viewContext
        let request: NSFetchRequest<OneToManyEntity> = OneToManyEntity.fetchRequest()
        request.sortDescriptors = [.init(keyPath: \OneToManyEntity.id, ascending: true)]
        let objects = try? context.fetch(request)
    }

    public func benchmarkReadSimpleByGRDB() {
        let objects = try? databasePool.read { database in
            return try? SimplyObject.fetchAll(database)
        }
    }

    public func benchmarkReadOneToOneByGRDB() {
        let objects = try? databasePool.read { database -> [OneToOneObject]? in
            let relationObject = GRDBObject.OneToOneObject.relationObject.forKey("relationObject")
            let request = GRDBObject.OneToOneObject
                .including(
                    required: relationObject
                )
            return try? OneToOneObject.fetchAll(database, request)
        }
    }

    public func benchmarkReadOneToManyByGRDB() {
        let objects = try? databasePool.read { database -> [OneToManyObject]? in
            let realtionObjects = GRDBObject.OneToManyObject.relationObjects.forKey("relationObjects")
            let request = GRDBObject.OneToManyObject
                .including(
                    all: realtionObjects
                )
            return try? OneToManyObject.fetchAll(database, request)
        }
    }

    public func benchmarkReadSimpleByRealm() {
        let objects = realm.objects(SimplyRealmObject.self)
    }

    public func benchmarkReadOneToOneByRealm() {
        let objects = realm.objects(OneToOneRealmObject.self)
    }

    public func benchmarkReadOneToManyByRealm() {
        let objects = realm.objects(OneToManyRealmObject.self)
    }

    public func benchmarkReadSimpleByFMDB() {
        var objects: [SimplyObject] = []
        let sql = "SELECT * FROM parents;"
        fmDatabasePool.inDatabase { database in
            database.open()
            if let result = try? database.executeQuery(sql, values: nil) {
                while result.next() {
                    let object = SimplyObject(
                        id: Int(result.int(forColumnIndex: 0)),
                        name: result.string(forColumnIndex: 1) ?? ""
                    )
                    objects.append(object)
                }
            }
            database.close()
        }
    }

    public func benchmarkReadOneToOneByFMDB() {
        var objects: [OneToOneObject] = []
        let sql = "SELECT parents.id, parents.name, children.id, children.name FROM parents LEFT JOIN children ON parents.id == children.parent_id;"
        fmDatabasePool.inDatabase { database in
            database.open()
            if let result = try? database.executeQuery(sql, values: nil) {
                while result.next() {
                    let childObject = SimplyObject(
                        id: Int(result.int(forColumnIndex: 2)),
                        name: result.string(forColumnIndex: 3) ?? ""
                    )
                    let parentObject = OneToOneObject(
                        id: Int(result.int(forColumnIndex: 0)),
                        name: result.string(forColumnIndex: 1) ?? "",
                        relationObject: childObject
                    )

                    objects.append(parentObject)
                }
            }
            database.close()
        }
    }

    public func benchmarkReadOneToManyByFMDB() {
        var objects: [OneToManyObject] = []
        let sql = "SELECT parents.id, parents.name, children.id, children.name FROM parents LEFT JOIN children ON parents.id == children.parent_id;"
        fmDatabasePool.inDatabase { database in
            database.open()
            if let result = try? database.executeQuery(sql, values: nil) {
                var childrenObject: [SimplyObject] = []
                var currentParent = OneToManyObject(
                    id: 0,
                    name: "",
                    relationObjects: []
                )
                while result.next() {
                    if Int(result.int(forColumnIndex: 0)) != currentParent.id {
                        let parentObject = OneToManyObject(
                            id: currentParent.id,
                            name: currentParent.name,
                            relationObjects: childrenObject
                        )
                        childrenObject = []
                        objects.append(parentObject)
                    }

                    currentParent = OneToManyObject(
                        id: Int(result.int(forColumnIndex: 0)),
                        name: result.string(forColumnIndex: 1) ?? "",
                        relationObjects: []
                    )
                    let childObject = SimplyObject(
                        id: Int(result.int(forColumnIndex: 2)),
                        name: result.string(forColumnIndex: 3) ?? ""
                    )
                    childrenObject.append(childObject)
                }
                let parentObject = OneToManyObject(
                    id: currentParent.id,
                    name: currentParent.name,
                    relationObjects: childrenObject
                )
                objects.append(parentObject)
            }
            database.close()
        }
    }
}
