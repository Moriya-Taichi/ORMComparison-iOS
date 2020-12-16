//
//  Container.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/23.
//

import RealmSwift
import Foundation
import CoreData
import GRDB
import FMDB

struct Container {
    private static let coredataContainer = NSPersistentContainer(name: "DatabaseComparison")
    private static let realmConfiguration = Realm.Configuration(
        schemaVersion: 1,
        migrationBlock: nil,
        deleteRealmIfMigrationNeeded: false
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
        .appendingPathComponent("grdbDatabase.sqlite")
    private static let grdbDatabaseQueue = try! DatabaseQueue(path: grdbURL.path)
    static let grdbPublisherStore = GRDBPublisherStore(databaseQueue: grdbDatabaseQueue)
    private static let fmDatabaseURL = try! FileManager.default
        .url(
            for: .applicationSupportDirectory,
            in: .userDomainMask,
            appropriateFor: nil,
            create: true
        )
        .appendingPathComponent("fmDatabase.sqlite")
    private static let fmDatabaseQueue = FMDatabaseQueue(path: fmDatabaseURL.path)!
    static let fmdbPublisherStore = FMDBPublisherStore(
        fmDatabaseQueue: fmDatabaseQueue
    )

    static let coredataStore = CoreDataPublisherStore(container: coredataContainer)
    static let realmStore = RealmPublisherStore(realm: realm)
    static let userDefaultsStore = UserDefaultsStore()
}
