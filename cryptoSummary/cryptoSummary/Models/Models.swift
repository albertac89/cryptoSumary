//
//  Models.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 12/12/22.
//

import SwiftUI

struct CryptoDataResponse: Codable {
    let data: [String: CoinResponse]
    
    enum CodingKeys: String, CodingKey {
        case data = "Data"
    }
}

struct CoinResponse: Codable {
    let id: String
    let imageUrl: String?
    let name: String
    let symbol: String
    
    enum CodingKeys: String, CodingKey {
        case id = "Id"
        case imageUrl = "ImageUrl"
        case name = "CoinName"
        case symbol = "Symbol"
    }
}

struct CoinImage {
    let id: String
    let image: UIImage?
}

struct CoinValue {
    let id: String
    let eur: Float
}

struct CoinValueResponse: Codable {
    let eur: Float?
    
    enum CodingKeys: String, CodingKey {
        case eur = "EUR"
    }
}

struct Coin: Identifiable, Equatable {
    let id: String
    let image: UIImage
    let name: String
    let symbol: String
    let value: Float
}
