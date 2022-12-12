//
//  CryptoSummaryDetailViewModel.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 11/12/22.
//

import Foundation

protocol CryptoSummaryDetailViewModelProtocol {
    func coinsForAmount() -> Float
}

class CryptoSummaryDetailViewModel: ObservableObject {
    @Published var eurValue = ""
    private(set) var coin: Coin
    
    init(coin: Coin) {
        self.coin = coin
    }
}

extension CryptoSummaryDetailViewModel: CryptoSummaryDetailViewModelProtocol {
    func coinsForAmount() -> Float {
        return (eurValue as NSString).floatValue * (coin.value as NSString).floatValue
    }
}
