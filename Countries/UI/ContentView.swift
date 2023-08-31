//
//  ContentView.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

import SwiftUI

struct ContentView: View {
    @StateObject private var navigationState = NavigationState()
    
    var body: some View {
        NavigationStack(path: $navigationState.routes) {
            CountriesList()
                .navigationDestination(for: Routes.self) { route in
                    switch route {
                    case .country(let routes):
                        CountryRouter(routes: routes).configure()
                    }
                }
        }.environmentObject(navigationState)
        .tint(.white)
    }
}

struct ContentView_Previews: PreviewProvider {
    static var previews: some View {
        ContentView()
            .environmentObject(CountriesModel.mockCountry)
        
    }
}
