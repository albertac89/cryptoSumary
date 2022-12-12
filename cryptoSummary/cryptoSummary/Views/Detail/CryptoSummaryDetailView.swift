//
//  CryptoSummaryDetailView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 11/12/22.
//

import SwiftUI

struct CryptoSummaryDetailView: View {
    let viewModel: CryptoSummaryDetailViewModel
    
    init(viewModel: CryptoSummaryDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            VStack(alignment: .center) {
                CoinImageDetailView(image: viewModel.coin.image)
                CoinTextDetailView(text: "Symbol: ", value: viewModel.coin.symbol)
                CoinTextDetailView(text: "Value: ", value: viewModel.coin.value)
                CoinTextDetailView(text: "Volume over 24h: ", value: viewModel.coin.vol24)
            }
            Divider().padding(EdgeInsets(top: 20, leading: 0, bottom: 20, trailing: 0))
            VStack(alignment: .leading) {
                CoinAmountEurDetailView(viewModel: viewModel)
            }
            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.coin.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoSummaryDetailView(viewModel: CryptoSummaryDetailViewModel(coin:  Coin(id: "0", image: UIImage(), name: "BTC", symbol: "BTC", value: 0.0, vol24: 0.0)))
    }
}
