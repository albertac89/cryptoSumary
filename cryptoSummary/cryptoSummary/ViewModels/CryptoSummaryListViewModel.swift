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
    @Published var coinsList = [Coin]()
    @Published var isLoading = false
    @Published var isLoadingEndScroll = false
    @Published var showError = false
    @Published var errorMessage = ""
    
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
                coinsList = coinsCoreData
                return
            }
        }
        var from = 0
        var to = 20
        isLoading = true
        if coinsList.count > 0 {
            from = to
            to += to
            isLoading = false
            isLoadingEndScroll = true
        }

        let coinsPublisher = dataManager.getCoins(from: from, to: to)
        let imagesPublisher = dataManager.imagesPublisher(coinsPublisher: coinsPublisher)
        let coinEurValuePublisher = dataManager.coinEurValuePublisher(coinsPublisher: coinsPublisher)
        let coin24HourVolume = dataManager.coin24HourVolumePublisher(coinsPublisher: coinsPublisher)
        
        Publishers.Zip4(coinsPublisher, imagesPublisher, coinEurValuePublisher, coin24HourVolume)
            .sink { completion in
                switch completion {
                case .failure(let error):
                    print(error.localizedDescription)
                    self.errorMessage = error.localizedDescription
                    self.showError = true
                    self.isLoading = false
                    self.isLoadingEndScroll = false
                case .finished:
                    print("Succeesfully finished!")
                }
                return
            } receiveValue: { coinsResponse, imagesResponse, coinValuesResponse, coin24HourVolume in
                self.dataManager.mergeCoinsData(coinsList: &self.coinsList, coinsResponse: coinsResponse, imagesResponse: imagesResponse, coinValuesResponse: coinValuesResponse, coin24HourVolume: coin24HourVolume)
                self.isLoading = false
                self.isLoadingEndScroll = false
            }
            .store(in: &subscribers)
    }
    
    func isNetworkAvailable() -> Bool {
        networkMonitor.isNetworkAvailable
    }
}
