//
//  PublisherEntity+CoreDataProperties.swift
//  
//
//  Created by Mori on 2020/10/23.
//
//

import Foundation
import CoreData


extension PublisherEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<PublisherEntity> {
        return NSFetchRequest<PublisherEntity>(entityName: "PublisherEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var books: NSSet?
    @NSManaged public var owner: OwnerEntiry?

}

// MARK: Generated accessors for books
extension PublisherEntity {

    @objc(addBooksObject:)
    @NSManaged public func addToBooks(_ value: BookEntity)

    @objc(removeBooksObject:)
    @NSManaged public func removeFromBooks(_ value: BookEntity)

    @objc(addBooks:)
    @NSManaged public func addToBooks(_ values: NSSet)

    @objc(removeBooks:)
    @NSManaged public func removeFromBooks(_ values: NSSet)

}
