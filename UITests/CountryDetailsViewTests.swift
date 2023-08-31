//
//  CountryDetailsViewTests.swift
//  UITests
//
//  Created by Tal Nir on 2023-08-31.
//

import XCTest

final class CountryDetailsViewTests: XCTestCase {
    
    let app = XCUIApplication()

    override func setUpWithError() throws {
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }

    func test_CountryDetailsView_basicInfoExists() throws {
        // Given
        let app = XCUIApplication()
        let searchField = app.navigationBars["Countries"].searchFields["Search"]

        // When
        searchField.tap()
        searchField.typeText("Canada")
        let canadaCell = app.collectionViews.cells.staticTexts["Canada"]
        canadaCell.tap()

        let collectionViewsQuery = app.collectionViews
        let basicInfo = collectionViewsQuery.staticTexts["Basic Info"]
        let basicInfoCode = collectionViewsQuery.staticTexts["CAN"]
        let basicInfoPopulation = collectionViewsQuery.staticTexts["38,005,238"]
        let basicInfoCapital = collectionViewsQuery.staticTexts["Ottawa"]

        // Then
        XCTAssertTrue(basicInfo.exists, "Canada basic info doesn't exist")
        XCTAssertTrue(basicInfoCode.exists, "Canada basic info code doesn't exist")
        XCTAssertTrue(basicInfoPopulation.exists, "Canada basic info population doesn't exist")
        XCTAssertTrue(basicInfoCapital.exists, "Canada basic info capital doesn't exist")
    }

}
