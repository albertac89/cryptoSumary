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
    
    override class func setUp() {
        URLProtocol.registerClass(MockURLProtocol.self)
        guard let coinsListMock = MockedData.forFile(name: "coinsList"),
              let imageMock = MockedData.forFile(name: "media", fileExtension: "jpg"),
              let coinPriceMock = MockedData.forFile(name: "coinPrice"),
              let priceMultiFullMock = MockedData.forFile(name: "priceMultiFull") else { return }
        MockURLProtocol.mockData["/data/all/coinlist"] = coinsListMock
        MockURLProtocol.mockData["/media"] = imageMock
        MockURLProtocol.mockData["/data/price"] = coinPriceMock
        MockURLProtocol.mockData["/data/pricemultifull"] = priceMultiFullMock
    }
    
    private func getClient() -> URLSession {
        let configurationWithMock = URLSessionConfiguration.default
        configurationWithMock.protocolClasses = [MockURLProtocol.self]
        return URLSession(configuration: configurationWithMock)
    }
    
    func testNetworkStatusOn() {
        let viewModel = CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager(client: getClient()), networkMonitor: NetworkMonitorMock(isNetworkAvailable: true))
        XCTAssertTrue(viewModel.isNetworkAvailable())
    }
    
    func testNetworkStatusOff() {
        let viewModel = CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager(client: getClient()), networkMonitor: NetworkMonitorMock(isNetworkAvailable: false))
        XCTAssertFalse(viewModel.isNetworkAvailable())
    }
    
    func testFetchCoins() throws {
        let expectation = XCTestExpectation()
        let viewModel = CryptoSummaryListViewModel(dataManager: CryptoSummaryDataManager(client: getClient()), networkMonitor: NetworkMonitorMock(isNetworkAvailable: true))
        
        viewModel.$coinsList.dropFirst().sink { coins in
            XCTAssertTrue(coins.count == 21)
            expectation.fulfill()
        }.store(in: &cancellables)
        
        viewModel.fetchCoins()
        
        wait(for: [expectation], timeout: 5)
    }
}
