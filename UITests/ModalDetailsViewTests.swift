//
//  ModalDetailsViewTests.swift
//  UITests
//
//  Created by Tal Nir on 2023-08-31.
//

import XCTest

final class ModalDetailsViewTests: XCTestCase {

    let app = XCUIApplication()
    
    override func setUpWithError() throws {
        app.launch()
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
    }


    func test_ModalDetailsView_DisplaysCorrectly() throws {
        // Given
        let app = XCUIApplication()
        let searchField = app.navigationBars["Countries"].searchFields["Search"]

        // When
        searchField.tap()
        searchField.typeText("Canada")
        let canadaCell = app.collectionViews.cells.staticTexts["Canada"]
        canadaCell.tap()
        app.collectionViews.cells.firstMatch.tap()
        app.images["CountryFlagIdentifier"].tap()

        // Then
        XCTAssertTrue(app.buttons["Close"].exists)
        XCTAssertTrue(app.navigationBars.staticTexts["Canada"].exists)
    }
}
