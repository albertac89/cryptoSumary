//
//  CryptoSummaryModel.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import Combine
import UIKit
import CoreData

protocol CryptoSummaryDataManagerProtocol {
    func getCoins(from: Int, to: Int) -> AnyPublisher<[CoinResponse], Error>
    func imagesPublisher(coinsPublisher: AnyPublisher<[CoinResponse], Error>) -> Publishers.Map<Publishers.FlatMap<Publishers.Zip<Result<[CoinResponse], any Error>.Publisher, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinImage, any Error>>>>, AnyPublisher<[CoinResponse], any Error>>, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinImage, any Error>>>.Output>
    func coinEurValuePublisher(coinsPublisher: AnyPublisher<[CoinResponse], Error>) -> Publishers.Map<Publishers.FlatMap<Publishers.Zip<Result<[CoinResponse], any Error>.Publisher, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinValue, any Error>>>>, AnyPublisher<[CoinResponse], any Error>>, Publishers.Collect<Publishers.MergeMany<AnyPublisher<CoinValue, any Error>>>.Output>
    func coin24HourVolumePublisher(coinsPublisher: AnyPublisher<[CoinResponse], Error>) -> Publishers.Map<Publishers.FlatMap<Publishers.Zip<Result<[CoinResponse], any Error>.Publisher, Publishers.Collect<Publishers.MergeMany<AnyPublisher<Coin24HourlVolume, any Error>>>>, AnyPublisher<[CoinResponse], any Error>>, Publishers.Collect<Publishers.MergeMany<AnyPublisher<Coin24HourlVolume, any Error>>>.Output>
    func mergeCoinsData(coinsList: inout [Coin], coinsResponse: [CoinResponse], imagesResponse: [CoinImage], coinValuesResponse: [CoinValue], coin24HourVolume: [Coin24HourlVolume])
    func loadCoinsFromCoreData() -> [Coin]?
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
    
    private lazy var persistentContainer: NSPersistentContainer = {
        let container = NSPersistentContainer(name: "cryptoSummary")
        container.loadPersistentStores(completionHandler: { (storeDescription, error) in
            if let error = error as NSError? {
                fatalError("Unresolved error \(error), \(error.userInfo)")
            }
        })
        return container
    }()
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

    func coin24HourVolumePublisher(coinsPublisher: AnyPublisher<[CoinResponse], Error>) -> Publishers.Map<Publishers.FlatMap<Publishers.Zip<Result<[CoinResponse], any Error>.Publisher, Publishers.Collect<Publishers.MergeMany<AnyPublisher<Coin24HourlVolume, any Error>>>>, AnyPublisher<[CoinResponse], any Error>>, Publishers.Collect<Publishers.MergeMany<AnyPublisher<Coin24HourlVolume, any Error>>>.Output> {
        return coinsPublisher
            .flatMap { coins in
                return Publishers.Zip(Just(coins).setFailureType(to: Error.self),
                                      Publishers.MergeMany(coins.map { self.getCoin24HourVolume(for: $0) }).collect())
            }
            .map {
                return $0.1
            }
    }
    
    func mergeCoinsData(coinsList: inout [Coin], coinsResponse: [CoinResponse], imagesResponse: [CoinImage], coinValuesResponse: [CoinValue], coin24HourVolume: [Coin24HourlVolume]) {
        for coinResponse in coinsResponse where !coinsList.contains(where: { $0.id == coinResponse.id })  {
            let image = imagesResponse.first(where: { $0.id == coinResponse.id })
            let coinValue = coinValuesResponse.first(where: { $0.id == coinResponse.id })
            let coinVol = coin24HourVolume.first(where: { $0.id == coinResponse.id })
            coinsList.append(Coin(id: coinResponse.id,
                                   image: image?.image ?? UIImage(),
                                   name: coinResponse.name,
                                   symbol: coinResponse.symbol,
                                   value: coinValue?.eur ?? 0.0,
                                   vol24: coinVol?.volume24Hour ?? 0.0))
        }
        saveCoinsToCoreData(coins: coinsList)
    }
    
    func loadCoinsFromCoreData() -> [Coin]? {
        var coins: [NSManagedObject] = []
        let fetchRequest = NSFetchRequest<NSManagedObject>(entityName: "Coins")
        
        do {
            coins = try persistentContainer.viewContext.fetch(fetchRequest)
            return coins.map {
                let id = $0.value(forKey: "id") as? String ?? ""
                let image = UIImage(data: $0.value(forKey: "image") as? Data ?? Data()) ?? UIImage()
                let name = $0.value(forKey: "name") as? String ?? ""
                let symbol = $0.value(forKey: "symbol") as? String ?? ""
                let value = $0.value(forKey: "value") as? Float ?? 0
                let vol24 = $0.value(forKey: "vol24") as? Float ?? 0
                return Coin(id: id, image: image, name: name, symbol: symbol, value: value, vol24: vol24)
            }
        } catch let error as NSError {
            print("Could not fetch. \(error), \(error.userInfo)")
            return nil
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
    
    func getCoin24HourVolume(for coin: CoinResponse, fiatCoinVol: String = "EUR") -> AnyPublisher<Coin24HourlVolume, Error> {
        let urlCoinVol = URL(string: "https://min-api.cryptocompare.com/data/pricemultifull?fsyms=\(coin.symbol)&tsyms=\(fiatCoinVol)")!
        return URLSession.shared.dataTaskPublisher(for: urlCoinVol)
            .map(\.data)
            .decode(type: CoinMarketDataResponse.self, decoder: JSONDecoder())
            .compactMap {
                let dict = $0.raw?.values.map { $0 }
                guard let value = dict?.first?[fiatCoinVol]?.volume24HourTo else {
                    return Coin24HourlVolume(id: coin.id, volume24Hour: 0.0)
                }
                return Coin24HourlVolume(id: coin.id, volume24Hour: value)
            }
            .receive(on: RunLoop.main)
            .eraseToAnyPublisher()
    }
    
    func saveCoinsToCoreData(coins: [Coin]) {
        clearCoreDataCoinsEntity()
        coins.forEach { coin in
            if let entity = NSEntityDescription.entity(forEntityName: "Coins", in: persistentContainer.viewContext) {
                let coinData = NSManagedObject(entity: entity, insertInto: persistentContainer.viewContext)
                coinData.setValue(coin.id, forKeyPath: "id")
                coinData.setValue(coin.name, forKeyPath: "name")
                coinData.setValue(coin.symbol, forKeyPath: "symbol")
                coinData.setValue(coin.image.pngData(), forKeyPath: "image")
                coinData.setValue((coin.value as NSString).floatValue, forKeyPath: "value")
                coinData.setValue((coin.vol24 as NSString).floatValue, forKeyPath: "vol24")
            }
        }
        
        do {
            try persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("Could not save. \(error), \(error.userInfo)")
        }
    }
    
    func clearCoreDataCoinsEntity() {
        let deleteFetch = NSFetchRequest<NSFetchRequestResult>(entityName: "Coins")
        let deleteRequest = NSBatchDeleteRequest(fetchRequest: deleteFetch)
        
        do {
            try persistentContainer.viewContext.execute(deleteRequest)
            try persistentContainer.viewContext.save()
        } catch let error as NSError {
            print("There was an error deleting data. \(error), \(error.userInfo)")
        }
    }
}
