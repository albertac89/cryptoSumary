//
//  CryptoSummaryListViewModel.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI
import Combine

protocol CryptoSummaryListViewModelProtocol {
    func fetchCoins()
}

class CryptoSummaryListViewModel: ObservableObject {
    @Published var coins = [Coin]()
    @Published var isLoading = false
    
    private var subscribers = Set<AnyCancellable>()
    private var dataManager: CryptoSummaryDataManagerProtocol
    
    init(dataManager: CryptoSummaryDataManagerProtocol) {
        self.dataManager = dataManager
    }
}

extension CryptoSummaryListViewModel: CryptoSummaryListViewModelProtocol {
    func fetchCoins() {
        isLoading = true

        let coinsPublisher = dataManager.getCoins(from: 0, to: 20)//depenen del scroll es poden obtenir mes monedes, mirant la cuantitat que hi ha a coins i sumant 20 mes
        let imagesPublisher = dataManager.imagesPublisher(coinsPublisher: coinsPublisher)
        let coinEurValuePublisher = dataManager.coinEurValuePublisher(coinsPublisher: coinsPublisher)
        
        Publishers.Zip3(coinsPublisher, imagesPublisher, coinEurValuePublisher)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print("Failed with error: \(error)")
                    return
                case .finished:
                    print("Succeesfully finished!")
                }
            } receiveValue: { [weak self] coinsResponse, imagesResponse, coinValuesResponse in
                coinsResponse.enumerated().forEach { [weak self] index, coinResponse in
                    // todo move to a func
                    let image = imagesResponse.first(where: { $0.id == coinResponse.id })
                    let coinValue = coinValuesResponse.first(where: { $0.id == coinResponse.id })
                    self?.coins.append(Coin(id: coinResponse.id, image: image?.image ?? UIImage(), name: coinResponse.name, symbol: coinResponse.symbol, value: coinValue?.eur ?? 0.0))
                    if coinsResponse.count - 1 == index {
                        self?.isLoading = false
                    }
                }
            }
            .store(in: &subscribers)
    }
}

private extension CryptoSummaryListViewModel {
    
}

struct Coin: Identifiable {
    let id: String
    let image: UIImage
    let name: String
    let symbol: String
    let value: Float
}
