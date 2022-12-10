//
//  CryptoSummaryListViewModel.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI
import Combine

class CryptoSummaryListViewModel: ObservableObject {
    @Published var coins = [Coin]()
    @Published var isLoading = false
    
    private var subscribers = Set<AnyCancellable>()
    
    func fetchCoins() {
        isLoading = true
        /*CryptoSummaryDataManager.getCoins()
            .map {
                // Map [String: CoinResponse] to Coin
                $0.data.values.map { Coin(from: $0) }
            }
            .receive(on: RunLoop.main)
            .sink { response in
                switch response {
                case .failure(let error):
                    print("Failed with error: \(error)")
                    return
                case .finished:
                    print("Succeesfully finished!")
                }
            } receiveValue: { coins in
                self.coins = coins
            }
            .store(in: &subscribers)*/
        
        let coinsPublisher = CryptoSummaryDataManager.getCoins()
        
        let imagesPublisher = coinsPublisher
            .flatMap { coins in
                Publishers.Zip(Just(coins).setFailureType(to: Error.self),
                               Publishers.MergeMany(coins.map { CryptoSummaryDataManager.getCoinImage(for: $0) }).collect())
            }
            .map {
                return $0.1
            }
        
        let coinEurValuePublisher = coinsPublisher
            .flatMap { coins in
                Publishers.Zip(Just(coins).setFailureType(to: Error.self),
                               Publishers.MergeMany(coins.map { CryptoSummaryDataManager.getCoinEurValue(for: $0) }).collect())
            }
            .map {
                return $0.1
            }
        
        
        Publishers.Zip(coinsPublisher, imagesPublisher) //coinEurValuePublisher
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed with error: \(error)")
                    return
                case .finished:
                    print("Succeesfully finished!")
                }
            } receiveValue: { [weak self] coinsResponse, imagesResponse in //coinValuesResponse
                coinsResponse.forEach { [weak self] coinResponse in
                    let image = imagesResponse.first(where: { $0.id == coinResponse.id })
                    //let coinValue = coinValuesResponse.first(where: { $0.id == coinResponse.id })
                    self?.coins.append(Coin(id: coinResponse.id, image: image?.image ?? UIImage(), name: coinResponse.name, symbol: coinResponse.symbol, value: 0.0))//coinValue?.eur ??
                }
                self?.isLoading = false
            }
            .store(in: &subscribers)
    }
}

struct Coin: Identifiable {
    let id: String
    let image: UIImage
    let name: String
    let symbol: String
    let value: Float
}
