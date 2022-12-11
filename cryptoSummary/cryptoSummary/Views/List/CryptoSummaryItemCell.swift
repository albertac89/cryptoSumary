//
//  CryptoSummaryItemCell.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI

struct CryptoSummaryItemCell: View {
    var cryptoItem: Coin
    
    var body: some View {
        VStack {
            HStack {
                Image(uiImage: cryptoItem.image)
                    .resizable()
                    .frame(maxWidth: 30, maxHeight: 30)
                Text(cryptoItem.name)
                    .font(.system(size: 15))
                Text(cryptoItem.symbol)
                    .font(.system(size: 10))
                Spacer()
                Text("\(cryptoItem.value)€")
                    .font(.system(size: 12))
                Image(systemName: "chevron.right")
            }
            Divider()
        }
        .tint(.black)
        .shadow(color: Color.gray, radius: 1)
        .padding(2)
    }
}

struct CryptoItemCell_Previews: PreviewProvider {
    static var previews: some View {
        CryptoSummaryItemCell(cryptoItem: Coin(id: "0", image: UIImage(), name: "Bitcoin", symbol: "BTC", value: 10))
    }
}
