//
//  BookEntity+CoreDataProperties.swift
//  
//
//  Created by Mori on 2020/10/23.
//
//

import Foundation
import CoreData


extension BookEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<BookEntity> {
        return NSFetchRequest<BookEntity>(entityName: "BookEntity")
    }

    @NSManaged public var id: Int64
    @NSManaged public var name: String?
    @NSManaged public var price: Int64
    @NSManaged public var publisherId: Int64
    @NSManaged public var publisher: PublisherEntity?

}
