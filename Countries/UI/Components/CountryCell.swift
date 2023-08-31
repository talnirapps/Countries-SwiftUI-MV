//
//  CountryCell.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

import SwiftUI

struct CountryCell: View {
    
    let country: Country
    @Environment(\.locale) var locale: Locale
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(country.name(locale: locale))
                .font(.title)
            Text("Population \(country.population)")
                .font(.caption)
        }
        .padding()
        .frame(maxWidth: .infinity, maxHeight: 60, alignment: .leading)
        .background(Color.clear) // This ensures the entire cell occupies the space and is tappable.
        .contentShape(Rectangle()) // This makes the entire VStack tappable, not just where there's content.
        .listRowBackground(Color.clear) // Add this line to make the row's background transparent.
        
    }
}

#if DEBUG
struct CountryCell_Previews: PreviewProvider {
    static var previews: some View {
        CountryCell(country: Country.mockedData[0])
            .previewLayout(.fixed(width: 375, height: 60))
    }
}
#endif
