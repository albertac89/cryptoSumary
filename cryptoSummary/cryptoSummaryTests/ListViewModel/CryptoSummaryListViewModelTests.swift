//
//  CryptoSummaryListViewModelTests.swift
//  cryptoSummaryTests
//
//  Created by Albert Aige Cortasa on 13/12/22.
//

import XCTest
import Combine
@testable import cryptoSummary

class CryptoSummaryListViewModelTests: XCTestCase {
    private var cancellables: Set<AnyCancellable> = []
    
    func testNetworkStatusOn() {
        let viewModel = CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager(), networkMonitor: NetworkMonitorMock(isNetworkAvailable: true))
        XCTAssertTrue(viewModel.isNetworkAvailable())
    }
    
    func testNetworkStatusOff() {
        let viewModel = CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager(), networkMonitor: NetworkMonitorMock(isNetworkAvailable: false))
        XCTAssertFalse(viewModel.isNetworkAvailable())
    }
    
    func testFetchCoins() throws {
        let expectation = XCTestExpectation()
        let viewModel = CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager(), networkMonitor: NetworkMonitorMock(isNetworkAvailable: true))
        
        viewModel.$coinsList.dropFirst().sink { coins in
            XCTAssertTrue(coins.count == 21)
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.fetchCoins()
        
        wait(for: [expectation], timeout: 5)
    }
}
