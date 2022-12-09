//
//  ItemCell.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI

struct CryptoItemCell: View {
    var cryptoItem: Coin
    
    var body: some View {
        HStack {
            Image(systemName: "square.and.arrow.up.circle")
            Text(cryptoItem.name)
            Text(cryptoItem.symbol)
            Text("0.00 €")
        }
    }
}

struct CryptoItemCell_Previews: PreviewProvider {
    static var previews: some View {
        CryptoItemCell(cryptoItem: Coin(from: CoinResponse(id: "0", imageUrl: nil, name: "Bitcoin", symbol: "BTC")))
    }
}

//name, logo, symbol and value (€(EUR) conversion)
