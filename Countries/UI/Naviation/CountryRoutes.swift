//
//  CountryRoutes.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

import SwiftUI

extension Routes {    
    enum CountryRoutes: Hashable {
        case detail(Country, Country.Details)
    }
}

struct CountryRouter {
    
    let routes: Routes.CountryRoutes
    
    @ViewBuilder
    func configure() -> some View {
        switch routes {
        case let .detail(country, details):
            CountryDetails(country: country, details: details)
        }
    }
}
