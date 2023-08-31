//
//  HTTPClientTests.swift
//  UnitTests
//
//  Created by Tal Nir on 2023-08-30.
//

import XCTest
@testable import Countries

final class HTTPClientTests: XCTestCase {
    
    private var sut: RealHTTPClient!

    typealias Mock = RequestMocking.MockedResponse

    override func setUpWithError() throws {
        sut = RealHTTPClient(session: .mockedResponsesOnly)
    }

    override func tearDownWithError() throws {
        RequestMocking.removeAllMocks()
    }

    func test_loadCountires() async throws {
        let data = Country.mockedData
        try mock(.allCountries, result: .success(data))
        let resource = Resource(url: APIs.allCountries.url, modelType: [Country].self)
        let countries = try await sut.load(resource)
        XCTAssertEqual(data, countries)
    }

    func test_loadCountires_networkingError() async throws {
        let expectedError = NetworkError.httpError(400)
        try mock(.allCountries, result: Result<[Country], Error>.failure(expectedError))
        let resource = Resource(url: APIs.allCountries.url, modelType: [Country].self)

        do {
            let _ = try await sut.load(resource)
            XCTFail("Expected an error to be thrown, but no error was thrown.")
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NetworkError {
                XCTAssertEqual(underlyingError, expectedError, "Expected error \(expectedError), but got \(underlyingError) instead.")
            } else {
                XCTFail("Expected underlying error of type \(NetworkError.self), but got \(error.userInfo[NSUnderlyingErrorKey] ?? error) instead.")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func test_loadCountryDetails() async throws {
        let country = Country.mockedData.first!
        let data = Country.Details.mockedData.first!
        try mock(.countryDetails(country), result: .success(data))
        let resource = Resource(url: APIs.countryDetails(country).url, modelType: Country.Details.self)
        let countryDetails = try await sut.load(resource)
        XCTAssertEqual(data, countryDetails)
    }
    
    func test_loadCountryDetails_networkingError() async throws {
        let expectedError = NetworkError.httpError(500)
        let country = Country.mockedData.first!
        try mock(.countryDetails(country), result: Result<Country.Details, Error>.failure(expectedError))
        let resource = Resource(url: APIs.countryDetails(country).url, modelType: [Country].self)

        do {
            let _ = try await sut.load(resource)
            XCTFail("Expected an error to be thrown, but no error was thrown.")
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NetworkError {
                XCTAssertEqual(underlyingError, expectedError, "Expected error \(expectedError), but got \(underlyingError) instead.")
            } else {
                XCTFail("Expected underlying error of type \(NetworkError.self), but got \(error.userInfo[NSUnderlyingErrorKey] ?? error) instead.")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }
    
    func test_loadData() async throws {
        let testData = UIImage(named: "us")!.pngData()!
        let url = URL(string: "https://flagcdn.com/w640/us.jpg")!
        try mock(url, result: .success(testData))
        let resource = DataResource(url: url)
        let data = try await sut.loadData(resource)
        XCTAssertEqual(data, testData)
    }
    
    func test_loadData_networkingError() async throws {
        let expectedError = NetworkError.httpError(500)
        let url = URL(string: "https://flagcdn.com/w640/us.jpg")!
        try mock(url, result: Result<Data, Error>.failure(expectedError))
        let resource = DataResource(url: url)

        do {
            let _ = try await sut.loadData(resource)
            XCTFail("Expected an error to be thrown, but no error was thrown.")
        } catch let error as NSError where error.domain == NSURLErrorDomain {
            if let underlyingError = error.userInfo[NSUnderlyingErrorKey] as? NetworkError {
                XCTAssertEqual(underlyingError, expectedError, "Expected error \(expectedError), but got \(underlyingError) instead.")
            } else {
                XCTFail("Expected underlying error of type \(NetworkError.self), but got \(error.userInfo[NSUnderlyingErrorKey] ?? error) instead.")
            }
        } catch {
            XCTFail("Unexpected error type: \(error)")
        }
    }

    // MARK: - Helper
    private func mock<T>(_ apiCall: APIs, result: Result<T, Swift.Error>,
                         httpCode: Int = 200) throws where T: Encodable {
        let mock = try Mock(apiCall: apiCall, result: result, httpCode: httpCode)
        RequestMocking.add(mock: mock)
    }
    
    private func mock(_ url: URL, result: Result<Data, Swift.Error>) throws {
        let mock = Mock(url: url, result: result)
        RequestMocking.add(mock: mock)
    }
}
