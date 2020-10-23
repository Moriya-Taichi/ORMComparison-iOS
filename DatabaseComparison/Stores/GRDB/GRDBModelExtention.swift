//
//  GRDBModelExtension.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/10/22.
//

import GRDB

struct GRDBStoredPublisher: Decodable {
    let id: Int
    let name: String
    let ownerId: Int
}

struct GRDBStoredBook: Decodable {
    let id: Int
    let name: String
    let price: Int
    let publisherId: Int
}

extension Publisher: FetchableRecord { }

extension GRDBStoredBook: MutablePersistableRecord, FetchableRecord {
    enum Columns: String, ColumnExpression {
        case id, name, price, publisherId
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.price] = price
        container[Columns.publisherId] = publisherId
    }

    static let publisher = belongsTo(GRDBStoredPublisher.self)
    var publisher: QueryInterfaceRequest<GRDBStoredPublisher> {
        request(for: GRDBStoredBook.publisher)
    }
}

extension GRDBStoredPublisher: MutablePersistableRecord, FetchableRecord  {

    enum Columns: String, ColumnExpression {
        case id, name, ownerId
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.ownerId] = ownerId
    }

    static let books = hasMany(GRDBStoredBook.self)
    static let owner = belongsTo(Owner.self)

    var books: QueryInterfaceRequest<GRDBStoredBook> {
        request(for: Self.books)
    }

    var owner:QueryInterfaceRequest<Owner> {
        request(for: Self.owner)
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

    static let publishers = hasMany(GRDBStoredPublisher.self)
    var publishers: QueryInterfaceRequest<GRDBStoredPublisher> {
        request(for: Owner.publishers)
    }
}
