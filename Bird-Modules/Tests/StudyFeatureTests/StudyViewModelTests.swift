////
////  StudyViewModelTests.swift
////  
////
////  Created by Marcos Chevis on 06/09/22.
////

import XCTest
@testable import StudyFeature
import Storage
import Models
import Combine
import Utils

class StudyViewModelTests: XCTestCase {
    
    var sut: StudyViewModel!
    var localStorage: LocalStorageMock!
    var deckRepository: DeckRepositoryMock!
    var deck: Deck!
    var sessionCacher: SessionCacher!
    var dateHandler: DateHandlerProtocol!
    var systemObserver: SystemObserverMock!
    var cancellables: Set<AnyCancellable>!
    
    
    override func setUpWithError() throws {
        deckRepository = DeckRepositoryMock()
        localStorage = LocalStorageMock()
        sessionCacher = SessionCacher(storage: localStorage)
        deck = deckRepository.decks.first
        dateHandler = DateHandlerMock()
        systemObserver = SystemObserverMock()
        
        sut = .init()
        cancellables = .init()
    }
    
    override func tearDownWithError() throws {
        deckRepository = nil
        localStorage = nil
        sessionCacher = nil
        deck = nil
        sut = nil
        cancellables.forEach { $0.cancel() }
        cancellables = nil
        dateHandler = nil
        systemObserver = nil
    }
    
    func testStartupWithExistingSession() {
        let cardIds = Array(deckRepository.cards.prefix(3).map(\.id))
        let session = Session(cardIds: cardIds, date: dateHandler.today, deckId: deck.id)
        sessionCacher.setCurrentSession(session: session)
        
        sut.startup(deck: deck)
        let expectation = expectation(description: "fetch cards")
        sut.$cards.sink { [unowned self] cards in
            let first3Cards = Array(self.deckRepository.cards.prefix(3))
            XCTAssertEqual(cards.sorted(by: sortById), first3Cards.sorted(by: sortById))
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testDidCreateNewSessionOnStartup() {
        XCTAssertNil(sessionCacher.currentSession(for: deck.id))
        sut.startup(deck: deck)
        
        let expectation = expectation(description: "did handle events correctly")
        
        let expectedSession = Session(cardIds: deck.cardsIds.sorted(by: { $0.uuidString > $1.uuidString } ), date: dateHandler.today, deckId: deck.id)
        
        sut.$cards.sink {[unowned self] cards in
            var session = self.sessionCacher.currentSession(for: self.deck.id)
            let ids = session?.cardIds ?? []
            session?.cardIds = ids.sorted(by: { $0.uuidString > $1.uuidString })
            XCTAssertEqual(expectedSession, session)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    
    func testStartupWithNewSessionFewerCardsThanLimit() {
        XCTAssertEqual(sut.cards, [])
        sut.startup(deck: deck)
        let expectation = expectation(description: "fetch cards")
        sut.$cards.sink { cards in
            
            XCTAssertEqual(cards.sorted(by: self.sortById), self.deckRepository.cards.sorted(by: self.sortById).filter { $0.deckID == self.deck.id })
            XCTAssertEqual(self.sut.cardsToEdit.count, 0)
            XCTAssertEqual(self.sut.displayedCards.map(\.card.id), cards.prefix(2).reversed().map(CardViewModel.init).map(\.card.id))
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testStartupWithNewSessionNoCards() {
        XCTAssertEqual(sut.cards, [])
        self.deck = deckRepository.decks[1]
        deckRepository.cards = []
        sut.startup(deck: deck)
        let expectation = expectation(description: "fetch cards")
        sut.$cards.sink { cards in
            XCTAssertEqual(cards.count, 0)
            XCTAssertEqual(self.sut.cardsToEdit.count, 0)
            XCTAssertEqual(self.sut.displayedCards.count, 0)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testStartupWithNewSessionTooManyCards() {
        XCTAssertEqual(sut.cards, [])
        self.deck = deckRepository.decks[2]
        
        
        sut.startup(deck: deck)
        let expectation = expectation(description: "fetch cards")
        sut.$cards.sink { cards in
            XCTAssertEqual(cards.count, 3)
            XCTAssertEqual(self.sut.cardsToEdit.count, 1)
            XCTAssertEqual(self.sut.displayedCards.map(\.card.id), cards.prefix(2).reversed().map(CardViewModel.init).map(\.card.id))
            var hasRepeated = false
            for card in cards {
                if self.sut.cardsToEdit.contains(where: { c in c.id == card.id }) {
                    hasRepeated = true
                }
            }
            XCTAssertFalse(hasRepeated)
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testStartupWithNewSession2Cards() {
        XCTAssertEqual(sut.cards, [])
        self.deck = deckRepository.decks[3]
        
        sut.startup(deck: deck)
        let expectation = expectation(description: "fetch cards")
        sut.$cards.sink { cards in
            XCTAssertEqual(self.sut.displayedCards.map(\.card.id), cards.prefix(2).reversed().map(CardViewModel.init).map(\.card.id))
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testStartupWithNewSession1Card() {
        XCTAssertEqual(sut.cards, [])
        self.deck = deckRepository.decks[1]
        
        sut.startup(deck: deck)
        let expectation = expectation(description: "fetch cards")
        sut.$cards.sink { cards in
            XCTAssertEqual(self.sut.displayedCards.map(\.card.id), cards.prefix(2).reversed().map(CardViewModel.init).map(\.card.id))
            expectation.fulfill()
        }
        .store(in: &cancellables)
        
        wait(for: [expectation], timeout: 1)
    }
    
    func testPressedButtonCardDidGoBack() throws {
        XCTAssertEqual(sut.cards, [])
        
        sut.startup(deck: deck)
        
        let oldCard = sut.cards[0]
        sut.cards[0] = Card(id: oldCard.id, front: oldCard.front, back: oldCard.back, color: oldCard.color, datesLogs: oldCard.datesLogs, deckID: oldCard.deckID, woodpeckerCardInfo: WoodpeckerCardInfo(step: 1, isGraduated: false, easeFactor: 2.5, streak: 0, interval: 0, hasBeenPresented: true), history: [])
        //vai ficar no msm step, pq esta no 0

        try sut.pressedButton(for: .wrongHard, deck: deck)
        
        let modCard = sut.cards.first { card in
            card.id == oldCard.id
        }
        
        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 0, isGraduated: false, easeFactor: 2.5, streak: 0, interval: 0, hasBeenPresented: true))
        XCTAssertEqual(modCard?.history.count, 0)
    }
    
    func testPressedButtonCardDidStay() throws {
        XCTAssertEqual(sut.cards, [])
        
        sut.startup(deck: deck)
        let oldCard = sut.cards[0]
        //vai ficar no msm step, pq esta no 0
        
        try sut.pressedButton(for: .wrongHard, deck: deck)
        
        let modCard = sut.cards.first { card in
            card.id == oldCard.id
        }
        var newInfo = oldCard.woodpeckerCardInfo
        newInfo.hasBeenPresented = true
        
        XCTAssertEqual(modCard?.woodpeckerCardInfo, newInfo)
        XCTAssertEqual(modCard?.history.count, 0)
    }
    
    func testPressedButtonCardDidGoFoward() throws {
        XCTAssertEqual(sut.cards, [])
        
        sut.startup(deck: deck)
        let oldCard = sut.cards[0]
        //vai ficar no msm step, pq esta no 0
        
        try sut.pressedButton(for: .correct, deck: deck)
        
        let modCard = sut.cards.first { card in
            card.id == oldCard.id
        }
        
        
        
        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 1, isGraduated: false, easeFactor: 2.5, streak: 1, interval: 0, hasBeenPresented: true))
        XCTAssertEqual(modCard?.history.count, 0)
    }
    
    func testPressedButtonCardDidGraduate() throws {
        XCTAssertEqual(sut.cards, [])
        
        sut.startup(deck: deck)
        let oldCard = sut.cards[0]
        //vai ficar no msm step, pq esta no 0
        
        try sut.pressedButton(for: .correctEasy, deck: deck)
        
        let modCard = sut.cardsToEdit.first { card in
            card.id == oldCard.id
        }
        
        
        
        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 0, isGraduated: true, easeFactor: 2.5, streak: 1, interval: 1, hasBeenPresented: true))
        XCTAssertEqual(modCard?.history.count, 1)
        XCTAssertFalse(sut.cards.contains(where: { $0.id == oldCard.id }))
        XCTAssertTrue(sut.cardsToEdit.contains(where: { $0.id == oldCard.id }))
    }
    
    func testPressedButtonGraduatedCardDemoted() throws {
        XCTAssertEqual(sut.cards, [])
        
        sut.startup(deck: deck)
        sut.cards.reverse()
        let oldCard = sut.cards[0]
        
        
        try sut.pressedButton(for: .wrongHard, deck: deck)
        
        let modCard = sut.cardsToEdit.first { card in
            card.id == oldCard.id
        }
  
        
        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 0, isGraduated: false, easeFactor: 1.7, streak: 0, interval: 0, hasBeenPresented: true))
        XCTAssertEqual(modCard?.history.count, 2)
        XCTAssertFalse(sut.cards.contains(where: { $0.id == oldCard.id }))
        XCTAssertTrue(sut.cardsToEdit.contains(where: { $0.id == oldCard.id }))
    }
    
    func testPressedButtonGraduatedCardReviwed() throws {
        XCTAssertEqual(sut.cards, [])
        
        sut.startup(deck: deck)
        sut.cards.reverse()
        let oldCard = sut.cards[0]
        
        
        try sut.pressedButton(for: .correct, deck: deck)
        
        let modCard = sut.cardsToEdit.first { card in
            card.id == oldCard.id
        }
  
        
        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 0, isGraduated: true, easeFactor: 2.5, streak: 1, interval: 1, hasBeenPresented: true))
        XCTAssertEqual(modCard?.history.count, 2)
        XCTAssertFalse(sut.cards.contains(where: { $0.id == oldCard.id }))
        XCTAssertTrue(sut.cardsToEdit.contains(where: { $0.id == oldCard.id }))
    }

    
    // ordena todos os learning antes, depois os reviewing
    func sortCardByStepMock(card0: Card, card1: Card) -> Bool {
        if card0.woodpeckerCardInfo.isGraduated {
            return false
        } else if card1.woodpeckerCardInfo.isGraduated {
            return true
        } else {
            return card0.woodpeckerCardInfo.step < card1.woodpeckerCardInfo.step
        }
    }
    
    func sortById(d0: Card, d1: Card) -> Bool {
        return d0.id.uuidString > d1.id.uuidString
    }
    
    
    func testIsVOOn() {
        let cardIds = Array(deckRepository.cards.prefix(3).map(\.id))
        let session = Session(cardIds: cardIds, date: dateHandler.today, deckId: deck.id)
        sessionCacher.setCurrentSession(session: session)
        
        sut.startup(deck: deck)
        XCTAssertFalse(sut.isVOOn)
        systemObserver.voiceOverDidChangeSubject.send(true)
        XCTAssertTrue(sut.isVOOn)
    }
    
    func testSaveEditedCards() throws {
        let expectation = expectation(description: "receive card for id")
        self.deck = deckRepository.decks[1]
        
        sut.startup(deck: deck)
        let card = sut.cards.first!
        XCTAssertEqual(card.woodpeckerCardInfo.interval, 0)
        try sut.pressedButton(for: .correctEasy, deck: deck)
        try sut.saveChanges(deck: deck)
      
        deckRepository.fetchCardById(deckRepository.decks[1].cardsIds.first!)
            .assertNoFailure()
            .sink { receivedCard in
                XCTAssertEqual(receivedCard.woodpeckerCardInfo.interval, 1)
                expectation.fulfill()
                
            }
            .store(in: &cancellables)
        
        
        
        wait(for: [expectation], timeout: 1)
    }
}
