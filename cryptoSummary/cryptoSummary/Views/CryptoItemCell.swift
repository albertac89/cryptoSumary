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
            Image(uiImage: cryptoItem.image)
                .resizable()
                .frame(maxWidth: 30, maxHeight: 30)
            Text(cryptoItem.name)
                .font(.system(size: 15))
            Text(cryptoItem.symbol)
                .font(.system(size: 10))
            Spacer()
            Text("\(cryptoItem.value) €")
        }
    }
}

struct CryptoItemCell_Previews: PreviewProvider {
    static var previews: some View {
        CryptoItemCell(cryptoItem: Coin(id: "0", image: UIImage(), name: "Bitcoin", symbol: "BTC", value: 10))
    }
}

//name, logo, symbol and value (€(EUR) conversion)
