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
    @Published var isLoadingEndScroll = false
    
    private var subscribers = Set<AnyCancellable>()
    private var dataManager: CryptoSummaryDataManagerProtocol
    private var networkMonitor: NetworkMonitorProtocol
    
    init(dataManager: CryptoSummaryDataManagerProtocol, networkMonitor: NetworkMonitorProtocol) {
        self.dataManager = dataManager
        self.networkMonitor = networkMonitor
    }
}

extension CryptoSummaryListViewModel: CryptoSummaryListViewModelProtocol {
    func fetchCoins() {
        if !networkMonitor.isNetworkAvailable {
            if let coinsCoreData = dataManager.loadCoinsFromCoreData() {
                coins = coinsCoreData
                return
            }
        }
        var from = 0
        var to = 20
        isLoading = true
        if coins.count > 0 {
            from = to
            to += to
            isLoading = false
            isLoadingEndScroll = true
        }

        let coinsPublisher = dataManager.getCoins(from: from, to: to)
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
                self?.mergeCoinsData(coinsResponse: coinsResponse, imagesResponse: imagesResponse, coinValuesResponse: coinValuesResponse)
                self?.isLoading = false
                self?.isLoadingEndScroll = false
            }
            .store(in: &subscribers)
    }
    
    func isNetworkAvailable() -> Bool {
        networkMonitor.isNetworkAvailable
    }
}

private extension CryptoSummaryListViewModel {
    func mergeCoinsData(coinsResponse: [CoinResponse], imagesResponse: [CoinImage], coinValuesResponse: [CoinValue]) {
        coinsResponse.enumerated().forEach { index, coinResponse in
            if !self.coins.contains(where: { $0.id == coinResponse.id }) {
                let image = imagesResponse.first(where: { $0.id == coinResponse.id })
                let coinValue = coinValuesResponse.first(where: { $0.id == coinResponse.id })
                self.coins.append(Coin(id: coinResponse.id, image: image?.image ?? UIImage(), name: coinResponse.name, symbol: coinResponse.symbol, value: coinValue?.eur ?? 0.0))
            }
        }
        dataManager.saveCoinsToCoreData(coins: self.coins)
    }
}
