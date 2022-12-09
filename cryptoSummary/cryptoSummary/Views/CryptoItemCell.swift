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
            AsyncImage(
                url: cryptoItem.imageUrl,
                content: { image in
                    image.resizable()
                         .aspectRatio(contentMode: .fit)
                         .frame(maxWidth: 30, maxHeight: 30)
                },
                placeholder: {
                    ProgressView()
                }
            )
            Text(cryptoItem.name)
                .font(.system(size: 15))
            Text(cryptoItem.symbol)
                .font(.system(size: 10))
            Spacer()
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
