//
//  ExampleEntity+CoreDataProperties.swift
//  WordsBrowser
//
//  Created by mac on 29.09.2025.
//
//

public import Foundation
public import CoreData


public typealias ExampleEntityCoreDataPropertiesSet = NSSet

extension ExampleEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<ExampleEntity> {
        return NSFetchRequest<ExampleEntity>(entityName: "ExampleEntity")
    }

    @NSManaged public var example: String?
    @NSManaged public var id: String?
    @NSManaged public var word: WordEntity?

}

extension ExampleEntity : Identifiable {

}
