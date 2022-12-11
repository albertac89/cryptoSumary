//
//  CoinTextDetailView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 11/12/22.
//

import SwiftUI

struct CoinTextDetailView: View {
    let text: String
    let value: String
    
    var body: some View {
        HStack {
            Text(text)
                .font(.system(size: 15, weight: .bold))
            Text(value)
                .font(.system(size: 12, weight: .medium))
        }
        .padding(2)
        .shadow(color: Color.gray, radius: 1)
    }
}

struct CoinTextDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CoinTextDetailView(text: "Test: ", value: "10")
    }
}
