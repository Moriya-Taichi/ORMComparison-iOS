//
//  GRDBModelExtension.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/10/22.
//

import GRDB

extension Book: MutablePersistableRecord, FetchableRecord {

    enum Columns: String, ColumnExpression {
        case id, name, price
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.price] = price
    }
}

extension Owner: MutablePersistableRecord, FetchableRecord {

    enum Columns: String, ColumnExpression {
        case id, name, age, profile
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.age] = age
        container[Columns.profile] = profile
    }


}
