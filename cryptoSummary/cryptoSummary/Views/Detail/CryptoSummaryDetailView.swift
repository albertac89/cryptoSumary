//
//  CryptoSummaryDetailView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 11/12/22.
//

import SwiftUI

struct CryptoSummaryDetailView: View {
    @ObservedObject var viewModel: CryptoSummaryDetailViewModel
    
    init(viewModel: CryptoSummaryDetailViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            HStack(alignment: .center) {
                Image(uiImage: viewModel.coin.image)
                    .resizable()
                    .frame(width: 200, height: 200)
                    .clipShape(Circle())
                    .shadow(color: Color.gray, radius: 5)
                    .padding(10)
            }
            VStack(alignment: .leading) {
                HStack {
                    Text("Symbol: ")
                        .font(.system(size: 15, weight: .bold))
                    Text(viewModel.coin.symbol)
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(2)
                .shadow(color: Color.gray, radius: 1)
                HStack {
                    Text("Value: ")
                        .font(.system(size: 15, weight: .bold))
                    Text("\(viewModel.coin.value)")
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(2)
                .shadow(color: Color.gray, radius: 1)
                HStack {
                    Text("Volume over 24h: ")
                        .font(.system(size: 15, weight: .bold))
                    Text("654632.154€")
                        .font(.system(size: 12, weight: .medium))
                }
                .padding(2)
                .shadow(color: Color.gray, radius: 1)
                HStack {
                    Text("I Want to Buy for:")
                        .font(.system(size: 15, weight: .bold))
                    TextField("Insert eur", text: $viewModel.eurValue)
                }
                .padding(2)
                .shadow(color: Color.gray, radius: 1)
                Text("I will have \(viewModel.coinsForAmount()) Of \(viewModel.coin.name)")
                    .font(.system(size: 15, weight: .bold))
                    .padding(2)
                    .shadow(color: Color.gray, radius: 1)
                
            }
            Spacer()
        }
        .padding()
        .navigationTitle(viewModel.coin.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoSummaryDetailView(viewModel: CryptoSummaryDetailViewModel(coin:  Coin(id: "0", image: UIImage(), name: "BTC", symbol: "BTC", value: 0.00)))
    }
}
