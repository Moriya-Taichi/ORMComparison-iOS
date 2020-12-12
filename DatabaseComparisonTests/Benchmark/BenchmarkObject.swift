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

struct OneToOneObject:
    Codable,
    FetchableRecord,
    PersistableRecord {
    let id: Int
    let name: String
    let relationObject: SimplyObject
}

struct OneToManyObject: Codable, FetchableRecord, PersistableRecord {
    let id: Int
    let name: String
    let relationObjects: [SimplyObject]
}

final class SimplyRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""

    static override func primaryKey() -> String? {
        return "id"
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

final class OneToManyRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    let relationObjects = List<SimplyRealmObject>()

    static override func primaryKey() -> String? {
        return "id"
    }
}

struct GRDBObject {
    struct OneToOneObject:
        Codable,
        FetchableRecord,
        PersistableRecord {
        let id: Int
        let name: String
        static let relationObject = hasOne(OneToOneChildObject.self)
        var relationObject: QueryInterfaceRequest<OneToOneChildObject> {
            request(for: Self.relationObject)
        }
    }

    struct OneToOneChildObject:
        Codable,
        FetchableRecord,
        PersistableRecord {
        let id: Int
        let name: String
        let oneToOneObjectId: Int
        static let parentObject = belongsTo(GRDBObject.OneToOneObject.self)
        var parentObject: QueryInterfaceRequest<GRDBObject.OneToOneObject> {
            request(for: Self.parentObject)
        }
    }

    struct OneToManyObject: Codable, FetchableRecord, PersistableRecord {
        let id: Int
        let name: String

        static let relationObjects = hasMany(OneToManyChildObject.self)
        var relationObjects: QueryInterfaceRequest<OneToManyChildObject> {
            request(for: Self.relationObjects)
        }
    }

    struct OneToManyChildObject: Codable, FetchableRecord, PersistableRecord {
        let id: Int
        let name: String
        let oneToManyObjectId: Int

        static let parentObject = belongsTo(OneToManyObject.self)
        var parentObject: QueryInterfaceRequest<OneToManyObject> {
            request(for: Self.parentObject)
        }
    }
}

