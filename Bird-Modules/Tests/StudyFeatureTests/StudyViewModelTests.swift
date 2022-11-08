#warning("grrrrrrrr")
//////
//////  StudyViewModelTests.swift
//////
//////
//////  Created by Marcos Chevis on 06/09/22.
//////
//
//import XCTest
//@testable import StudyFeature
//import Storage
//import Models
//import Combine
//import Utils
//import Habitat
//
//class StudyViewModelTests: XCTestCase {
//
//    var sut: StudyViewModel!
//    var localStorage: LocalStorageMock!
//    var deckRepository: DeckRepositoryMock!
//    var deck: Deck!
//    var dateHandler: DateHandlerProtocol!
//    var systemObserver: SystemObserverMock!
//    var uuidGenerator: UUIDGeneratorProtocol!
//    var cancellables: Set<AnyCancellable>!
//
//
//    override func setUpWithError() throws {
//        deckRepository = DeckRepositoryMock()
//        localStorage = LocalStorageMock()
//        deck = deckRepository.decks.first
//        dateHandler = DateHandlerMock()
//        systemObserver = SystemObserverMock()
//        setupHabitatForIsolatedTesting(deckRepository: deckRepository, collectionRepository: CollectionRepositoryMock(), dateHandler: dateHandler, uuidGenerator: UUIDHandlerMock(), systemObserver: systemObserver)
//
//        sut = .init()
//        uuidGenerator = UUIDHandlerMock()
//        cancellables = .init()
//    }
//
//    override func tearDownWithError() throws {
//        deckRepository = nil
//        localStorage = nil
//        deck = nil
//        sut = nil
//        cancellables.forEach { $0.cancel() }
//        cancellables = nil
//        dateHandler = nil
//        systemObserver = nil
//    }
//
//    func testCrammingStartup() {
//        sut.startup(deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let deckCards = deck.cardsIds.sorted(by: sortIds)
//        let resultCards = sut.cards
//        let result = sut.cards.map(\.id).sorted(by: sortIds)
//
//        XCTAssertEqual(deckCards, result)
//
//        resultCards.forEach { card in
//            XCTAssertEqual(card.woodpeckerCardInfo.step, 0)
//            XCTAssertFalse(card.woodpeckerCardInfo.isGraduated)
//        }
//
//    }
//
//    func testRepetitionStartupWithExistingSession() throws {
//        let cardIds = Array(deckRepository.cards.prefix(3).map(\.id))
//        let session = Session(cardIds: cardIds, date: dateHandler.today, deckId: deck.id, id: uuidGenerator.newId())
//        try deckRepository.createSession(session, for: deck)
//
//    sut.startup(deck: deckRepository.decks.first!, mode: .spaced)
//        let expectation = expectation(description: "fetch cards")
//        sut.$cards.sink { [unowned self] cards in
//            let first3Cards = Array(self.deckRepository.cards.prefix(3))
//            XCTAssertEqual(cards.sorted(by: sortById), first3Cards.sorted(by: sortById))
//            expectation.fulfill()
//        }
//        .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 1)
//    }
//
//    func testDidCreateNewSessionOnStartup() {
//        XCTAssertNil(deck.session)
//        sut.startup(deck: deck, mode: .spaced)
//
//        let expectation = expectation(description: "did handle events correctly")
//
//        let expectedSession = Session(cardIds: deck.cardsIds.sorted(by: { $0.uuidString > $1.uuidString } ), date: dateHandler.today, deckId: deck.id, id: uuidGenerator.newId())
//
//        sut.$cards.sink {[unowned self] cards in
////            XCTAssertNotNil(deck.session)
//            var session = deckRepository.decks.first!.session
//            let ids = session?.cardIds ?? []
//            session?.cardIds = ids.sorted(by: { $0.uuidString > $1.uuidString })
//            XCTAssertEqual(expectedSession.cardIds.sorted(by: sortIds), session?.cardIds.sorted(by: sortIds))
//            XCTAssertEqual(expectedSession.date, session?.date)
//            expectation.fulfill()
//        }
//        .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 1)
//    }
//
//
//    func testRepetitionStartupWithNewSessionFewerCardsThanLimit() {
//        XCTAssertEqual(sut.cards, [])
//        sut.startup(deck: deck, mode: .spaced)
//        let expectation = expectation(description: "fetch cards")
//        sut.$cards.sink { cards in
//
//            XCTAssertEqual(cards.sorted(by: self.sortById), self.deckRepository.cards.sorted(by: self.sortById).filter { $0.deckID == self.deck.id })
//            XCTAssertEqual(self.sut.cardsToEdit.count, 0)
//            XCTAssertEqual(self.sut.displayedCards.map(\.card.id), cards.prefix(2).reversed().map(CardViewModel.init).map(\.card.id))
//            expectation.fulfill()
//        }
//        .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 1)
//    }
//
//    func testRepetitionStartupWithNewSessionNoCards() {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[1]
//        deckRepository.cards = []
//        sut.startup(deck: deck, mode: .spaced)
//        let expectation = expectation(description: "fetch cards")
//        sut.$cards.sink { cards in
//            XCTAssertEqual(cards.count, 0)
//            XCTAssertEqual(self.sut.cardsToEdit.count, 0)
//            XCTAssertEqual(self.sut.displayedCards.count, 0)
//            expectation.fulfill()
//        }
//        .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 1)
//    }
//
//    func testRepetitionStartupWithNewSessionTooManyCards() {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[2]
//
//
//        sut.startup(deck: deck, mode: .spaced)
//        let expectation = expectation(description: "fetch cards")
//        sut.$cards.sink { cards in
//            XCTAssertEqual(cards.count, 3)
//            XCTAssertEqual(self.sut.cardsToEdit.count, 1)
//            XCTAssertEqual(self.sut.displayedCards.map(\.card.id), cards.prefix(2).reversed().map(CardViewModel.init).map(\.card.id))
//            var hasRepeated = false
//            for card in cards {
//                if self.sut.cardsToEdit.contains(where: { c in c.id == card.id }) {
//                    hasRepeated = true
//                }
//            }
//            XCTAssertFalse(hasRepeated)
//            expectation.fulfill()
//        }
//        .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 1)
//    }
//
//    func testRepetitionStartupWithNewSession2Cards() {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[3]
//
//        sut.startup(deck: deck, mode: .spaced)
//        let expectation = expectation(description: "fetch cards")
//        sut.$cards.sink { cards in
//            XCTAssertEqual(self.sut.displayedCards.map(\.card.id), cards.prefix(2).reversed().map(CardViewModel.init).map(\.card.id))
//            expectation.fulfill()
//        }
//        .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 1)
//    }
//
//    func testRepetitionStartupWithNewSession1Card() {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[1]
//
//        sut.startup(deck: deck, mode: .spaced)
//        let expectation = expectation(description: "fetch cards")
//        sut.$cards.sink { cards in
//            XCTAssertEqual(self.sut.displayedCards.map(\.card.id), cards.prefix(2).reversed().map(CardViewModel.init).map(\.card.id))
//            expectation.fulfill()
//        }
//        .store(in: &cancellables)
//
//        wait(for: [expectation], timeout: 1)
//    }
//
//    func testSpacedPressedButtonCardDidGoBack() throws {
//        XCTAssertEqual(sut.cards, [])
//
//        sut.startup(deck: deck, mode: .spaced)
//
//        let oldCard = sut.cards[0]
//        sut.cards[0] = Card(id: oldCard.id, front: oldCard.front, back: oldCard.back, color: oldCard.color, datesLogs: oldCard.datesLogs, deckID: oldCard.deckID, woodpeckerCardInfo: WoodpeckerCardInfo(step: 1, isGraduated: false, easeFactor: 2.5, streak: 0, interval: 0, hasBeenPresented: true), history: [])
//        //vai ficar no msm step, pq esta no 0
//
//        try sut.pressedButton(for: .wrongHard, deck: deck, mode: .spaced)
//
//        let modCard = sut.cards.first { card in
//            card.id == oldCard.id
//        }
//
//        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 0, isGraduated: false, easeFactor: 2.5, streak: 0, interval: 0, hasBeenPresented: true))
//        XCTAssertEqual(modCard?.history.count, 0)
//    }
//
//    func testSpacedPressedButtonCardDidStay() throws {
//        XCTAssertEqual(sut.cards, [])
//
//        sut.startup(deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//        let oldCard = sut.cards[0]
//        //vai ficar no msm step, pq esta no 0
//
//        try sut.pressedButton(for: .wrongHard, deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//
//        let modCard = sut.cards.first { card in
//            card.id == oldCard.id
//        }
//        var newInfo = oldCard.woodpeckerCardInfo
//        newInfo.hasBeenPresented = true
//
//        XCTAssertEqual(modCard?.woodpeckerCardInfo, newInfo)
//        XCTAssertEqual(modCard?.history.count, 0)
//    }
//
//    func testSpacedPressedButtonCardDidGoFoward() throws {
//        XCTAssertEqual(sut.cards, [])
//
//        sut.startup(deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//        let oldCard = sut.cards[0]
//        //vai ficar no msm step, pq esta no 0
//
//        try sut.pressedButton(for: .correct, deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//
//        let modCard = sut.cards.first { card in
//            card.id == oldCard.id
//        }
//
//        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 1, isGraduated: false, easeFactor: 2.5, streak: 1, interval: 0, hasBeenPresented: true))
//        XCTAssertEqual(modCard?.history.count, 0)
//    }
//
//    func testSpacedPressedButtonCardDidGraduate() throws {
//        XCTAssertEqual(sut.cards, [])
//
//        sut.startup(deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//        let oldCard = sut.cards[0]
//        //vai ficar no msm step, pq esta no 0
//
//        try sut.pressedButton(for: .correctEasy, deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//
//        let modCard = sut.cardsToEdit.first { card in
//            card.id == oldCard.id
//        }
//
//
//
//        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 0, isGraduated: true, easeFactor: 2.5, streak: 1, interval: 1, hasBeenPresented: true))
//        XCTAssertEqual(modCard?.history.count, oldCard.history.count + 1)
//        XCTAssertFalse(sut.cards.contains(where: { $0.id == oldCard.id }))
//        XCTAssertTrue(sut.cardsToEdit.contains(where: { $0.id == oldCard.id }))
//    }
//
//    func testSpacedPressedButtonGraduatedCardDemoted() throws {
//        XCTAssertEqual(sut.cards, [])
//
//        sut.startup(deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//        sut.cards.reverse()
//        let oldCard = sut.cards[0]
//
//
//        try sut.pressedButton(for: .wrongHard, deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//
//        let modCard = sut.cardsToEdit.first { card in
//            card.id == oldCard.id
//        }
//
//
//        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 0, isGraduated: false, easeFactor: 1.7, streak: 0, interval: 0, hasBeenPresented: true))
//        XCTAssertEqual(modCard?.history.count, 2)
//        XCTAssertFalse(sut.cards.contains(where: { $0.id == oldCard.id }))
//        XCTAssertTrue(sut.cardsToEdit.contains(where: { $0.id == oldCard.id }))
//    }
//
//    func testSpacedPressedButtonGraduatedCardReviwed() throws {
//        XCTAssertEqual(sut.cards, [])
//
//        sut.startup(deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//        sut.cards.reverse()
//        let oldCard = sut.cards[0]
//
//
//        try sut.pressedButton(for: .correct, deck: deck, mode: .spaced, cardSortingFunc: sortCardByStepMock)
//
//        let modCard = sut.cardsToEdit.first { card in
//            card.id == oldCard.id
//        }
//
//
//        XCTAssertEqual(modCard?.woodpeckerCardInfo, WoodpeckerCardInfo(step: 0, isGraduated: true, easeFactor: 2.5, streak: 1, interval: 1, hasBeenPresented: true))
//        XCTAssertEqual(modCard?.history.count, 2)
//        XCTAssertFalse(sut.cards.contains(where: { $0.id == oldCard.id }))
//        XCTAssertTrue(sut.cardsToEdit.contains(where: { $0.id == oldCard.id }))
//    }
//
//    func testCrammingPressedButtonWrongHard() throws {
//        sut.startup(deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let firstCard = sut.cards.first!
//        try sut.pressedButton(for: .wrongHard, deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let deckCards = deck.cardsIds.sorted(by: sortIds)
//
//        let result = sut.cards.map(\.id).sorted(by: sortIds)
//
//        XCTAssertEqual(deckCards, result)
//
//        let modifiedCard = sut.cards.first(where: { $0.id == firstCard.id})
//        XCTAssertEqual(firstCard.woodpeckerCardInfo.step, modifiedCard?.woodpeckerCardInfo.step)
//    }
//
//    func testCrammingPressedButtonWrong() throws {
//        sut.startup(deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let firstCard = sut.cards.first!
//        try sut.pressedButton(for: .wrong, deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let deckCards = deck.cardsIds.sorted(by: sortIds)
//
//
//        let result = sut.cards.map(\.id).sorted(by: sortIds)
//
//        XCTAssertEqual(deckCards, result)
//
//        let modifiedCard = sut.cards.first(where: { $0.id == firstCard.id})
//        XCTAssertEqual(firstCard.woodpeckerCardInfo.step, modifiedCard?.woodpeckerCardInfo.step)
//    }
//
//    func testCrammingPressedButtonCorrect() throws {
//        sut.startup(deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let firstCard = sut.cards.first!
//        try sut.pressedButton(for: .correct, deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let deckCards = deck.cardsIds.sorted(by: sortIds)
//
//
//        let result = sut.cards.map(\.id).sorted(by: sortIds)
//
//        XCTAssertEqual(deckCards, result)
//
//        let modifiedCard = sut.cards.first(where: { $0.id == firstCard.id})
//
//
//        XCTAssertEqual(firstCard.woodpeckerCardInfo.step + 1, modifiedCard?.woodpeckerCardInfo.step)
//    }
//
//    func testCrammingPressedButtonCorrectEasy() throws {
//        sut.startup(deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let firstCard = sut.cards.first!
//        try sut.pressedButton(for: .correctEasy, deck: deck, mode: .cramming, cardSortingFunc: sortCardByStepMock)
//        let deckCards = deck.cardsIds.sorted(by: sortIds)
//
//        let result = sut.cards.map(\.id).sorted(by: sortIds)
//
//        for deck in result {
//            XCTAssertNotEqual(deck, firstCard.id)
//        }
//        XCTAssertNotEqual(deckCards, result)
//    }
//
//
//
//    // ordena todos os learning antes, depois os reviewing
//    func sortCardByStepMock(card0: Card, card1: Card) -> Bool {
//        if card0.woodpeckerCardInfo.isGraduated {
//            return false
//        } else if card1.woodpeckerCardInfo.isGraduated {
//            return true
//        } else {
//            return card0.woodpeckerCardInfo.step < card1.woodpeckerCardInfo.step
//        }
//    }
//
//    func sortById(d0: Card, d1: Card) -> Bool {
//        return d0.id.uuidString > d1.id.uuidString
//    }
//
//    func sortIds(id0: UUID, id1: UUID) -> Bool {
//        return id0.uuidString > id1.uuidString
//    }
//
//
//    func testIsVOOn() throws {
//        let cardIds = Array(deckRepository.cards.prefix(3).map(\.id))
//        let session = Session(cardIds: cardIds, date: dateHandler.today, deckId: deck.id, id: uuidGenerator.newId())
//        try deckRepository.createSession(session, for: deckRepository.decks.first!)
//
//        sut.startup(deck: deckRepository.decks.first!, mode: .spaced)
//        XCTAssertFalse(sut.isVOOn)
//        systemObserver.voiceOverDidChangeSubject.send(true)
//        XCTAssertTrue(sut.isVOOn)
//    }
//
//    func testSaveEditedCards() throws {
//        let expectation = expectation(description: "receive card for id")
//        self.deck = deckRepository.decks[1]
//
//        sut.startup(deck: deckRepository.decks[1], mode: .spaced)
//        let card = sut.cards.first!
//        XCTAssertEqual(card.woodpeckerCardInfo.interval, 0)
//        try sut.pressedButton(for: .correctEasy, deck: deckRepository.decks[1], mode: .spaced)
//        try sut.saveChanges(deck: deckRepository.decks[1], mode: .spaced)
//
//        deckRepository.fetchCardById(deckRepository.decks[1].cardsIds.first!)
//            .replaceError(with: deckRepository.cards.first!)
//            .sink { receivedCard in
//                XCTAssertEqual(receivedCard.woodpeckerCardInfo.interval, 1)
//                expectation.fulfill()
//
//            }
//            .store(in: &cancellables)
//
//
//
//        wait(for: [expectation], timeout: 1)
//    }
//
//    // MARK: - Tests SessionProgress
//
//    // There are 0 cards in a Spaced session
//    func testGetSessionCardsSpacedWhen0() {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[1]
//        deckRepository.cards = []
//        sut.startup(deck: deck, mode: .spaced)
//        XCTAssertEqual(sut.getSessionTotalCards(), 0)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 0)
//    }
//
//    // There are 0 cards in a Cramming session
//    func testGetSessionCardsCrammingWhen0() {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[1]
//        deckRepository.cards = []
//
//        sut.startup(deck: deck, mode: .cramming)
//        XCTAssertEqual(sut.getSessionTotalCards(), 0)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .cramming), 0)
//    }
//
//    // There are 2 unseen cards in a Spaced session
//    func testGetSessionCardsSpacedWhen2() {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[4]
//
//        sut.startup(deck: deck, mode: .spaced)
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 1)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 1)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 0)
//    }
//
//    // There are 2 unseen cards in a Cramming session
//    func testGetSessionCardsCrammingWhen2() {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[4]
//
//        sut.startup(deck: deck, mode: .cramming)
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .cramming), 0)
//    }
//
//    // Progress in a Cramming session after seeing 1 out of 4 cards (clicked correct easy)
//    func testProgressWhen1DoneCramming() throws {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[2]
//
//        sut.startup(deck: deck, mode: .cramming)
//        XCTAssertEqual(sut.getSessionTotalCards(), 4)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .cramming), 0)
//
//        try sut.pressedButton(for: .correctEasy, deck: deck, mode: .cramming)
//        try sut.saveChanges(deck: deck, mode: .cramming)
//
//        XCTAssertEqual(sut.getSessionTotalCards(), 4)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 1)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .cramming), 0)
//    }
//
//    // Progress in a Cramming session after seeing 0 out of 4 cards (clicked wrong)
//    func testProgressWhenClickedHardCramming() throws {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[2]
//
//        sut.startup(deck: deck, mode: .cramming)
//        XCTAssertEqual(sut.getSessionTotalCards(), 4)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .cramming), 0)
//
//        try sut.pressedButton(for: .wrong, deck: deck, mode: .cramming)
//        try sut.saveChanges(deck: deck, mode: .cramming)
//
//        XCTAssertEqual(sut.getSessionTotalCards(), 4)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .cramming), 0)
//    }
//
//    // Progress in a Cramming session after seeing 2 out of 4 cards (clicked correct easy)
//    func testProgressWhen2SeenCramming() throws {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[2]
//
//        sut.startup(deck: deck, mode: .cramming)
//        XCTAssertEqual(sut.getSessionTotalCards(), 4)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .cramming), 0)
//
//        try sut.pressedButton(for: .correctEasy, deck: deck, mode: .cramming)
//        try sut.saveChanges(deck: deck, mode: .cramming)
//        try sut.pressedButton(for: .correctEasy, deck: deck, mode: .cramming)
//        try sut.saveChanges(deck: deck, mode: .cramming)
//
//        XCTAssertEqual(sut.getSessionTotalCards(), 4)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 2)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .cramming), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .cramming), 0)
//    }
//
//    // Progress in a Spaced session after seeing 1 reviewing out of 2 cards (clicked wrong)
//    func testProgressWhen1ReviewingDoneSpaced() throws {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[3]
//
//        sut.startup(deck: deck, mode: .spaced)
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 2)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 0)
//
//        try sut.pressedButton(for: .wrong, deck: deck, mode: .spaced)
//        try sut.saveChanges(deck: deck, mode: .spaced)
//
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 1)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 2)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 1)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 0)
//    }
//
//    // Progress in a Spaced session after seeing 1 learning out of 2 cards (clicked correct easy)
//    func testProgressWhen1LearningDoneSpaced() throws {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[5]
//
//        sut.startup(deck: deck, mode: .spaced)
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 2)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 0)
//
//        try sut.pressedButton(for: .correctEasy, deck: deck, mode: .spaced)
//        try sut.saveChanges(deck: deck, mode: .spaced)
//
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 1)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 2)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 1)
//    }
//
//    // Progress in a Spaced session after rating 1 learning out of 2 cards, not counting as Seen (clicked wrong)
//    func testProgressWhen0LearningDoneSpaced() throws {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[5]
//
//        sut.startup(deck: deck, mode: .spaced)
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 2)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 0)
//
//        try sut.pressedButton(for: .wrongHard, deck: deck, mode: .spaced)
//        try sut.saveChanges(deck: deck, mode: .spaced)
//
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 2)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 0)
//    }
//
//    // Progress in a Spaced session after rating 1 learning and 1 reviewing out of 2 cards
//    func testProgressWhenLearningAndReviewingDoneSpaced() throws {
//        XCTAssertEqual(sut.cards, [])
//        self.deck = deckRepository.decks[4]
//
//        sut.startup(deck: deck, mode: .spaced)
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 0)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 1)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 0)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 1)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 0)
//
//        try sut.pressedButton(for: .correctEasy, deck: deck, mode: .spaced)
//        try sut.saveChanges(deck: deck, mode: .spaced)
//        try sut.pressedButton(for: .correctEasy, deck: deck, mode: .spaced)
//        try sut.saveChanges(deck: deck, mode: .spaced)
//
//        XCTAssertEqual(sut.getSessionTotalCards(), 2)
//        XCTAssertEqual(sut.getSessionTotalSeenCards(), 2)
//        XCTAssertEqual(sut.getSessionReviewingCards(mode: .spaced), 1)
//        XCTAssertEqual(sut.getSessionReviewingSeenCards(mode: .spaced), 1)
//        XCTAssertEqual(sut.getSessionLearningCards(mode: .spaced), 1)
//        XCTAssertEqual(sut.getSessionLearningSeenCards(mode: .spaced), 1)
//    }
//
//
//    // MARK: - Tests Session Creation
//
//    func testNewSessionCreationAtEndOfSession() {
//
//    }
//}
