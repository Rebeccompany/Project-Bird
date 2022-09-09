//
 //  DeckRepositoryMock.swift
 //
 //
 //  Created by Marcos Chevis on 06/09/22.
 //

 import Foundation
 import Models
 import Combine

 public class DeckRepositoryMock: DeckRepositoryProtocol {
     public var deckWithCardsId: UUID = UUID(uuidString: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2")!

     public lazy var decks: [Deck] = [Deck(id: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", cardsIds: cards.map( { $0.id })),
                          Deck(id: "a498bc3c-85a3-4784-b560-a33a272a0a92"),
                          Deck(id: "4e56be0a-bc7c-4497-aec9-c30482e82496"),
                          Deck(id: "3947217b-2f55-4f16-ae59-10017d291579")

     ]

     public lazy var subject: CurrentValueSubject<[Deck], RepositoryError> = .init(decks)

     public var cards: [Card] = [
         Card(id: "1f222564-ff0d-4f2d-9598-1a0542899974", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .learn, front: AttributedString(String(0)), back: AttributedString(String(0))),
         Card(id: "66605408-4cd4-4ded-b23d-91db9249a946", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .learn, front: AttributedString(String(1)), back: AttributedString(String(1))),
         Card(id: "4f298230-4286-4a83-9f1c-53fd60533ed8", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .learn, front: AttributedString(String(2)), back: AttributedString(String(2))),
         Card(id: "9b06af85-e4e8-442d-be7a-40450cfd310c", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .learn, front: AttributedString(String(3)), back: AttributedString(String(3))),
         Card(id: "855eb618-602e-449d-83fc-5de6b8a36454", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .learn, front: AttributedString(String(4)), back: AttributedString(String(4))),
         Card(id: "5285798a-4107-48b3-8994-e706699a3445", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .learn, front: AttributedString(String(5)), back: AttributedString(String(5))),
         Card(id: "407e7694-316e-4903-9c94-b3ec0e9ab0e8", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .learn, front: AttributedString(String(6)), back: AttributedString(String(6))),
         Card(id: "09ae6b07-b988-442f-a059-9ea76d5c9055", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .review, front: AttributedString(String(7)), back: AttributedString(String(7))),
         Card(id: "d3b5ba9a-7805-480e-ad47-43b842f0472f", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .review, front: AttributedString(String(8)), back: AttributedString(String(8))),
         Card(id: "d9d3d4ec-9854-4e73-864b-1e68355a6973", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .review, front: AttributedString(String(9)), back: AttributedString(String(9))),
         Card(id: "c24affd7-376d-4614-9ad6-8a83a0f60da5", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .review, front: AttributedString(String(10)), back: AttributedString(String(10))),
         Card(id: "d2c951fb-36f5-49dc-84f0-353a3b3a2875", deckId: "c3046ed9-83fb-4c81-a83c-b11ae4863bd2", state: .review, front: AttributedString(String(11)), back: AttributedString(String(11)))
     ]
     
     public init() {}

     public func fetchDeckById(_ id: UUID) -> AnyPublisher<Deck, RepositoryError> {
         if let deck = decks.first(where: { deck in deck.id == id }) {
             return Just(deck).setFailureType(to: RepositoryError.self).eraseToAnyPublisher()
         } else {
             return Fail<Deck,RepositoryError>(error: .failedFetching).eraseToAnyPublisher()
         }
     }

     public func fetchDecksByIds(_ ids: [UUID]) -> AnyPublisher<[Deck], RepositoryError> {
         let decks = decks.filter { deck in ids.contains(deck.id) }
         return Just(decks).setFailureType(to: RepositoryError.self).eraseToAnyPublisher()

     }

     public func deckListener() -> AnyPublisher<[Deck], RepositoryError> {
         subject.eraseToAnyPublisher()
     }

     public func createDeck(_ deck: Deck, cards: [Card]) throws {
         var deck = deck
         deck.cardsIds = cards.map(\.id)
         decks.append(deck)
         self.cards += cards
         
         subject.send(decks)
     }

     public func deleteDeck(_ deck: Deck) throws {
         decks.removeAll { d in
             d.id == deck.id
         }
         
         subject.send(decks)
     }

     public func editDeck(_ deck: Deck) throws {
         if let i = decks.firstIndex(where: { d in d.id == deck.id }) {
             decks[i] = deck
         } else {
             throw RepositoryError.couldNotEdit
         }
         
         subject.send(decks)
     }

     public func addCard(_ card: Card, to deck: Deck) throws {
         if let i = decks.firstIndex(where: { d in d.id == deck.id }) {
             decks[i] = deck
             subject.send(decks)
         } else {
             throw RepositoryError.couldNotEdit
         }
     }

     public func removeCard(_ card: Card, from deck: Deck) throws {
         cards.removeAll { $0.id == card.id }
         decks = decks.map { d in
             var d = d
             d.cardsIds = d.cardsIds.filter { id in id != card.id }
             return d
         }
         subject.send(decks)
     }

     public func fetchCardById(_ id: UUID) -> AnyPublisher<Card, RepositoryError> {
         if let card = cards.first(where: { card in card.id == id }) {
             return Just(card).setFailureType(to: RepositoryError.self).eraseToAnyPublisher()
         } else {
             return Fail<Card,RepositoryError>(error: .failedFetching).eraseToAnyPublisher()
         }
     }

     public func fetchCardsByIds(_ ids: [UUID]) -> AnyPublisher<[Card], RepositoryError> {
         let cards = cards.filter { card in ids.contains(card.id) }
         return Just(cards).setFailureType(to: RepositoryError.self).eraseToAnyPublisher()
     }

     public func deleteCard(_ card: Card) throws {
         cards.removeAll { $0.id == card.id }
         decks = decks.map { d in
             var d = d
             d.cardsIds = d.cardsIds.filter { id in id != card.id }
             return d
         }
     }

     public func editCard(_ card: Card) throws {
         if let i = cards.firstIndex(where: { d in d.id == card.id }) {
             cards[i] = card
         } else {
             throw RepositoryError.couldNotEdit
         }
     }


 }

 fileprivate enum WoodpeckerState {
     case review, learn
 }

 extension WoodpeckerCardInfo {
     fileprivate init(state: WoodpeckerState) {
         let isg: Bool
         let interval: Int
         switch state {
         case .review:
             isg = true
             interval = 1

         case .learn:
             isg = false
             interval = 0
         }
         self.init(step: 0, isGraduated: isg, easeFactor: 2.5, streak: 0, interval: interval, hasBeenPresented: isg)
     }
 }

 extension Card {
     
     fileprivate init(id: String, deckId: String, state: WoodpeckerState, front: AttributedString, back: AttributedString) {
         let h: [CardSnapshot]
         switch state {
         case .review:
             h = [CardSnapshot(woodpeckerCardInfo: WoodpeckerCardInfo(state: .learn), userGrade: .correct, timeSpend: 20, date: Date(timeIntervalSince1970: -8400))]
         case .learn:
             h = []
         }
         self.init(id: UUID(uuidString: id)!,
                   front: front,
                   back: back,
                   color: .red,
                   datesLogs: DateLogs(lastAccess: Date(timeIntervalSince1970: 0),
                                       lastEdit: Date(timeIntervalSince1970: 0),
                                       createdAt: Date(timeIntervalSince1970: 0)),
                   deckID: UUID(uuidString: deckId)!,
                   woodpeckerCardInfo: WoodpeckerCardInfo(state: state),
                   history: h)
     }
 }

 extension Deck {
     fileprivate init(id: String, cardsIds: [UUID] = []) {
         self.init(id: UUID(uuidString: id)!,
                   name: "Progamação Swift",
                   icon: "chevron.down",
                   color: .red,
                   datesLogs: DateLogs(lastAccess: Date(timeIntervalSince1970: 0),
                                       lastEdit: Date(timeIntervalSince1970: 0),
                                       createdAt: Date(timeIntervalSince1970: 0)),
                   collectionsIds: [],
                   cardsIds: cardsIds,
                   spacedRepetitionConfig: .init(maxLearningCards: 20,
                                                 maxReviewingCards: 200))
     }
 }
