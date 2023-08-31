//
//  RequestMocking.swift
//  UnitTests
//
//  Created by Tal Nir on 2023-08-30.
//

import Foundation

extension URLSession {
    static var mockedResponsesOnly: URLSession {
        let configuration = URLSessionConfiguration.default
        configuration.protocolClasses = [RequestMocking.self, RequestBlocking.self]
        configuration.timeoutIntervalForRequest = 1
        configuration.timeoutIntervalForResource = 1
        return URLSession(configuration: configuration)
    }
}

extension RequestMocking {
    static private var mocks: [MockedResponse] = []
    
    static func add(mock: MockedResponse) {
        mocks.append(mock)
    }
    
    static func removeAllMocks() {
        mocks.removeAll()
    }
    
    static private func mock(for request: URLRequest) -> MockedResponse? {
        return mocks.first { $0.url == request.url }
    }
}

// MARK: - RequestMocking

final class RequestMocking: URLProtocol {

    override class func canInit(with request: URLRequest) -> Bool {
        return mock(for: request) != nil
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }
    
    // swiftlint:disable identifier_name
    override class func requestIsCacheEquivalent(_ a: URLRequest, to b: URLRequest) -> Bool {
    // swiftlint:enable identifier_name
        return false
    }
    
    override func startLoading() {
        if let mock = RequestMocking.mock(for: request),
           let url = request.url,
           let response = mock.customResponse ??
               HTTPURLResponse(url: url,
                               statusCode: mock.httpCode,
                               httpVersion: "HTTP/1.1",
                               headerFields: mock.headers) {

            Task {
                try await Task.sleep(nanoseconds: UInt64(mock.loadingTime * 1_000_000_000)) // convert to nanoseconds
                await MainActor.run {
                    self.client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
                }
                switch mock.result {
                case let .success(data):
                    await MainActor.run {
                        self.client?.urlProtocol(self, didLoad: data)
                        self.client?.urlProtocolDidFinishLoading(self)
                    }
                case let .failure(error):
                    let failure = NSError(domain: NSURLErrorDomain, code: 1,
                                          userInfo: [NSUnderlyingErrorKey: error])
                    await MainActor.run {
                        self.client?.urlProtocol(self, didFailWithError: failure)
                    }
                }
            }
        }
    }



    override func stopLoading() { }
}

// MARK: - RequestBlocking

private class RequestBlocking: URLProtocol {
    enum Error: Swift.Error {
        case requestBlocked
    }
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }

    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        Task {
            await Task.yield() // This is to ensure the function runs asynchronously
            await MainActor.run {
                self.client?.urlProtocol(self, didFailWithError: Error.requestBlocked)
            }
        }
    }

    override func stopLoading() { }
}
