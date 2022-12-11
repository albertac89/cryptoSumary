//
//  LoaderView.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 11/12/22.
//

import SwiftUI

struct LoaderView: View {
    let scale: CGFloat

    var body: some View {
        ProgressView()
            .scaleEffect(scale, anchor: .center)
            .progressViewStyle(CircularProgressViewStyle(tint: .blue))
    }
}

struct LoaderView_Previews: PreviewProvider {
    static var previews: some View {
        LoaderView(scale: 4)
    }
}
