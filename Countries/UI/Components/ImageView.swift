//
//  ImageView.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

import SwiftUI
import Combine

struct ImageView: View {
    @EnvironmentObject var model: CountriesModel
    @State var uiImage: UIImage? = nil
    
    let imageURL: URL
    
    var body: some View {
        Group {
            if let uiImage = uiImage {
                Image(uiImage: uiImage)
                    .resizable()
                    .aspectRatio(contentMode: .fit)
            } else {
                ProgressView() // Show a loading spinner while image is loading
            }
        }
        .task {
            await loadImage()
        }
    }
    
    func loadImage() async {
        do {
            let data = try await model.load(url: imageURL)
            uiImage = UIImage(data: data)
        } catch {
            print("Error loading image from URL: \(error)")
            // Handle the error appropriately for your app.
        }
    }
}



#if DEBUG
struct ImageView_Previews: PreviewProvider {
    static var previews: some View {
        VStack {
            ImageView(imageURL: URL(string: "https://flagcdn.com/w640/us.jpg")!)
        }
        .environmentObject(CountriesModel.mockCountry)
    }
}
#endif
