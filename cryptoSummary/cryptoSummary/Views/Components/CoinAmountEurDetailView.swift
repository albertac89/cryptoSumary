//
//  CoinAmountEurDetailView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 11/12/22.
//

import SwiftUI

struct CoinAmountEurDetailView: View {
    @ObservedObject var viewModel: CryptoSummaryDetailViewModel
    
    var body: some View {
        HStack {
            Text("I want to buy for:")
                .font(.system(size: 15, weight: .bold))
            TextField("Insert eur", text: $viewModel.eurValue)
        }
        .padding(2)
        .shadow(color: Color.gray, radius: 1)
        Text("I will have \(viewModel.coinsForAmount()) of \(viewModel.coin.name)")
            .font(.system(size: 15, weight: .bold))
            .padding(2)
            .shadow(color: Color.gray, radius: 1)
    }
}

struct CoinAmountEurDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CoinAmountEurDetailView(viewModel: CryptoSummaryDetailViewModel(coin: Coin(id: "12", image: UIImage(), name: "BTC", symbol: "BTC", value: 0.0)))
    }
}
