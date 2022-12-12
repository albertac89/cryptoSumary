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

struct CoinMarketDataResponse: Codable {
    let raw: [String: [String: CoinMarketDataSymbol]]?
    
    enum CodingKeys: String, CodingKey {
        case raw = "RAW"
    }
}

struct CoinMarketDataSymbol: Codable {
    let volume24HourTo: Float?
    
    enum CodingKeys: String, CodingKey {
        case volume24HourTo = "VOLUME24HOURTO"
    }
}

struct Coin24HourlVolume {
    let id: String
    let volume24Hour: Float
}

struct Coin: Identifiable, Equatable {
    let id: String
    let image: UIImage
    let name: String
    let symbol: String
    let value: String
    let vol24: String
    
    init(id: String, image: UIImage, name: String, symbol: String, value: Float, vol24: Float) {
        self.id = id
        self.image = image
        self.name = name
        self.symbol = symbol
        self.value = value == .zero ? "No data available" : "\(value)€"
        self.vol24 = vol24 == .zero ? "No data available" : "\(vol24)€"
    }
}
