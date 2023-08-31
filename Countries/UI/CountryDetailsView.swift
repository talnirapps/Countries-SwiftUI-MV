//
//  CountryDetails.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

import SwiftUI

struct CountryDetails: View {
    @Environment(\.locale) var locale: Locale
    @EnvironmentObject private var navigationState: NavigationState
    @EnvironmentObject var model: CountriesModel
    
    @State var isLoadingDetails = false
    @State var userError: UserError? = nil  // New state for the error
    @State var isPresentedModalDetailsView = false
    
    let country: Country
    let details: Country.Details
    
    var body: some View {
        ZStack {
            
            LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]),
                           startPoint: .topLeading,
                           endPoint: .bottomTrailing)
            .ignoresSafeArea()
            
            List {
                country.flag.map { url in
                    flagView(url: url)
                }
                basicInfoSectionView(countryDetails: details)
                if details.currencies.count > 0 {
                    currenciesSectionView(currencies: details.currencies)
                }
                if details.neighbors.count > 0 {
                    neighborsSectionView(neighbors: details.neighbors)
                }
            }
            .listStyle(PlainListStyle()) // Add this line
            .background(LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]), startPoint: .topLeading, endPoint: .bottomTrailing)) // Add the gradient to the List itself.
            .sheet(isPresented: $isPresentedModalDetailsView,
                   content: {
                ModalDetailsView(country: country,
                                 isDisplayed: $isPresentedModalDetailsView)
            }
            )
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
        .alert(item: $userError) { error in   // Alert based on the error
            Alert(title: Text("Error"),
                  message: Text(error.message),
                  dismissButton: .default(Text("OK")))
        }
    }
    
    func flagView(url: URL) -> some View {
        HStack {
            Spacer()
            ImageView(imageURL: url)
                .frame(width: 120, height: 80)
                .onTapGesture {
                    isPresentedModalDetailsView = true
                }
            Spacer()
        }
        .listRowBackground(Color.clear) // Add this line to make the row's background transparent.
    }
    
    func basicInfoSectionView(countryDetails: Country.Details) -> some View {
        Section(header: Text("Basic Info")) {
            DetailRow(leftLabel: Text(country.alpha3Code), rightLabel: "Code")
            DetailRow(leftLabel: Text("\(country.population)"), rightLabel: "Population")
            DetailRow(leftLabel: Text("\(countryDetails.capital)"), rightLabel: "Capital")
        }
    }
    
    func currenciesSectionView(currencies: [Country.Currency]) -> some View {
        Section(header: Text("Currencies")) {
            ForEach(currencies) { currency in
                DetailRow(leftLabel: Text(currency.title), rightLabel: Text(currency.code))
            }
        }
    }
    
    func neighborsSectionView(neighbors: [Country]) -> some View {
        Section(header: Text("Neighboring countries")) {
            ForEach(neighbors) { country in
                DetailRow(leftLabel: Text(country.name(locale: self.locale)), rightLabel: "")
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
        }
    }
}

private extension Country.Currency {
    var title: String {
        return name + (symbol.map {" " + $0} ?? "")
    }
}

struct CountryDetails_Previews: PreviewProvider {
    static var previews: some View {
        CountryDetails(country: Country.mockedData[0], details: Country.Details.mockedData[0])
            .environmentObject(CountriesModel.mockCountry)
    }
}
