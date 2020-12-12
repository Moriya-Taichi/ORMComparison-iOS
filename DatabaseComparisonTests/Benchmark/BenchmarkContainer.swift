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
    private static let container = NSPersistentContainer(name: "DatabaseComparison")
    private static let realmURL = try! FileManager
        .default
        .url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("realmBenchmark.realm")
    private static let realmConfiguration = Realm.Configuration(
        fileURL: realmURL,
        schemaVersion: 1,
        deleteRealmIfMigrationNeeded: true,
        objectTypes: [
            SimplyRealmObject.self,
            OneToOneRealmObject.self,
            OneToManyRealmObject.self
        ]
    )
    private static let realm = try! Realm(configuration: realmConfiguration)
    private static let grdbURL = try! FileManager
        .default
        .url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("grdbBenchmark.sqlite")
    private static let databasePool = try! DatabasePool(path: grdbURL.path)
    private static let fmDatabasePath = try! FileManager.default
        .url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("fmbenchmark.sqlite")
    private static let fmDatabasePool = FMDatabasePool(path: fmDatabasePath.path)
    public static let benchmarker = Benchmarker(
        fmDatabasePool: fmDatabasePool,
        databasePool: databasePool,
        userDefaults: .standard,
        container: container,
        realm: realm
    )
}
