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

        let (insertedIndex, deletedIndex, noChangedIndex, _) = self.differenceIndex(from: elements)

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
        noChangedIndex: [Int],
        noChangedOldIndex: [Int]
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
            let nextIndex = index + 1
            let previousIndex = index - 1

            let isNotRepalaced = !insertedIndex.contains(index) && !deletedIndex.contains(index)
            let isPreviousInsertedAndDeletePosition = insertedIndex.contains(previousIndex) &&
                deletedIndex.contains(index)
            let isNextInsertedAndDeletePrevious = insertedIndex.contains(nextIndex) &&
                deletedIndex.contains(index)

            if isNotRepalaced {
                noChangedIndex.insert(index)
            } else if isPreviousInsertedAndDeletePosition || isNextInsertedAndDeletePrevious {
                noChangedIndex.insert(index)
            } else if index < elements.count,
                      self[index] != elements[index] && !insertedIndex.contains(index)
            {
                noChangedIndex.insert(index)
            }
        }

        let oldArrayNoChangedPosition = elements.enumerated().map { $0.offset }.filter { index in
            return !deletedIndex.contains(index)
        }

        return (
            insertedIndex: Array<Int>(insertedIndex).sorted(),
            deletedIndex: Array<Int>(deletedIndex).sorted(),
            noChangedIndex: Array<Int>(noChangedIndex).sorted(),
            noChangedOldIndex: oldArrayNoChangedPosition
        )
    }
}
