//
//  CollectionEntityTests.swift
//  
//
//  Created by Gabriel Ferreira de Carvalho on 25/08/22.
//

import XCTest
@testable import Storage
import Models

class CollectionEntityTests: XCTestCase {
    
    var dataStorage: DataStorage! = nil

    override func setUp() {
        dataStorage = DataStorage(StoreType.inMemory)
    }
    
    override func tearDown() {
        dataStorage = nil
    }
    
    func testModelToEntity() throws {
        let model = DeckCollectionDummy.dummy
        
        _ = CollectionEntity(withData: model, on: dataStorage.mainContext)
        try dataStorage.save()
        
        let saved = try dataStorage.mainContext.fetch(CollectionEntity.fetchRequest()).first!
        
        XCTAssertEqual(model.id, saved.id)
        XCTAssertEqual(model.name, saved.name)
        XCTAssertEqual(model.iconPath, model.iconPath)
        XCTAssertEqual(model.datesLogs.createdAt, saved.createdAt)
        XCTAssertEqual(model.datesLogs.lastEdit, saved.lastEdit)
        XCTAssertEqual(model.datesLogs.lastAccess, saved.lastAccess)
        
    }
    
    func testEntityToModel() throws {
        let model = DeckCollectionDummy.dummy
        
        _ = CollectionEntity(withData: model, on: dataStorage.mainContext)
        try dataStorage.save()
        
        let saved = try dataStorage.mainContext.fetch(CollectionEntity.fetchRequest()).first!
        
        let savedModel = DeckCollection(entity: saved)
        
        XCTAssertEqual(model, savedModel)
    }

}
