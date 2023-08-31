//
//  LocaleExt.swift
//  countries
//
//  Created by Tal Nir on 2023-08-28.
//

import Foundation

extension Locale {
    static var backendDefault: Locale {
        return Locale(identifier: "en")
    }
    
    var shortIdentifier: String {
        return String(identifier.prefix(2))
    }
}
