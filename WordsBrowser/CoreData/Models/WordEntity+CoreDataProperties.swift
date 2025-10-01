//
//  WordEntity+CoreDataProperties.swift
//  WordsBrowser
//
//  Created by mac on 29.09.2025.
//
//

public import Foundation
public import CoreData


public typealias WordEntityCoreDataPropertiesSet = NSSet

extension WordEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<WordEntity> {
        return NSFetchRequest<WordEntity>(entityName: "WordEntity")
    }

    @NSManaged public var id: String
    @NSManaged public var word: String
    @NSManaged public var createdAt: Date
    @NSManaged public var pronunciation: String?
    @NSManaged public var definitions: NSSet?
    @NSManaged public var synonyms: NSSet?
    @NSManaged public var examples: NSSet?

}

// MARK: Generated accessors for definitions
extension WordEntity {

    @objc(addDefinitionsObject:)
    @NSManaged public func addToDefinitions(_ value: DefinitionEntity)

    @objc(removeDefinitionsObject:)
    @NSManaged public func removeFromDefinitions(_ value: DefinitionEntity)

    @objc(addDefinitions:)
    @NSManaged public func addToDefinitions(_ values: NSSet)

    @objc(removeDefinitions:)
    @NSManaged public func removeFromDefinitions(_ values: NSSet)

}

// MARK: Generated accessors for synonyms
extension WordEntity {

    @objc(addSynonymsObject:)
    @NSManaged public func addToSynonyms(_ value: SynonymEntity)

    @objc(removeSynonymsObject:)
    @NSManaged public func removeFromSynonyms(_ value: SynonymEntity)

    @objc(addSynonyms:)
    @NSManaged public func addToSynonyms(_ values: NSSet)

    @objc(removeSynonyms:)
    @NSManaged public func removeFromSynonyms(_ values: NSSet)

}

// MARK: Generated accessors for examples
extension WordEntity {

    @objc(addExamplesObject:)
    @NSManaged public func addToExamples(_ value: ExampleEntity)

    @objc(removeExamplesObject:)
    @NSManaged public func removeFromExamples(_ value: ExampleEntity)

    @objc(addExamples:)
    @NSManaged public func addToExamples(_ values: NSSet)

    @objc(removeExamples:)
    @NSManaged public func removeFromExamples(_ values: NSSet)

}

extension WordEntity : Identifiable {

}

// MARK: Exist to provide a word to use with Xcode previews
extension WordEntity {
    
    static var sampleWord: WordEntity {
        let context = StoreProvider.preview.managedObjectContext
        
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.fetchLimit = 1
        
        guard let word = try? context.fetch(fetchRequest).first else {
            fatalError("No sample word available")
        }
        
        return word
    }
}
