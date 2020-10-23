//
//  OwnerEntiry+CoreDataProperties.swift
//  
//
//  Created by Mori on 2020/10/23.
//
//

import Foundation
import CoreData


extension OwnerEntiry {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<OwnerEntiry> {
        return NSFetchRequest<OwnerEntiry>(entityName: "OwnerEntiry")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var profile: String?
    @NSManaged public var age: Int32
    @NSManaged public var publishers: NSSet?

}

// MARK: Generated accessors for publishers
extension OwnerEntiry {

    @objc(addPublishersObject:)
    @NSManaged public func addToPublishers(_ value: PublisherEntity)

    @objc(removePublishersObject:)
    @NSManaged public func removeFromPublishers(_ value: PublisherEntity)

    @objc(addPublishers:)
    @NSManaged public func addToPublishers(_ values: NSSet)

    @objc(removePublishers:)
    @NSManaged public func removeFromPublishers(_ values: NSSet)

}
