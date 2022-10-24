//
//  APIServiceProtocol.swift
//  
//
//  Created by Rebecca Mello on 24/10/22.
//

import Foundation
import Combine
import Models

protocol ExternalDeckServiceProtocol {
    func getDeckFeed() -> AnyPublisher<[DeckCategory: [ExternalDeck]], URLError>
}
