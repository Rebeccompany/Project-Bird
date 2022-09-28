//
//  SwiftUIView.swift
//  
//
//  Created by Marcos Chevis on 08/09/22.
//

import SwiftUI
import Storage
import Models
import HummingBird
import Utils

public struct StudyView: View {
    @StateObject private var viewModel: StudyViewModel = StudyViewModel()
    @Environment(\.dismiss) private var dismiss
    @State private var showingErrorAlert: Bool = false
    @State private var selectedErrorMessage: AlertText = .deleteCard
    
    var deck: Deck
    
    public init(deck: Deck) {
        self.deck = deck
    }
    
    private func toString(_ attributed: AttributedString) -> String {
        NSAttributedString(attributed).string
    }
    
    private func generateAttributedLabel() -> String {
        if !viewModel.cards.isEmpty {
            let card = viewModel.displayedCards[0].card
            guard let isFlipped = viewModel.displayedCards.last?.isFlipped else {
                return ""
            }
            
            if !isFlipped {
                return "Frente: " + toString(card.front)
            } else {
                return "Verso: " + toString(card.back)
            }
        }
        return ""
    }
    //swiftlint:disable trailing_closure
    public var body: some View {
        NavigationStack {
            ZStack {
                if !viewModel.displayedCards.isEmpty {
                    
                    VStack {
                        FlashcardDeckView(cards: $viewModel.displayedCards)
                            .zIndex(1)
                            .padding(.vertical)
                            .accessibilityElement(children: .ignore)
                            .accessibilityAddTraits(.isButton)
                            .accessibilityLabel(generateAttributedLabel())
                            .accessibilityHidden(viewModel.cards.isEmpty)
                        
                        
                        HStack(alignment: .top) {
                            ForEach(UserGrade.allCases) { userGrade in
                                Spacer()
                                DifficultyButtonView(userGrade: userGrade, isDisabled: $viewModel.shouldButtonsBeDisabled, isVOOn: $viewModel.isVOOn) { userGrade in
                                    withAnimation {
                                        do {
                                            try viewModel.pressedButton(for: userGrade, deck: deck)
                                        } catch {
                                            selectedErrorMessage = .gradeCard
                                            showingErrorAlert = true
                                        }
                                    }
                                }
                                Spacer()
                            }
                        }
                        .padding()
                        .accessibilityElement(children: .contain)
                        .accessibilityHint("Escolha nível de dificuldade")
                        .accessibilityLabel("Quatro Botões.")
                    }
                    
                    
                } else {
                    EndOfStudyView {
                        do {
                            try viewModel.saveChanges(deck: deck)
                            dismiss()
                        } catch {
                            selectedErrorMessage = .saveStudy
                            showingErrorAlert = true
                        }
                    }
                }
            }
            .viewBackgroundColor(HBColor.primaryBackground)
            .navigationTitle(deck.name)
            .toolbar(content: {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(role: .destructive) {
                        do {
                            try viewModel.saveChanges(deck: deck)
                            dismiss()
                        } catch {
                            selectedErrorMessage = .saveStudy
                            showingErrorAlert = true
                        }
                    } label: {
                        Text("Sair")
                    }
                    .foregroundColor(.red)
                    
                    
                }
            })
            .navigationBarTitleDisplayMode(.inline)
            .onAppear {
                viewModel.startup(deck: deck)
            }
            
            .alert(isPresented: $showingErrorAlert) {
                Alert(title: Text(selectedErrorMessage.texts.title),
                      message: Text(selectedErrorMessage.texts.message),
                      dismissButton: .default(Text("Fechar")))
            }
        }
        
    }
}

struct StudyView_Previews: PreviewProvider {
    static var repo: DeckRepositoryMock { DeckRepositoryMock() }
    
    static var previews: some View {
        StudyView(deck: repo.decks.first { $0.id == repo.deckWithCardsId }!)
    }
}
