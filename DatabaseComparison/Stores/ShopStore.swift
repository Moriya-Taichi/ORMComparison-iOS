//
//  ShopStore.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/10/16.
//

import Foundation

protocol Store {
    associatedtype StoredObjectType

    func create(object: StoredObjectType)
    func read() -> [StoredObjectType]?
    func update(object: StoredObjectType)
    func delete(object: StoredObjectType)
}

protocol ShopStore: Store where StoredObjectType == Shop {}
