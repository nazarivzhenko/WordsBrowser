import Foundation
import CoreData

fileprivate enum StoreProviderType {
    case normal, preview, testing
}

final class StoreProvider: ObservableObject {
    
    static let shared = StoreProvider(type: .normal)
    static let preview = StoreProvider(type: .preview)
    static let testing = StoreProvider(type: .testing)
    
    @Published private(set) var words: [WordEntity] = []
    
    let managedObjectContext: NSManagedObjectContext
    
    private init(type: StoreProviderType) {
        switch type {
        case .normal:
            let persistentStore = PersistentStore()
            self.managedObjectContext = persistentStore.context
        case .preview:
            let persistentStore = PersistentStore(inMemory: true)
            self.managedObjectContext = persistentStore.context
            
            saveWord("striking", pronunciation: "'straɪkɪŋ")
            saveDefinition("sensational in appearance or thrilling in effect",
                           partOfSpeech: "adjective",
                           for: "striking")
            saveDefinition("having a quality that thrusts itself into attention",
                           partOfSpeech: "adjective",
                           for: "striking")
            saveSynonyms(["impressive", "remarkable", "outstanding"], for: "striking")
            saveExamples([
                "A striking thing about Picadilly Circus is the statue of Eros in the center."
            ], for: "striking")
            
            try? managedObjectContext.save()
        case .testing:
            let persistentStore = PersistentStore(inMemory: true)
            self.managedObjectContext = persistentStore.context
        }
        
        fetchAllWords()
    }
    
    func saveData() {
        if managedObjectContext.hasChanges {
            do {
                try managedObjectContext.save()
            } catch let error as NSError {
                NSLog("Unresolved error saving context: \(error), \(error.userInfo)")
            }
        }
    }
    
    func fetchAllWords() {
        if let fetchedWords = fetchWords(), !fetchedWords.isEmpty {
            words = fetchedWords
        }
    }
}

extension StoreProvider {
    func fetchWords() -> [WordEntity]? {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.sortDescriptors = [NSSortDescriptor(keyPath: \WordEntity.createdAt, ascending: false)]
        
        do {
            return try managedObjectContext.fetch(fetchRequest)
        } catch {
            print("Failed to fetch words: \(error)")
            return nil
        }
    }
    
    func saveWord(_ word: String, pronunciation: String) {
        let wordEntity = WordEntity(context: managedObjectContext)
        wordEntity.id = UUID().uuidString
        wordEntity.word = word
        wordEntity.createdAt = Date()
        wordEntity.pronunciation = pronunciation
        
        saveData()
    }
    
    func saveDefinition(_ definition: String, partOfSpeech: String, for word: String) {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word == %@", word)
        guard let wordEntity = try? managedObjectContext.fetch(fetchRequest).first else { return }
        
        let definitionEntity = DefinitionEntity(context: managedObjectContext)
        definitionEntity.id = UUID().uuidString
        definitionEntity.definition = definition
        definitionEntity.partOfSpeech = partOfSpeech
        
        wordEntity.addToDefinitions(definitionEntity)
        saveData()
    }
    
    func fetchSynonyms(for word: String) -> [String]? {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word == %@", word)
        guard let wordEntity = try? managedObjectContext.fetch(fetchRequest).first else { return nil }
        
        return (wordEntity.synonyms?.allObjects as? [SynonymEntity])?.compactMap(\.synonym)
    }
    
    func saveSynonyms(_ synonyms: [String], for word: String) {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word == %@", word)
        guard let wordEntity = try? managedObjectContext.fetch(fetchRequest).first else { return }
        
        for synonym in synonyms {
            let synonymEntity = SynonymEntity(context: managedObjectContext)
            synonymEntity.id = UUID().uuidString
            synonymEntity.synonym = synonym
            
            wordEntity.addToSynonyms(synonymEntity)
        }
        
        saveData()
    }
    
    func fetchExamples(for word: String) -> [String]? {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word == %@", word)
        guard let wordEntity = try? managedObjectContext.fetch(fetchRequest).first else { return nil }
        
        return (wordEntity.examples?.allObjects as? [ExampleEntity])?.compactMap(\.example)
    }
    
    func saveExamples(_ examples: [String], for word: String) {
        let fetchRequest: NSFetchRequest<WordEntity> = WordEntity.fetchRequest()
        fetchRequest.predicate = NSPredicate(format: "word == %@", word)
        guard let wordEntity = try? managedObjectContext.fetch(fetchRequest).first else { return }
        
        for example in examples {
            let exampleEntity = ExampleEntity(context: managedObjectContext)
            exampleEntity.id = UUID().uuidString
            exampleEntity.example = example
            
            wordEntity.addToExamples(exampleEntity)
        }
        
        saveData()
    }
}
