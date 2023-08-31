//
//  CountriesList.swift
//  countries
//
//  Created by Tal Nir on 2023-08-28.
//

import SwiftUI

struct UserError: Identifiable {
    let id = UUID()
    let message: String
}

struct CountriesList: View {
    
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject var model: CountriesModel
    
    @State var isLoadingDetails = false
    @State var userError: UserError? = nil  // New state for the error
    @State private var searchText = ""
    
    private var sortedCountries: [Country] {
        model.countries.sorted {
            $0.name < $1.name
        }
        .filter {
            searchText.isEmpty ? true : $0.name.contains(searchText)
        }
    }
    
    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            List(sortedCountries) { country in
                CountryCell(country: country)
                    .onTapGesture {
                        Task {
                            do {
                                isLoadingDetails = true
                                if let details =  try await model.loadCountryDetails(country: country) {
                                    navigationState.routes.append(.country(.detail(country, details)))
                                }
                                isLoadingDetails = false
                            } catch {
                                isLoadingDetails = false
                                userError = UserError(message: error.localizedDescription)  // Set the error when an error occurs
                            }
                        }
                        
                    }
            }
            .listStyle(PlainListStyle()) // Add this line
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Add the gradient to the List itself.
            .blur(radius: isLoadingDetails ? 10 : 0)
            .allowsTightening(isLoadingDetails == false)
            
            
            
            if isLoadingDetails {
                ProgressView()
                    .progressViewStyle(CircularProgressViewStyle(tint: .blue))
                    .scaleEffect(2) // Optional: Increase the size of the progress view
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                    .edgesIgnoringSafeArea(.all)
            }
        }
        
        .task {
            do {
                try await model.loadCountries()
            } catch {
                print(error.localizedDescription)
            }
        }
        .navigationTitle("Countries")
        .alert(item: $userError) { error in   // Alert based on the error
            Alert(title: Text("Error"),
                  message: Text(error.message),
                  dismissButton: .default(Text("OK")))
        }
        .searchable(text: $searchText)
    }
}

struct CountriesList_Previews: PreviewProvider {
    static var previews: some View {
        CountriesList()
            .environmentObject(CountriesModel.mockCountry) // use the mock version here.
    }
}
