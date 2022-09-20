//
//  DeckEntity+CoreDataProperties.swift
//  Project-Bird
//
//  Created by Marcos Chevis on 20/09/22.
//
//

import Foundation
import CoreData

extension DeckEntity {

    @nonobjc public class func fetchRequest() -> NSFetchRequest<DeckEntity> {
        return NSFetchRequest<DeckEntity>(entityName: "DeckEntity")
    }

    @NSManaged public var color: Int16
    @NSManaged public var createdAt: Date?
    @NSManaged public var icon: String?
    @NSManaged public var id: UUID?
    @NSManaged public var lastAccess: Date?
    @NSManaged public var lastEdit: Date?
    @NSManaged public var maxLearningCards: Int32
    @NSManaged public var maxReviewingCards: Int32
    @NSManaged public var name: String?
    @NSManaged public var numberOfSteps: Int16
    @NSManaged public var cards: NSSet?
    @NSManaged public var collection: CollectionEntity?

}

// MARK: Generated accessors for cards
extension DeckEntity {

    @objc(addCardsObject:)
    @NSManaged public func addToCards(_ value: CardEntity)

    @objc(removeCardsObject:)
    @NSManaged public func removeFromCards(_ value: CardEntity)

    @objc(addCards:)
    @NSManaged public func addToCards(_ values: NSSet)

    @objc(removeCards:)
    @NSManaged public func removeFromCards(_ values: NSSet)

}
