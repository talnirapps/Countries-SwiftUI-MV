//
//  CountriesListTests.swift
//  UITests
//
//  Created by Tal Nir on 2023-08-31.
//

import XCTest

final class CountriesListTests: XCTestCase {

    let app = XCUIApplication()

    override func setUpWithError() throws {
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }
    
    func test_CountriesList_countriesNavigationBarExists() throws {
        // Given
        let app = XCUIApplication()
        let countriesNavigationBar = app.navigationBars["Countries"]
        
        // When
        
        // Then
        XCTAssertTrue(countriesNavigationBar.exists)
    }
    
    func test_CountriesList_searchFieldsExists() throws {
        // Given
        let app = XCUIApplication()
        let countriesNavigationBar = app.navigationBars["Countries"]
        let searchField = countriesNavigationBar.searchFields["Search"]
        
        // When
        
        // Then
        XCTAssertTrue(searchField.exists)
    }
    
    func test_CountriesList_searchForCanada() throws {
        // Given
        let app = XCUIApplication()
        let searchField = app.navigationBars["Countries"].searchFields["Search"]

        // When
        searchField.tap()
        searchField.typeText("Canada")
        let canadaCell = app.collectionViews.cells.staticTexts["Canada"]

        // Then
        XCTAssertTrue(canadaCell.exists, "Canada cell doesn't exist in the search results")
    }
}
