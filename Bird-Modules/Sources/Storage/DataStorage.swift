//
//  File.swift
//  
//
//  Created by Gabriel Ferreira de Carvalho on 22/08/22.
//

import CoreData

public class Test {
    public static func test() {
        let data = try! DataStorage.shared.mainContext.fetch(CardEntity.fetchRequest())
        print(data)
    }
}

final class DataStorage {

    static let shared = DataStorage()
    
    private static var managedObjectModel: NSManagedObjectModel = {
        let bundle = Bundle.module
        let containerName = "Bird"
        guard let url = bundle.url(forResource: containerName, withExtension: "momd") else {
            fatalError("Failed to find file")
        }
        guard let model = NSManagedObjectModel(contentsOf: url) else {
            fatalError("Failed to load file")
        }
        return model
    }()

    private let model: String

    private var container: NSPersistentContainer

    var mainContext: NSManagedObjectContext {
        container.viewContext
    }

    init(_ storeType: StoreType = .persistent) {
        self.model = "NotesModel"
        container = NSPersistentContainer(name: model, managedObjectModel: Self.managedObjectModel) // quando se refere as coisas estaticas da classe
        
        if storeType == .inMemory { // quando recebe esse endereco, eh pra guardar em memoria
            container.persistentStoreDescriptions.first!.url = URL(fileURLWithPath: "/dev/null")
        }
        
        container.loadPersistentStores { _, error in
            if let error = error {
                fatalError("Failed loading with error: \(error)")
            }
        }
    }

    func save() throws {
        if mainContext.hasChanges {
            do {
                try mainContext.save()
            } catch {
                throw CoreDataStackError.failedToSave
            }
        } else {
            throw CoreDataStackError.contextHasNoChanges
        }
    }
    
    func convertURLToObjectID(_ url: URL) -> NSManagedObjectID? {
        container.persistentStoreCoordinator.managedObjectID(forURIRepresentation: url)
    }
}



enum CoreDataStackError: Error {
    case failedToSave
    case contextHasNoChanges
}

enum StoreType {
    case persistent
    case inMemory
}
