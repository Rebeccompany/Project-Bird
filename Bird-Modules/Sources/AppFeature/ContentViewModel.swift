//
//  ContentViewModel.swift
//  
//
//  Created by Gabriel Ferreira de Carvalho on 14/09/22.
//

import Foundation
import Models
import Combine
import Storage
import DeckFeature
import Habitat
import Utils
import SwiftUI

//swiftlint:disable trailing_closure
public final class ContentViewModel: ObservableObject {
    
    // MARK: Collections
    @Published var collections: [DeckCollection]
    @Published var decks: [Deck]
    @Published var todayDecks: [Deck]
    
    // MARK: View Bindings
#if os(iOS)
    @Published var sidebarSelection: SidebarRoute? = .allDecks
#elseif os(macOS)
    @Published var sidebarSelection: SidebarRoute = .allDecks
#endif
    @Published var selection: Set<Deck.ID>
    @Published var searchText: String
    @Published var detailType: DetailDisplayType
    @Published var sortOrder: [KeyPathComparator<Deck>]
    @Published var shouldReturnToGrid: Bool

    // MARK: Repositories
    @Dependency(\.collectionRepository) private var collectionRepository: CollectionRepositoryProtocol
    @Dependency(\.deckRepository) private var deckRepository: DeckRepositoryProtocol
    @Dependency(\.displayCacher) private var displayCacher: DisplayCacherProtocol
    @Dependency(\.dateHandler) private var dateHandler: DateHandlerProtocol
    
    private var cancellables: Set<AnyCancellable>
    
    var detailTitle: String {
        switch sidebarSelection {
        case .allDecks:
            return NSLocalizedString("baralhos_title", bundle: .module, comment: "")
        case .decksFromCollection(let collection):
            return collection.name
        #if os(iOS)
        case .none:
            return ""
        #endif
        }
    }
    
    var selectedCollection: DeckCollection? {
        switch sidebarSelection {
        case .allDecks:
            return nil
        case .decksFromCollection(let collection):
            return collection
        #if os(iOS)
        case .none:
            return nil
        #endif
        }
    }
    
    public init() {
        self.collections = []
        self.cancellables = .init()
        self.decks = []
        self.todayDecks = []
        self.selection = .init()
        self.searchText = ""
        self.detailType = .grid
        self.shouldReturnToGrid = true
        self.sortOrder = [KeyPathComparator(\Deck.name)]
    }
    
    private var collectionListener: AnyPublisher<[DeckCollection], Never> {
        collectionRepository
            .listener()
            .handleEvents(receiveCompletion: { [weak self] completion in self?.handleCompletion(completion) })
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    private var deckListener: AnyPublisher<[Deck], Never> {
        deckRepository
            .deckListener()
            .handleEvents(receiveCompletion: { [weak self] completion in self?.handleCompletion(completion) })
            .replaceError(with: [])
            .eraseToAnyPublisher()
    }
    
    var filteredDecks: [Deck] {
        let filteredBySelection = mapDecksBySidebarSelection(decks: decks, sidebarSelection: sidebarSelection)
        let filteredBySearch = filterDecksBySearchText(filteredBySelection, searchText: searchText)
        return filteredBySearch
    }
    
    func startup() {
        collectionListener
            .assign(to: &$collections)
        
        deckListener
            .assign(to: &$decks)
        
        detailType = displayCacher.getCurrentDetailType() ?? .grid
        shouldReturnToGrid = detailType == .grid
        
        $decks
            .tryMap(filterDecksForToday)
            .replaceError(with: [])
            .assign(to: &$todayDecks)
    }
    
    func bindingToDeck(_ deck: Deck) -> Binding<Deck> {
        Binding<Deck> { [weak self] in
            guard let self = self,
                  let index = self.decks.firstIndex(where: { $0.id == deck.id }) else {
                preconditionFailure("A deck that do not exist was passed")
            }
            
            return self.decks[index]
            
        } set: { [weak self] newValue in
            guard let self = self,
                  let index = self.decks.firstIndex(where: { $0.id == newValue.id }) else {
                preconditionFailure("A deck that do not exist was passed")
            }
            
            return self.decks[index] = newValue
        }
    }
    
    func changeDetailType(for newDetailType: DetailDisplayType) {
        detailType = newDetailType
        displayCacher.saveDetailType(detailType: newDetailType)
    }
    
    private func mapDecksBySidebarSelection(decks: [Deck], sidebarSelection: SidebarRoute?) -> [Deck] {
        switch sidebarSelection ?? .allDecks {
        case .allDecks:
            return decks
        case .decksFromCollection(let collection):
            return decks.filter { deck in
                deck.collectionId == collection.id
            }
        }
    }
            
    private func filterDecksBySearchText(_ decks: [Deck], searchText: String) -> [Deck] {
        if searchText.isEmpty {
            return decks
        } else {
            return decks.filter { $0.name.capitalized.contains(searchText.capitalized) }
        }
    }
    
    private func filterDecksForToday(_ decks: [Deck]) -> [Deck] {
        
        decks.filter {
            guard let session = $0.session else { return false }

            guard !session.cardIds.isEmpty else { return false }
            return dateHandler.isToday(date: session.date) || session.date < dateHandler.today
        }
    }
    
    private func handleCompletion(_ completion: Subscribers.Completion<RepositoryError>) {
        switch completion {
        case .finished:
            break
        case .failure(_):
            break
        }
    }
    
    func deleteCollection(at index: IndexSet) throws {
        let collections = self.collections
        let collectionsToDelete = index.map { i in collections[i] }
        
        try collectionsToDelete.forEach { collection in
            try deleteCollection(collection)
        }
    }
    
    func deleteCollection(_ collection: DeckCollection) throws {
        try collectionRepository.deleteCollection(collection)
    }
    
    func deleteDecks() throws {
        let decksToBeDeleted = self.decks.filter { deck in
            selection.contains(deck.id)
        }
        
        guard !decksToBeDeleted.isEmpty else {
            throw RepositoryError.couldNotDelete
        }
        
        try decksToBeDeleted
            .forEach { deck in
                try deckRepository.deleteDeck(deck)
            }
            
        selection = Set()
    }
    
    func editDeck() -> Deck? {
        guard
            selection.count == 1,
            let deck = decks.first(where: { deck in deck.id == selection.first })
        else { return nil }
        
        return deck
    }
    
    func deleteDeck(_ deck: Deck) throws {
        try deckRepository.deleteDeck(deck)
    }
    
    func didDeckPresentationStatusChanged(_ status: Bool) {
        guard status == false else {
            return
        }
        
        selection = Set()
    }
    
    func didCollectionPresentationStatusChanged(_ status: Bool) {
        guard status == false else {
            return
        }
    }
}
