//
//  Routes.swift
//  
//
//  Created by Rebecca Mello on 27/10/22.
//

import Foundation

extension Endpoint {
    static var feed: Endpoint {
        Endpoint(path: "api/decks/feed")
    }
    
    static func cardsForDeck(id: String, page: Int = 0) -> Endpoint {
        let queryItem = URLQueryItem(name: "page", value: "\(page)")
        return Endpoint(path: "api/cards/\(id)", queryItems: [queryItem])
    }
    
    static func deck(id: String) -> Endpoint {
        return Endpoint(path: "api/decks/\(id)")
    }
    
    static func sendAnDeck(_ dto: Data) -> Endpoint {
        Endpoint(path: "api/decks", method: .post, body: dto)
    }
    
    static func deleteDeck(with id: String) -> Endpoint {
        Endpoint(path: "api/decks/\(id)", method: .delete)
    }
}
