//
//  CountriesModel.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

import Foundation
import SwiftUI

protocol ModelProtocol: ObservableObject {
    @MainActor var countries: [Country] { get set }
    
    func loadCountries() async throws
    @MainActor func loadCountryDetails(country: Country) async throws -> Country.Details?
    @MainActor func load(url: URL) async throws -> Data
}

@MainActor
class CountriesModel: ModelProtocol {
    
    @Published var countries: [Country] = []
    private var httpClient: HTTPClient // TOTO: Use Repository
    
    init(httpClient: HTTPClient) {
        self.httpClient = httpClient
    }
    
    func loadCountries() async throws {
        let resource = Resource(url: APIs.allCountries.url, modelType: [Country].self)
        countries = try await httpClient.load(resource)
    }
    
    
    func loadCountryDetails(country: Country) async throws -> Country.Details? {
        let resource = Resource(url: APIs.countryDetails(country).url, modelType: [Country.Details.Intermediate].self)
        let array: [Country.Details.Intermediate] =  try await httpClient.load(resource)
        let detailsIntermediat: Country.Details.Intermediate? = array.first
        
        guard let detailsIntermediat = detailsIntermediat else {
            return nil
        }
        let neighbors = countries.filter { detailsIntermediat.borders.contains($0.alpha3Code) }
        let details: Country.Details? = Country.Details(capital: detailsIntermediat.capital, currencies: detailsIntermediat.currencies, neighbors: neighbors)
        
        return details
    }
    
    func load(url: URL) async throws -> Data {
        let resource = DataResource(url: url)
        return try await httpClient.loadData(resource)
    }
}
