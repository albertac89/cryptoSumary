//
//  cryptoSummaryApp.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI

@main
struct cryptoSummaryApp: App {

    var body: some Scene {
        WindowGroup {
            CryptoSummaryListView(viewModel: CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager(), networkMonitor: NetworkMonitor()))
        }
    }
}
