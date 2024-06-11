//
//  DeckTableView.swift
//  
//
//  Created by Nathalia do Valle Papst on 15/09/22.
//

import SwiftUI
import Models
import HummingBird
import NewDeckFeature

struct DeckTableView: View {
    @EnvironmentObject private var viewModel: ContentViewModel
    #if os(iOS)
    @Environment(\.horizontalSizeClass) private var horizontalSizeClass
    #endif
    
    @State private var showCollectionSelection = false
    @State private var deckToBeEdited: Deck?
    
    var editAction: (Deck) -> Void
    
    private var sortedDecks: [Deck] {
        viewModel.filteredDecks.sorted(using: viewModel.sortOrder)
    }
    
    var body: some View {
        if viewModel.filteredDecks.isEmpty {
            EmptyStateView(component: .deck)
        } else {
            content
                .sheet(isPresented: $showCollectionSelection) {
                    CollectionList(viewModel: viewModel, deck: $deckToBeEdited)
                        .frame(width: 500, height: 500)
                }
        }
    }
    
    @ViewBuilder
    private var content: some View {
        VStack(alignment: .leading) {
            if !viewModel.todayDecks.isEmpty && viewModel.selectedCollection == nil {
                Text(NSLocalizedString("sessões_para_hoje", bundle: .module, comment: ""))
                    .padding(.leading)
                    .padding(.top)
                    .font(.title3)
                    .bold()
                SessionsForTodayView()
            }
            Text(NSLocalizedString("baralhos", bundle: .module, comment: ""))
                .padding(.leading)
                .font(.title3)
                .bold()
#if os(iOS)
            if horizontalSizeClass == .compact {
                list
            } else {
                table
            }
            
#elseif os(macOS)
            table
#endif
            
        }
#if os(iOS)
        .toolbarBackground(.visible, for: .bottomBar)
#endif
    }
    
    @ViewBuilder
    private var list: some View {
        List(sortedDecks, selection: $viewModel.selection) { deck in
            NavigationLink(value: StudyRoute.deck(deck)) {
                cell(for: deck)
            }
            .swipeActions {
                Button {
                    try? viewModel.deleteDeck(deck)
                } label: {
                    Text("deletar", bundle: .module)
                }
                .tint(.red)
            }
            .swipeActions(edge: .leading, allowsFullSwipe: false) {
                Button {
                    editAction(deck)
                } label: {
                    Text("editar", bundle: .module)
                }
                .tint(HBColor.actionColor)
                Button {
                    deckToBeEdited = deck
                    showCollectionSelection = true
                } label: {
                    Text("mover_colecao", bundle: .module)
                }
                .tint(HBColor.collectionYellow)
            }
            .contextMenu {
                contextMenu(for: deck)
            }
        }
        .animation(.linear, value: sortedDecks)
        #if os(iOS)
        .toolbarBackground(.visible, for: .tabBar)
        #endif
        .listStyle(.plain)
        .onDisappear {
            Task {
                await MainActor.run {
                    viewModel.selection = Set()
                }
            }
        }
    }
    
    @ViewBuilder
    private var table: some View {
        Table(selection: $viewModel.selection, sortOrder: $viewModel.sortOrder) {
            TableColumn("") { (deck: Deck) in
                Image(systemName: deck.icon)
                    .font(.system(size: 14))
                    .foregroundColor(HBColor.color(for: deck.color))
                    .background {
                        Circle()
                            .fill(HBColor.color(for: deck.color).opacity(0.2))
                            .frame(width: 35, height: 35)
                    }
                    .frame(width: 35, height: 35)
            }.width(35)
            TableColumn(NSLocalizedString("nome", bundle: .module, comment: ""), value: \.name) { deck in
                Text(deck.name)
            }
            TableColumn("Flashcards", value: \.cardCount) { deck in
                Text("\(deck.cardCount) flashcards")
            }
            TableColumn(NSLocalizedString("ultimo_acesso", bundle: .module, comment: ""), value: \.datesLogs.lastAccess) { deck in
                Text(deck.datesLogs.lastAccess, style: .date)
            }
            TableColumn(NSLocalizedString("acessar", bundle: .module, comment: "")) { deck in
                NavigationLink(value: StudyRoute.deck(deck)) {
                    Text(NSLocalizedString("abrir", bundle: .module, comment: ""))
                    
                }
                .tint(HBColor.color(for: deck.color))
                .buttonStyle(.bordered)
                #if os(iOS)
                .buttonBorderShape(.capsule)
                #endif
            }.width(90)
        } rows: {
            ForEach(sortedDecks) { deck in
                TableRow(deck)
                    .contextMenu {
                        contextMenu(for: deck)
                    }
            }
        }.animation(.linear, value: viewModel.sortOrder)
    }
    
    @ViewBuilder
    private func cell(for deck: Deck) -> some View {
        HStack {
            Image(systemName: deck.icon)
                .foregroundColor(HBColor.color(for: deck.color))
                .background(
                    Circle()
                        .fill(HBColor.color(for: deck.color).opacity(0.2))
                    
                        .frame(width: 35, height: 35)
                    
                )
                .frame(width: 35, height: 35)
                .padding(.trailing, 8)
            Text(deck.name)
                .foregroundColor(.primary)
        }
        .padding(.leading, 4)
    }
    
    @ViewBuilder
    private func contextMenu(for deck: Deck) -> some View {
        Button {
            editAction(deck)
        } label: {
            Label(NSLocalizedString("editar", bundle: .module, comment: ""), systemImage: "pencil")
        }
        
        Button(role: .destructive) {
            try? viewModel.deleteDeck(deck)
        } label: {
            Label(NSLocalizedString("deletar", bundle: .module, comment: ""), systemImage: "trash")
        }
        
        Button {
            deckToBeEdited = deck
            showCollectionSelection = true
        } label: {
            Text("mover_colecao", bundle: .module)
        }
    }
}
