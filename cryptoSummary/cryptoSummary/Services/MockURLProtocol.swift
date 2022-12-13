//
//  CryptoSummaryDataManagerMock.swift
//  cryptoSummaryTests
//
//  Created by Albert Aige Cortasa on 13/12/22.
//

import Foundation

class MockURLProtocol: URLProtocol {
    static var mockData = [String: Data]()
    
    override class func canInit(with task: URLSessionTask) -> Bool {
        return true
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    override func startLoading() {
        if let url = request.url {
            let path: String
            if url.relativePath.contains("media") {
                path = "/media"
            } else {
                path = url.relativePath
            }
            if let data = MockURLProtocol.mockData[path] {
                client?.urlProtocol(self, didLoad: data)
                client?.urlProtocol(self, didReceive: HTTPURLResponse(), cacheStoragePolicy: .allowed)
            } else {
                client?.urlProtocol(self, didFailWithError: APIError.invalidResponse)
            }
        }
        client?.urlProtocolDidFinishLoading(self)
    }
    
    override func stopLoading() {}
}

class MockedData {
    static func forFile(name: String, fileExtension: String = "json") -> Data? {
        if let url = Bundle.main.url(forResource: name, withExtension: fileExtension) {
            do {
                let data = try Data(contentsOf: url)
                return data
            } catch {
                print("Mocking data error:\(error)")
            }
        }
        return nil
    }
}
