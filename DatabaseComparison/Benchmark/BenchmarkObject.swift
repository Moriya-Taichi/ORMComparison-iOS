//
//  BenchmarkObject.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/27.
//

import RealmSwift
import GRDB

struct BenchmarkSimplyObject: Codable {
    let id: Int
    let name: String
}

final class BenchmarkSimplyRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""

    static override func primaryKey() -> String? {
        return "id"
    }
}

struct BenchmarkOneToOneObject: Codable {
    let id: Int
    let name: String
    let realtionObject: BenchmarkSimplyObject
}

final class BenchmarkOneToOneRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    @objc dynamic var relationObject: BenchmarkSimplyRealmObject?

    static override func primaryKey() -> String? {
        return "id"
    }
}

struct BenchmarkOneToManyObject: Codable {
    let id: Int
    let name: String
    let relationObjects: [BenchmarkSimplyObject]
}

final class BenchmarkOneToManyRealmObject: Object {
    @objc dynamic var id: Int = 0
    @objc dynamic var name: String = ""
    let relationObjects = List<BenchmarkSimplyRealmObject>()

    static override func primaryKey() -> String? {
        return "id"
    }
}


