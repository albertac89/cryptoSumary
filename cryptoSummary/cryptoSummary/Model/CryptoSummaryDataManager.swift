//
//  CryptoSummaryModel.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import Combine
import UIKit

protocol CryptoSummaryDataManagerProtocol {
    func getCoins(from: Int, to: Int) -> AnyPublisher<[CoinResponse], Error>
    func imagesPublisher(coinsPublisher: AnyPublisher<[CoinResponse], Error>) -> Publishers.Map<Publishers.FlatMap<Publishers.Zip<Result<[CoinResponse], any Error>.Publisher, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinImage, any Error>>>>, AnyPublisher<[CoinResponse], any Error>>, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinImage, any Error>>>.Output>
    func coinEurValuePublisher(coinsPublisher: AnyPublisher<[CoinResponse], Error>) -> Publishers.Map<Publishers.FlatMap<Publishers.Zip<Result<[CoinResponse], any Error>.Publisher, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinValue, any Error>>>>, AnyPublisher<[CoinResponse], any Error>>, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinValue, any Error>>>.Output>
}

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
}

extension CryptoSummaryDataManager: CryptoSummaryDataManagerProtocol {
    func getCoins(from: Int, to: Int) -> AnyPublisher<[CoinResponse], Error> {
        let urlCoinList = URL(string: "https://min-api.cryptocompare.com/data/all/coinlist")!
        return URLSession.shared.dataTaskPublisher(for: urlCoinList)
            .map(\.data)
            .decode(type: CryptoDataResponse.self, decoder: JSONDecoder())
            .compactMap { $0.data.values.map { $0 } } // Map [String: CoinResponse] to CoinResponse
            .map { $0[from...to].map { $0 } }
            .share()
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func imagesPublisher(coinsPublisher: AnyPublisher<[CoinResponse], Error>) -> Publishers.Map<Publishers.FlatMap<Publishers.Zip<Result<[CoinResponse], any Error>.Publisher, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinImage, any Error>>>>, AnyPublisher<[CoinResponse], any Error>>, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinImage, any Error>>>.Output> {
        return coinsPublisher
            .flatMap { coins in
                return Publishers.Zip(Just(coins).setFailureType(to: Error.self),
                                      Publishers.MergeMany(coins.map { self.getCoinImage(for: $0) }).collect())
            }
            .map {
                return $0.1
            }
    }
    
    func coinEurValuePublisher(coinsPublisher: AnyPublisher<[CoinResponse], Error>) -> Publishers.Map<Publishers.FlatMap<Publishers.Zip<Result<[CoinResponse], any Error>.Publisher, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinValue, any Error>>>>, AnyPublisher<[CoinResponse], any Error>>, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinValue, any Error>>>.Output> {
        return coinsPublisher
            .flatMap { coins in
                return Publishers.Zip(Just(coins).setFailureType(to: Error.self),
                                      Publishers.MergeMany(coins.map { self.getCoinEurValue(for: $0) }).collect())
            }
            .map {
                return $0.1
            }
    }
}

private extension CryptoSummaryDataManager {
    func getCoinImage(for coin: CoinResponse) -> AnyPublisher<CoinImage, Error> {
        let url = URL(string: "https://www.cryptocompare.com\(coin.imageUrl ?? "")")!
        return URLSession.shared
            .dataTaskPublisher(for: url)
            .map(\.data)
            .compactMap { CoinImage(id: coin.id, image: UIImage(data: $0)) }
            .mapError { $0 as Error }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func getCoinEurValue(for coin: CoinResponse) -> AnyPublisher<CoinValue, Error> {
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
