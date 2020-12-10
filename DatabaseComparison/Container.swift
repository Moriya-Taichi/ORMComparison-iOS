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

struct Container {
    private static let coredataContainer = NSPersistentContainer(name: "DatabaseComparison")
    private static let fmdbDatabaseWrapper = FMDBDatabaseWrapeer()
    private static let fmdbBookStore = FMDBBookStore(databaseWrapper: fmdbDatabaseWrapper)
    private static let fmdbOwnerStore = FMDBOwnerStore(databaseWrapper: fmdbDatabaseWrapper)
    private static let realmConfiguration = Realm.Configuration(
        encryptionKey: "hogehoge".data(using: .utf8),
        schemaVersion: 1,
        migrationBlock: nil,
        deleteRealmIfMigrationNeeded: false
    )
    private static let realm = try! Realm(configuration: realmConfiguration)
    private static let grdbDatabaseQueue = try! DatabaseQueue(path: "grdbDatabase.sqlite")
    static let grdbPublisherStore = GRDBPublisherStore(databaseQueue: grdbDatabaseQueue)
    static let fmdbPublisherStore = FMDBPublisherStore(
        databaseWrapper: fmdbDatabaseWrapper,
        bookStore: fmdbBookStore,
        ownerStore: fmdbOwnerStore
    )

    static let coredataStore = CoreDataPublisherStore(container: coredataContainer)
    static let realmStore = RealmPublisherStore(realm: realm)
    static let userDefaultsStore = UserDefaultsStore()
}
