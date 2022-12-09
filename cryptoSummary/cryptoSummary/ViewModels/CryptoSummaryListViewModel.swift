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
    
    private var subscribers = Set<AnyCancellable>()
    
    func fetchCoins() {
        CryptoSummaryDataManager.getCoins()
            .map {
                // Map [String: CoinResponse] to Coin
                $0.data.values.map{ Coin(from: $0) }
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
            .store(in: &subscribers)
    }
}

struct Coin: Identifiable {
    let id: String
    let imageUrl: String?
    let name: String
    let symbol: String
    
    init(from coin: CoinResponse) {
        self.id = coin.id
        self.imageUrl = coin.imageUrl
        self.name = coin.name
        self.symbol = coin.symbol
    }
}
