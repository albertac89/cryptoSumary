//
//  cryptoSummaryApp.swift
//  cryptoSummary
//
//  Created by Albert Aige Cortasa on 9/12/22.
//

import SwiftUI

@main
struct cryptoSummaryApp: App {
    let persistenceController = PersistenceController.shared

    var body: some Scene {
        WindowGroup {
            CryptoSummaryListView(viewModel: CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager()))
        }
    }
}
