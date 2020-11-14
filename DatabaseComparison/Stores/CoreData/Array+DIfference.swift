//
//  Array+DIfference.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/13.
//

import Foundation

extension Array where Self.Element: Equatable {
    func differenceElements(from elements: [Element]) -> (
        insertedElements: [Element],
        deletedElements: [Element],
        noChangedElements: [Element]
    ) {
        var insertedElements: [Element] = []
        var deletedElements: [Element] = []
        var noChangedElements: [Element] = []

        let (insertedIndex, deletedIndex, noChangedIndex) = self.differenceIndex(from: elements)

        insertedElements = insertedIndex.map { self[$0] }
        deletedElements = deletedIndex.map { elements[$0] }
        noChangedElements = noChangedIndex.map { self[$0] }

        return (
            insertedElements: insertedElements,
            deletedElements: deletedElements,
            noChangedElements: noChangedElements
        )
    }

    func differenceIndex(from elements: [Element]) -> (
        insertedIndex: [Int],
        deletedIndex: [Int],
        noChangedIndex: [Int]
    ) {
        var insertedIndex = Set<Int>()
        var deletedIndex = Set<Int>()
        var noChangedIndex = Set<Int>()
        let differences = self.difference(from: elements)
        differences.forEach { difference in
            switch difference {
            case let .insert(offset, _, _):
                insertedIndex.insert(offset)
            case let .remove(offset, _, _):
                deletedIndex.insert(offset)
            }
        }

        for index in 0..<self.count {
            if !insertedIndex.contains(index) && !deletedIndex.contains(index) {
                noChangedIndex.insert(index)
            }
        }

        return (
            insertedIndex: Array<Int>(insertedIndex),
            deletedIndex: Array<Int>(deletedIndex),
            noChangedIndex: Array<Int>(noChangedIndex)
        )
    }
}
