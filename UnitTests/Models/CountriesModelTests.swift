//
//  CountriesModelTests.swift
//  UnitTests
//
//  Created by Tal Nir on 2023-08-31.
//

import XCTest
@testable import Countries

final class CountriesModelTests: XCTestCase {
    
    private var sut: CountriesModel!
    
    let url = APIs.allCountries.url
    let mockedAllCountries = try! JSONEncoder().encode(Country.mockedData)
    
    let url2 = APIs.countryDetails(Country.mockedData.first!).url
    let mockedCountryDetails = try! JSONEncoder().encode( [Country.Details.Intermediate(capital: "test", currencies: [], borders: [])])

    let url3 = URL(string: "https://flagcdn.com/w640/us.jpg")!
    let mockedData = UIImage(named: "us")?.pngData()
    
    @MainActor override func setUpWithError() throws {
        let mockClient = MockHTTPClient(mockedResponses: [url: mockedAllCountries, url2: mockedCountryDetails, url3: mockedData!])
        sut = CountriesModel(httpClient: mockClient)
    }
    
    override func tearDownWithError() throws {
    }
    
    
    
    @MainActor
    func test_loadCountires() async throws {
        try await sut.loadCountries()
        XCTAssertEqual(Country.mockedData, sut.countries)
    }
    
    func test_loadCountryDetails() async throws {
        let countryDetails: Country.Details = try await sut.loadCountryDetails(country: Country.mockedData.first!)!
        XCTAssertEqual(Country.Details(capital: "test", currencies: [], neighbors: []), countryDetails)
    }
    
    func test_loadData() async throws {
        let data = try await sut.load(url: url3)
        XCTAssertEqual(mockedData, data)
    }
}
