//
//  NavigationState.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

import Foundation

class NavigationState: ObservableObject {
    @Published var routes: [Routes] = []
}
