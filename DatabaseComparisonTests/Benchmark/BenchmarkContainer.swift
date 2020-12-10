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

public struct BenchmarkContainer {
    private static let container = NSPersistentContainer(name: "benchmark")
    private static let realmConfiguration = Realm.Configuration(
        schemaVersion: 1,
        deleteRealmIfMigrationNeeded: true
    )
    private static let realm = try! Realm(configuration: realmConfiguration)
    private static let grdbDatabaseURL = try! FileManager
        .default
        .url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("grdbBenchmark.sqlite")
    private static let databasePool = try! DatabasePool(path: grdbDatabaseURL.path)
    private static let fmDatabasePool = FMDatabasePool(path: "/fmdbbenchmark.sqlite")
    public static let benchmarker = Benchmarker(
        fmDatabasePool: fmDatabasePool,
        databasePool: databasePool,
        userDefaults: .standard,
        container: container,
        realm: realm
    )
}
