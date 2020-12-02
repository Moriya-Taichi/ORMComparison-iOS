//
//  GRDBModelExtension.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/10/22.
//

import GRDB

final class GRDBObject {
    struct Publisher: Decodable {
        let id: Int
        let name: String
        let ownerId: Int
    }

    struct Book: Decodable {
        let id: Int
        let name: String
        let price: Int
        let publisherId: Int
    }
}

extension Publisher: FetchableRecord { }

extension GRDBObject.Book: MutablePersistableRecord, FetchableRecord {
    enum Columns: String, ColumnExpression {
        case id, name, price, publisherId
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.price] = price
        container[Columns.publisherId] = publisherId
    }

    static let publisher = belongsTo(GRDBObject.Publisher.self)
    var publisher: QueryInterfaceRequest<GRDBObject.Publisher> {
        request(for: Self.publisher)
    }
}

extension GRDBObject.Publisher: MutablePersistableRecord, FetchableRecord  {

    enum Columns: String, ColumnExpression {
        case id, name, ownerId
    }

    func encode(to container: inout PersistenceContainer) {
        container[Columns.id] = id
        container[Columns.name] = name
        container[Columns.ownerId] = ownerId
    }

    static let books = hasMany(GRDBObject.Book.self)
    static let owner = belongsTo(Owner.self)

    var books: QueryInterfaceRequest<GRDBObject.Book> {
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

    static let publishers = hasMany(GRDBObject.Publisher.self)
    var publishers: QueryInterfaceRequest<GRDBObject.Publisher> {
        request(for: Owner.publishers)
    }
}
