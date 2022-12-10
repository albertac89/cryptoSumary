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
        isLoading = false

        let coinsPublisher = CryptoSummaryDataManager.getCoins(from: 0, to: 20)
        
        let imagesPublisher = coinsPublisher
            .flatMap { coins in
                return Publishers.Zip(Just(coins).setFailureType(to: Error.self),
                               Publishers.MergeMany(coins.map { CryptoSummaryDataManager.getCoinImage(for: $0) }).collect())
            }
            .map {
                return $0.1
            }
        
        let coinEurValuePublisher = coinsPublisher
            .flatMap { coins in
                return Publishers.Zip(Just(coins).setFailureType(to: Error.self),
                               Publishers.MergeMany(coins.map { CryptoSummaryDataManager.getCoinEurValue(for: $0) }).collect())
            }
            .map {
                return $0.1
            }
        
        
        Publishers.Zip3(coinsPublisher, imagesPublisher, coinEurValuePublisher) //coinEurValuePublisher
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed with error: \(error)")
                    return
                case .finished:
                    print("Succeesfully finished!")
                }
            } receiveValue: { [weak self] coinsResponse, imagesResponse, coinValuesResponse in //coinValuesResponse
                coinsResponse.forEach { [weak self] coinResponse in
                    let image = imagesResponse.first(where: { $0.id == coinResponse.id })
                    let coinValue = coinValuesResponse.first(where: { $0.id == coinResponse.id })
                    self?.coins.append(Coin(id: coinResponse.id, image: image?.image ?? UIImage(), name: coinResponse.name, symbol: coinResponse.symbol, value: coinValue?.eur ?? 0.0))//coinValue?.eur ??
                }
                self?.isLoading = false
                print("Loaded")
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
