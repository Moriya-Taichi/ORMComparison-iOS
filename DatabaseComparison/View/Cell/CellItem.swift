//
//  CellItem.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/24.
//

import Foundation

enum Section {
    case orm
    case publisher
    case book
}

enum ORMType: Hashable {
    case userDefaults
    case coredata
    case realm
    case grdb
    case fmdb
}

enum CellItem: Hashable {
    case publisher(Publisher)
    case book(Book)
}
