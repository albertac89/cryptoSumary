//
//  CoinImageDetailView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 11/12/22.
//

import SwiftUI

struct CoinImageDetailView: View {
    let image: UIImage

    var body: some View {
        Image(uiImage: image)
            .resizable()
            .frame(width: 200, height: 200)
            .clipShape(Circle())
            .shadow(color: Color.gray, radius: 5)
            .padding(10)
    }
}

struct CoinImageDetailView_Previews: PreviewProvider {
    static var previews: some View {
        CoinImageDetailView(image: UIImage())
    }
}
