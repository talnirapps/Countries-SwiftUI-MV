//
//  APIs.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

import Combine
import Foundation

fileprivate let version = "v2"

enum APIs {
    
    case allCountries
    case countryDetails(Country)
    
    private var baseURL: URL {
        URL(string: "https://restcountries.com")!
    }
    
    var url: URL {
        switch self {
        case .allCountries:
            return baseURL.appendingPathComponent("\(version)/all")
        case let .countryDetails(country):
            return baseURL.appendingPathComponent("\(version)/name/\(country.name)")
        }
    }
}
