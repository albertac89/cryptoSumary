//
//  ListView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel = CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager())
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                LoaderView(scale: 4)
            } else {
                NavigationView {
                    List(viewModel.coins) { coin in
                        NavigationLink(destination: DetailView(coin: coin)) {
                            CryptoItemCell(cryptoItem: coin)
                        }
                    }
                    .navigationTitle("Cryptos list")
                }
            }
        }.onAppear(perform: viewModel.fetchCoins)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
