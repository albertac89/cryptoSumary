//
//  ListView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI

struct ListView: View {
    @ObservedObject var viewModel = CryptoSummaryListViewModel()
    
    var body: some View {
        if viewModel.isLoading {
            ProgressView()
                .scaleEffect(1.0, anchor: .center)
                .progressViewStyle(CircularProgressViewStyle(tint: .red))
        } else {
            ScrollView {
                LazyVStack {
                    ForEach(viewModel.coins) { coin in
                        CryptoItemCell(cryptoItem: coin)
                    }
                }.onAppear(perform: viewModel.fetchCoins)
            }.padding()
            /*List(viewModel.coins) { coin in
                CryptoItemCell(cryptoItem: coin)
            }.onAppear(perform: viewModel.fetchCoins)*/
        }
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
