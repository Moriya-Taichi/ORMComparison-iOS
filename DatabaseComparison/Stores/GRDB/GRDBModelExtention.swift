//
//  GRDBModelExtention.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/10/22.
//

import GRDB

struct GRDBStoredPublisher {
    let id: Int
    let name: String
    let ownerId: Int
}

extension GRDBStoredPublisher: MutablePersistableRecord, FetchableRecord  {

    enum Columns: String, ColumnExpression {
        case id, name, ownerId
    }

    init(row: Row) {
        id = row[0]
        name = row[1]
        ownerId = row[2]
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.ownerId] = ownerId
    }

    static let books = hasMany(Book.self)
    static let owner = belongsTo(Owner.self)

    var relationBooks: QueryInterfaceRequest<Book> {
        request(for: Self.books)
    }

    var relationOwner:QueryInterfaceRequest<Owner> {
        request(for: Self.owner)
    }
}

extension Book: MutablePersistableRecord, FetchableRecord {

    enum Columns: String, ColumnExpression {
        case id, name, price
    }

    init(row: Row) {
        id = row[0]
        name = row[1]
        price = row[2]
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

    init(row: Row) {
        id = row[0]
        name = row[1]
        age = row[2]
        profile = row[3]
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.age] = age
        container[Columns.profile] = profile
    }


}
