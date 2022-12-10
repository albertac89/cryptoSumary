//
//  CryptoSummaryModel.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import Combine
import UIKit

class CryptoSummaryDataManager {
    enum CryptoSummaryError: Error, CustomStringConvertible {
        case network
        case parsing
        case fetching
        
        var description: String {
            switch self {
            case .network:
                return "Network error"
            case .parsing:
                return "Parsing error"
            case .fetching:
                return "File fetching error"
            }
        }
    }

    static func getCoins() -> AnyPublisher<[CoinResponse], Error> {
        let urlCoinList = URL(string: "https://min-api.cryptocompare.com/data/all/coinlist")!
        return URLSession.shared.dataTaskPublisher(for: urlCoinList)
            .map(\.data)
            .decode(type: CryptoDataResponse.self, decoder: JSONDecoder())
            .compactMap { $0.data.values.map { $0 } } // Map [String: CoinResponse] to CoinResponse
            .share()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    static func getCoinImage(for coin: CoinResponse) -> AnyPublisher<CoinImage, Error> {
        let url = URL(string: "https://www.cryptocompare.com\(coin.imageUrl ?? "")")!
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { CoinImage(id: coin.id, image: UIImage(data: $0)) }
            .mapError { $0 as Error }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }

    static func getCoinEurValue(for coin: CoinResponse) -> AnyPublisher<CoinValue, Error> {
        let urlCoinList = URL(string: "https://min-api.cryptocompare.com/data/price?fsym=\(coin.symbol)&tsyms=EUR")!
        return URLSession.shared.dataTaskPublisher(for: urlCoinList)
            .map(\.data)
            .decode(type: CoinValueResponse.self, decoder: JSONDecoder())
            .compactMap { CoinValue(id: coin.id, eur: $0.eur ?? 0.0)}
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
}

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
