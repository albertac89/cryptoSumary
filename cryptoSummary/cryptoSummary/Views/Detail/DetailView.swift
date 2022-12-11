//
//  DetailView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 11/12/22.
//

import SwiftUI

struct DetailView: View {
    let coin: Coin
    var body: some View {
        VStack {
            Image(uiImage: coin.image)
                .resizable()
                .frame(width: 200, height: 200)
                .clipShape(Circle())
                .shadow(color: Color.gray, radius: 5)
                .padding(10)
            HStack {
                Text("Symbol: ")
                    .font(.system(size: 15, weight: .bold))
                Text(coin.symbol)
                    .font(.system(size: 12, weight: .medium))
            }
            .padding(2)
            .shadow(color: Color.gray, radius: 1)
            HStack {
                Text("Value: ")
                    .font(.system(size: 15, weight: .bold))
                Text("\(coin.value)")
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
            Spacer()
        }
        .navigationTitle(coin.name)
    }
}

struct DetailView_Previews: PreviewProvider {
    static var previews: some View {
        DetailView(coin: Coin(id: "0", image: UIImage(), name: "BTC", symbol: "BTC", value: 0.00))
    }
}
