//
//  SynonymEntity+CoreDataProperties.swift
//  WordsBrowser
//
//  Created by mac on 29.09.2025.
//
//

public import Foundation
public import CoreData


public typealias SynonymEntityCoreDataPropertiesSet = NSSet

extension SynonymEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<SynonymEntity> {
        return NSFetchRequest<SynonymEntity>(entityName: "SynonymEntity")
    }

    @NSManaged public var synonym: String?
    @NSManaged public var id: String?
    @NSManaged public var word: WordEntity?

}

extension SynonymEntity : Identifiable {

}
