//
//  CryptoSummaryListView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI

struct CryptoSummaryListView: View {
    @ObservedObject var viewModel: CryptoSummaryListViewModel
    
    init(viewModel: CryptoSummaryListViewModel) {
        self.viewModel = viewModel
    }
    
    var body: some View {
        VStack {
            if viewModel.isLoading {
                LoaderView(scale: 4)
            } else {
                NavigationView {
                    ScrollView {
                        LazyVStack {
                            ForEach(viewModel.coinsList) { coin in
                                NavigationLink(destination: CryptoSummaryDetailView(viewModel: CryptoSummaryDetailViewModel(coin: coin))) {
                                    CryptoSummaryItemCell(cryptoItem: coin)
                                        .onAppear() {
                                            if viewModel.coinsList.last == coin {
                                                if !viewModel.isLoadingEndScroll && viewModel.isNetworkAvailable() {
                                                    viewModel.fetchCoins()
                                                }
                                            }
                                        }
                                }
                            }
                        }
                        .padding()
                    }
                    .navigationTitle("Cryptos list")
                }
                if viewModel.isLoadingEndScroll {
                    LoaderView(scale: 1)
                }
            }
        }.onAppear(perform: viewModel.fetchCoins)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        CryptoSummaryListView(viewModel: CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager(), networkMonitor: NetworkMonitor()))
    }
}
