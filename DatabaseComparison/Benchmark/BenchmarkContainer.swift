//
//  BenchmarkContainer.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/12/07.
//

import RealmSwift
import Foundation
import CoreData
import FMDB
import GRDB

struct BenchmarkContainer {
    private static let container = NSPersistentContainer(name: "benchmark")
    private static let realmConfiguration = Realm.Configuration(
        fileURL: .init(fileURLWithPath: "/realm/benchmark"),
        schemaVersion: 1,
        deleteRealmIfMigrationNeeded: true,
        objectTypes: [
            RealmObject.SimplyObject.self,
            RealmObject.OneToOneObject.self,
            RealmObject.OneToManyObject.self
        ]
    )
    private static let realm = try! Realm(configuration: realmConfiguration)
    private static let databasePool = try! DatabasePool(path: "/GRDB/benchmark")
    private static let fmDatabasePool = FMDatabasePool(path: "/FMDB/benchmark")
    static let benchmarker = Benchmarker(
        fmDatabasePool: fmDatabasePool,
        databasePool: databasePool,
        userDefaults: .standard,
        container: container,
        realm: realm
    )
}
