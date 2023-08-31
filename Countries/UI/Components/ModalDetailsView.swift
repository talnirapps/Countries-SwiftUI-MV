//
//  ModalDetailsView.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-30.
//

import SwiftUI

struct ModalDetailsView: View {
    
    let country: Country
    @Binding var isDisplayed: Bool
    
    var body: some View {
        NavigationView {
            ZStack {
                LinearGradient(gradient: Gradient(colors: [Color.blue, Color.black]),
                               startPoint: .topLeading,
                               endPoint: .bottomTrailing)
                .ignoresSafeArea()
                
                VStack {
                    country.flag.map { url in
                        HStack {
                            Spacer()
                            ImageView(imageURL: url)
                                .frame(width: 300, height: 200)
                                .accessibilityIdentifier("CountryFlagIdentifier")
                            Spacer()
                        }
                    }
                    closeButton.padding(.top, 40)
                }
                .navigationBarTitle(Text(country.name), displayMode: .inline)
            }
        }
        .navigationViewStyle(StackNavigationViewStyle())
    }
    
    private var closeButton: some View {
        Button(action: {
            self.isDisplayed = false
        }, label: { Text("Close") })
    }
}

#if DEBUG
struct ModalDetailsView_Previews: PreviewProvider {
    
    @State static var isDisplayed: Bool = true
    
    static var previews: some View {
        ModalDetailsView(country: Country.mockedData[0], isDisplayed: $isDisplayed)
            .environmentObject(CountriesModel.mockCountry)
    }
}
#endif
