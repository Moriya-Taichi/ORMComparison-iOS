//
//  PublisherStore.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/23.
//

protocol PublisherStore {
    func create(publisher: Publisher)
    func read() -> [Publisher]
    func update(publisher: Publisher)
    func delete(publisher: Publisher)
}
