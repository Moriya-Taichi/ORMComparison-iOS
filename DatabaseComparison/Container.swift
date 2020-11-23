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
    static let coredataContainer = NSPersistentContainer(name: "")
    private static let fmdbDatabaseWrapper = FMDBDatabaseWrapeer()
    private static let fmdbBookStore = FMDBBookStore(databaseWrapper: fmdbDatabaseWrapper)
    private static let fmdbOwnerStore = FMDBOwnerStore(databaseWrapper: fmdbDatabaseWrapper)
    static let fmdbPublisherStore = FMDBPublisherStore(
        databaseWrapper: fmdbDatabaseWrapper,
        bookStore: fmdbBookStore,
        ownerStore: fmdbOwnerStore
    )

    private static let grdbDatabaseQueue = try! DatabaseQueue(path: "")
    static let grdbPublisherStore = GRDBPublisherStore(databaseQueue: grdbDatabaseQueue)

    private static let realmConfiguration = Realm.Configuration(
        encryptionKey: "hogehoge".data(using: .utf8),
        schemaVersion: 1,
        migrationBlock: nil,
        deleteRealmIfMigrationNeeded: false
    )
    static let realm = try! Realm(configuration: realmConfiguration)
}
