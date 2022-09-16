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

public struct StudyView: View {
    @ObservedObject private var viewModel: StudyViewModel
    @Environment(\.dismiss) var dismiss
    
    public init(viewModel: StudyViewModel) {
        self.viewModel = viewModel
    }
    
    private func toString(_ attributed: AttributedString) -> String {
        NSAttributedString(attributed).string
    }
    
    private func generateAttributedLabel() -> String {
        if !viewModel.cards.isEmpty {
            if !viewModel.displayedCards[1].isFlipped {
                return "Frente: " + toString(viewModel.displayedCards[0].card.front) + "Olha que bonito."
            } else {
                return "Verso: " + toString(viewModel.displayedCards[0].card.back) + "É o Chevis."
            }
        }
        return ""
    }
    
    public var body: some View {
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
                            DifficultyButtonView(userGrade: userGrade, isDisabled: $viewModel.shouldButtonsBeDisabled) { userGrade in
                                withAnimation {
                                    viewModel.pressedButton(for: userGrade)
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
                Text("EmptyState")
            }
        }
        .background(HBColor.primaryBackground)
        .navigationTitle(viewModel.deck.name)
        .toolbar(content: {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(role: .destructive) {
                    viewModel.saveChanges()
                    dismiss()
                } label: {
                    Text("Sair")
                }
                .foregroundColor(.red)
            

            }
        })
        .navigationBarTitleDisplayMode(.inline)
        .onAppear {
            viewModel.startup()
        }
        
    }
}

struct StudyView_Previews: PreviewProvider {
    static var repo: DeckRepositoryMock { DeckRepositoryMock() }
    
    static var previews: some View {
        
        Group {
            NavigationView {
                StudyView(
                    viewModel: StudyViewModel(
                        deckRepository: repo,
                        sessionCacher: SessionCacher(
                            storage: LocalStorageMock()
                        ),
                        deck: repo.decks.first!,
                        dateHandler: DateHandler()
                    )
                )
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 12"))
            .previewDisplayName("iPhone 12")
            
            NavigationView {
                StudyView(
                    viewModel: StudyViewModel(
                        deckRepository: repo,
                        sessionCacher: SessionCacher(
                            storage: LocalStorageMock()
                        ),
                        deck: repo.decks.first!,
                        dateHandler: DateHandler()
                    )
                )
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone 13 Pro Max"))
            .previewDisplayName("iPhone 13 Pro Max")
            
            
            NavigationStack {
                StudyView(
                        viewModel: StudyViewModel(
                            deckRepository: repo,
                            sessionCacher: SessionCacher(
                                storage: LocalStorageMock()
                            ),
                            deck: repo.decks.first!,
                            dateHandler: DateHandler()
                        )
                    )
            }
            .previewDevice(PreviewDevice(rawValue: "iPad Pro (12.9-inch)"))
            .previewDisplayName("iPad Pro (12.9-inch)")
            
            NavigationView {
                StudyView(
                    viewModel: StudyViewModel(
                        deckRepository: repo,
                        sessionCacher: SessionCacher(
                            storage: LocalStorageMock()
                        ),
                        deck: repo.decks.first!,
                        dateHandler: DateHandler()
                    )
                )
            }
            .previewDevice(PreviewDevice(rawValue: "iPhone SE (3rd generation)"))
            .previewDisplayName("iPhone SE (3rd generation)")
        }
    }
}
