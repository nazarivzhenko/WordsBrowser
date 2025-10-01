//
//  DefinitionEntity+CoreDataProperties.swift
//  WordsBrowser
//
//  Created by mac on 29.09.2025.
//
//

public import Foundation
public import CoreData


public typealias DefinitionEntityCoreDataPropertiesSet = NSSet

extension DefinitionEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DefinitionEntity> {
        return NSFetchRequest<DefinitionEntity>(entityName: "DefinitionEntity")
    }

    @NSManaged public var definition: String
    @NSManaged public var partOfSpeech: String
    @NSManaged public var id: String
    @NSManaged public var word: WordEntity?

}

extension DefinitionEntity : Identifiable {

}
