//
//  BenchmarkObject.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/27.
//

import RealmSwift
import GRDB

struct SimplyObject:
    Codable,
    FetchableRecord,
    PersistableRecord {
    let id: Int
    let name: String
}

final class SimplyRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""

    static override func primaryKey() -> String? {
        return "id"
    }
}

struct OneToOneObject:
    Codable,
    FetchableRecord,
    PersistableRecord {
    let id: Int
    let name: String
    let realtionObject: SimplyObject
}

struct OneToOneGRDBObject:
    Codable,
    FetchableRecord,
    PersistableRecord {
    let id: Int
    let name: String
    static let relationObject = hasOne(OneToOneChildGRDBObject.self)
    var relationObject: QueryInterfaceRequest<OneToOneChildGRDBObject> {
        request(for: Self.relationObject)
    }
}

struct OneToOneChildGRDBObject:
    Codable,
    FetchableRecord,
    PersistableRecord {
    let id: Int
    let name: String
    let oneToOneGRDBObjectId: Int
    static let parentObject = belongsTo(OneToOneGRDBObject.self)
    var parentObject: QueryInterfaceRequest<OneToOneGRDBObject> {
        request(for: Self.parentObject)
    }
}

final class OneToOneRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var relationObject: SimplyRealmObject?

    static override func primaryKey() -> String? {
        return "id"
    }
}

struct OneToManyObject: Codable, FetchableRecord, PersistableRecord {
    let id: Int
    let name: String
    let relationObjects: [SimplyObject]
}

struct OneToManyGRDBObject: Codable, FetchableRecord, PersistableRecord {
    let id: Int
    let name: String

    static let relationObjects = hasMany(OneToManyChildGRDBObject.self)
    var relationObjects: QueryInterfaceRequest<OneToManyChildGRDBObject> {
        request(for: Self.relationObjects)
    }
}

struct OneToManyChildGRDBObject: Codable, FetchableRecord, PersistableRecord {
    let id: Int
    let name: String

    static let parentObject = belongsTo(OneToManyGRDBObject.self)
    var parentObject: QueryInterfaceRequest<OneToManyGRDBObject> {
        request(for: Self.parentObject)
    }
}

final class OneToManyRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    let relationObjects = List<SimplyRealmObject>()

    static override func primaryKey() -> String? {
        return "id"
    }
}


