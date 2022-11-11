//
//  DeckForTodayCell.swift
//  
//
//  Created by Caroline Taus on 19/10/22.
//

import SwiftUI
import HummingBird
import Models


struct DeckForTodayCell: View {
    var deck: Deck
    
    var body: some View {
        
        HStack {
            IconCircleView(iconName: deck.icon)
                .padding(.vertical, 4)
            VStack(alignment: .leading) {
                Text(deck.name)
                    .font(.title3)
                    .bold()
                
                Text("\(deck.session?.cardIds.count ?? 404) cartas para hoje")
                    .font(.subheadline)
            }
            .foregroundColor(Color.white)
            Spacer()
        }
        .padding(.horizontal)
        .frame(height: 80)
        .background {
            RoundedRectangle(cornerRadius: 8)
                .fill(HBColor.color(for: deck.color))
        }
        
    }
    
}

private struct IconCircleView: View {
    let angle: [Angle] = [Angle(degrees: 180), Angle(degrees: 300), Angle(degrees: 60)]
    let opacity: [Double] = [0.5, 0.7, 0.3]
    let iconName: String
    
    var body: some View {
        IconCircle(radius: 20, angle: 90) {
            ForEach(0..<3) { icon in
                Image(systemName: iconName)
                    .foregroundColor(Color.white)
                    .font(.title2)
                    .opacity(opacity[icon])
                    .rotationEffect(angle[icon])
            }
        }
    }
}

private struct IconCircle: Layout {
    let radius: CGFloat
    let angle: CGFloat
    
    func sizeThatFits(proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) -> CGSize {
        let maxSize = subviews.map { $0.sizeThatFits(proposal) }.reduce(CGSize.zero) {
            CGSize(width: max($0.width, $1.width), height: max($0.height, $1.height))
        }
        
        return CGSize(width: (maxSize.width / 2 + radius) * 2,
                      height: (maxSize.height / 2 + radius) * 2)
    }
    
    func placeSubviews(in bounds: CGRect, proposal: ProposedViewSize, subviews: Subviews, cache: inout ()) {
        for (index, subview) in subviews.enumerated() {
            var point = CGPoint(x: 0, y: -radius)
                .applying(CGAffineTransform(
                    rotationAngle: angle * Double(index)))
            
            point.x += bounds.midX
            point.y += bounds.midY
            
            subview.place(at: point, anchor: .center, proposal: .unspecified)
        }
    }
}

struct DeckForTodayCell_Previews: PreviewProvider {
    static var previews: some View {
        DeckForTodayCell(deck: Deck(id: UUID(), name: "Palavras em Inglês", icon: "flame", color: CollectionColor.darkPurple, datesLogs: DateLogs(), collectionId: nil, cardsIds: [], spacedRepetitionConfig: .init(), session: Session(cardIds: [UUID(), UUID()], date: Date(), deckId: UUID(), id: UUID()), category: .others, storeId: nil))
            .frame(width: 300, height: 100)
            .previewLayout(.sizeThatFits)
            .viewBackgroundColor(Color.blue)
    }
}
