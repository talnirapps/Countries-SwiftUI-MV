//
//  CountriesApp.swift
//  countries
//
//  Created by Tal Nir on 2023-08-28.
//

import SwiftUI

@main
struct CountriesApp: App {
    
    var body: some Scene {
        WindowGroup {
            ContentView()
                .environmentObject(CountriesModel(httpClient: RealHTTPClient()))
        }
    }
}
