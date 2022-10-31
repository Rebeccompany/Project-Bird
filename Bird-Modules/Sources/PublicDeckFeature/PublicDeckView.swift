//
//  PublicDeckView.swift
//  
//
//  Created by Rebecca Mello on 25/10/22.
//

import SwiftUI
import HummingBird

struct PublicDeckView: View {
    @Binding var description: String
    @StateObject private var viewModel: PublicDeckViewModel = PublicDeckViewModel()
    @State private var shouldDisplayNewFlashcard: Bool = false
    
    
    var body: some View {
        ScrollView {
            VStack {
                VStack {
                    HeaderPublicDeckView()
                    HStack {
                        Button {
                            
                        } label: {
                            Image(systemName: "square.and.arrow.down")
                            Text("Download")
                        }
                        .bold()
                        .buttonStyle(.borderedProminent)
                        .tint(HBColor.actionColor.opacity(0.15))
                        .foregroundColor(HBColor.actionColor)
                        .padding(.bottom)
                        
                        Button {
                            
                        } label: {
                            Image(systemName: "square.and.arrow.up")
                            Text("Compartilhar")
                        }
                        .bold()
                        .buttonStyle(.borderedProminent)
                        .tint(HBColor.actionColor.opacity(0.15))
                        .foregroundColor(HBColor.actionColor)
                        .padding(.bottom)
                    }
                    
                    TextEditor(text: $description)
                        .foregroundColor(.black)
                        .padding([.horizontal, .bottom], 16)
                        .scrollContentBackground(.hidden)
                        .background(.white)
                        .frame(height: 300)
                        .clipShape(
                            RoundedRectangle(cornerRadius: 16)
                        )
                        .padding(.bottom)
                }
                
                LazyVStack(alignment: .leading){
                    Text("Flashcards")
                        .font(.title3)
                        .bold()
                }
                
                LazyVGrid(columns: [GridItem(.adaptive(minimum: 160, maximum: 180), spacing: 12, alignment: .top)], spacing: 12) {
                    ForEach(viewModel.cards) { card in
                        FlashcardCell(card: card) {
                            shouldDisplayNewFlashcard = true
                        }
                    }
                    .listRowSeparator(.hidden)
                }
                .padding(.horizontal)
            }
            .padding()
        }
        .viewBackgroundColor(HBColor.primaryBackground)
    }
}

struct SwiftUIView_Previews: PreviewProvider {
    static var previews: some View {
        PublicDeckView(description: .constant("dasdsadasdasda"))
    }
}
