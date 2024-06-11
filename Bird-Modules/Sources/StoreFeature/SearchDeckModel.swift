//
//  SearchDeckModel.swift
//  
//
//  Created by Gabriel Ferreira de Carvalho on 04/12/22.
//

import Foundation
import Models
import Habitat
import Puffins
import Combine

final class SearchDeckModel: ObservableObject {
    
    @Published var decks: [ExternalDeck] = []
    @Published var viewState: ViewState = .loaded
    @Published var searchText: String = ""
    @Published var selectedFilter: FilterType = .name
    @Published var shouldLoadMore: Bool = false
    
    @Dependency(\.externalDeckService) private var deckService
    private var cancellables = Set<AnyCancellable>()
    private var currentPage = 0
    
    enum FilterType: String {
        case name
        case author
    }
    
    func startUp() {
        searchPublisher
            .receive(on: RunLoop.main)
            .sink {[weak self] decks in
                if let decks {
                    self?.viewState = .loaded
                    self?.shouldLoadMore = true
                    self?.decks = decks
                } else {
                    self?.viewState = .error
                }
            }
            .store(in: &cancellables)
    }

    private var combineTextAndFilterPublisher: AnyPublisher<(String, FilterType), Never> {
        Publishers.CombineLatest($searchText, $selectedFilter)
            .filter { !$0.0.isEmpty }
            .removeDuplicates { previous, actual in
                previous.0 == actual.0 && previous.1 == actual.1
            }
            .eraseToAnyPublisher()
    }

    //swiftlint: disable trailing_closure
    //swiftlint: disable discouraged_optional_collection
    private var searchPublisher: AnyPublisher<[ExternalDeck]?, Never> {
        combineTextAndFilterPublisher
            .debounce(for: .milliseconds(500), scheduler: RunLoop.main)
            .receive(on: RunLoop.main)
            .handleEvents(receiveOutput: { [weak self] _ in
                self?.viewState = .loading
                self?.currentPage = 0
            })
            .flatMap { [weak self] searchContent, selectedFilter in
                guard let self
                else {
                    return Fail(outputType: [ExternalDeck]?.self, failure: URLError(.badServerResponse)).eraseToAnyPublisher()
                }
                
                return self.deckService
                    .searchDecks(
                        type: selectedFilter.rawValue,
                        value: searchContent,
                        page: self.currentPage
                    )
                    .map { $0 as [ExternalDeck]? }
                    .eraseToAnyPublisher()
            }
            .replaceError(with: nil)
            .eraseToAnyPublisher()
    }
    
    func loadMoreDecks() {
        currentPage += 1
        loadDecks(page: currentPage)
    }
    
    func reloadDecks() {
        currentPage = 0
        viewState = .loading
        decks = []
        loadDecks(page: currentPage)
    }
    
    private func loadDecks(page: Int) {
        deckService
            .searchDecks(type: selectedFilter.rawValue, value: searchText, page: currentPage)
            .receive(on: RunLoop.main)
            .sink {[weak self] completion in
                switch completion {
                case .finished:
                    self?.viewState = .loaded
                case .failure(_):
                    self?.viewState = .error
                }
            } receiveValue: {[weak self] decks in
                if decks.isEmpty {
                    self?.shouldLoadMore = false
                } else {
                    self?.shouldLoadMore = true
                    self?.decks.append(contentsOf: decks)
                }
            }
            .store(in: &cancellables)
    }
}
