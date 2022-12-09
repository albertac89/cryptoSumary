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

    //var cancellable = Set<AnyCancellable>()
    //let urlCoinList = URL(string: "https://min-api.cryptocompare.com/data/all/coinlist")!
    //let urlCoinValue = URL(string: "https://min-api.cryptocompare.com/data/price?fsym=\(coin)&tsyms=EUR")!
    //https://www.cryptocompare.com/media/37747382/csc-2.png

    static func getCoins() -> AnyPublisher<CryptoDataResponse, Error> {
        let urlCoinList = URL(string: "https://min-api.cryptocompare.com/data/all/coinlist")!
        return URLSession.shared.dataTaskPublisher(for: urlCoinList)
            .map(\.data)
            .decode(type: CryptoDataResponse.self, decoder: JSONDecoder())
            .eraseToAnyPublisher()
    }
    //let url = URL(string: "https://www.cryptocompare.com\(imageUrl ?? "")")!
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

struct CoinValueResponse: Codable {
    let eur: Float
    
    enum CodingKeys: String, CodingKey {
        case eur = "EUR"
    }
}
