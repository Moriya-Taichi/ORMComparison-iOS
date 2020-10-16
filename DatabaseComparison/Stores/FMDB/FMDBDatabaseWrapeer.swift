//
//  FMDBDatabaseWrapeer.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/10/16.
//

import FMDB

final class FMDBDatabaseWrapeer {

    let database: FMDatabase

    init () {
        let databasePath = try! FileManager.default
                .url(
                    for: .applicationSupportDirectory,
                    in: .userDomainMask,
                    appropriateFor: nil,
                    create: true
                )
                .appendingPathComponent("test.sqlite")
        database = FMDatabase(url: databasePath)
        database.open()
    }

    deinit {
        database.close()
    }
}
