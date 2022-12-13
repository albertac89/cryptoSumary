//
//  NetworkMonitorMock.swift
//  cryptoSummaryTests
//
//  Created by Albert Aige Cortasa on 13/12/22.
//

@testable import cryptoSummary

class NetworkMonitorMock: NetworkMonitorProtocol {
    var isNetworkAvailable: Bool = false
    
    init(isNetworkAvailable: Bool) {
        self.isNetworkAvailable = isNetworkAvailable
    }
}
