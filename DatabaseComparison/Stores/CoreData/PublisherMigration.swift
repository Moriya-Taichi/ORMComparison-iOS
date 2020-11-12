//
//  PublisherMigration.swift
//  DatabaseComparison
//
//  Created by Mori on 2020/11/12.
//

import Foundation
import CoreData

final class PublisherMigration: NSEntityMigrationPolicy {
    override func createDestinationInstances(
        forSource sInstance: NSManagedObject,
        in mapping: NSEntityMapping,
        manager: NSMigrationManager
    ) throws {
        //Migration
        if sInstance.entity.name == "Publisher" {
            let context = manager.destinationContext

            let publisherName = sInstance.primitiveValue(forKey: "name") as? String
            let publisherID = sInstance.primitiveValue(forKey: "id") as? Int

            //example
            //let newObject = Hoge(context: context)
            //newObject.hoge = publisherName
            //context.insert(newObject)
        }
    }
}
