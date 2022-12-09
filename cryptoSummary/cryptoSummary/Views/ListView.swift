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
        List(viewModel.coins) { coin in
            CryptoItemCell(cryptoItem: coin)
        }.onAppear(perform: viewModel.fetchCoins)
    }
}

struct ListView_Previews: PreviewProvider {
    static var previews: some View {
        ListView()
    }
}
