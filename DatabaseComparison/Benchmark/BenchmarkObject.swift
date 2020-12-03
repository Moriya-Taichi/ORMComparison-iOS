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
    let realtionObject: SimplyObject
}

struct OneToManyObject: Codable, FetchableRecord, PersistableRecord {
    let id: Int
    let name: String
    let relationObjects: [SimplyObject]
}

final class RealmObject {
    final class SimplyObject: Object {
        @objc dynamic var id: Int = 0
        @objc dynamic var name: String = ""

        static override func primaryKey() -> String? {
            return "id"
        }
    }

    final class OneToOneObject: Object {
        @objc dynamic var id: Int = 0
        @objc dynamic var name: String = ""
        @objc dynamic var relationObject: SimplyObject?

        static override func primaryKey() -> String? {
            return "id"
        }
    }

    final class OneToManyObject: Object {
        @objc dynamic var id: Int = 0
        @objc dynamic var name: String = ""
        let relationObjects = List<SimplyObject>()

        static override func primaryKey() -> String? {
            return "id"
        }
    }
}

extension GRDBObject {
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
        static let parentObject = belongsTo(OneToOneObject.self)
        var parentObject: QueryInterfaceRequest<OneToOneObject> {
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

