//
//  MovieQuizUITests.swift
//  MovieQuizUITests
//
//  Created by Zhulasov Pavel on 02.05.2023.
//

import XCTest

final class MovieQuizUITests: XCTestCase {
    
    var app: XCUIApplication!

    override func setUpWithError() throws {
        try super.setUpWithError()
        app = XCUIApplication()
        app.launch()
       
        continueAfterFailure = false
    }

    override func tearDownWithError() throws {
        app.launch()
        app = nil
    }

    func testExample() throws {
       
        let app = XCUIApplication()
        app.launch()
    }

    func testLaunchPerformance() throws {
        if #available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 7.0, *) {
            measure(metrics: [XCTApplicationLaunchMetric()]) {
                app.launch()
                app.buttons["Нет"].tap()
            }
        }
    }
    
    func testYesButton() {
        sleep(3)
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        XCTAssertTrue(firstPoster.exists)
        app.buttons["Да"].tap()
        sleep(3)
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation
        XCTAssertTrue(secondPoster.exists)
        XCTAssertFalse(firstPoster == secondPoster)
        XCTAssertNotEqual(firstPosterData, secondPosterData)
    }
    func testNoButton() {
        sleep(3)
        
        let firstPoster = app.images["Poster"]
        let firstPosterData = firstPoster.screenshot().pngRepresentation
        
        app.buttons["Нет"].tap()
        sleep(3)
        
        let secondPoster = app.images["Poster"]
        let secondPosterData = secondPoster.screenshot().pngRepresentation

        let indexLabel = app.staticTexts["Index"]
       
        XCTAssertNotEqual(firstPosterData, secondPosterData)
        XCTAssertEqual(indexLabel.label, "2/10")
    }
    func testGameFinish() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["Нет"].tap()
            sleep(2)
        }

        let alert = app.alerts["Игра окончена!"]
        
        XCTAssertTrue(alert.exists)
        XCTAssertTrue(alert.label == "Игра окончена!")
        XCTAssertTrue(alert.buttons.firstMatch.label == "ОК")
    }

    func testAlertDismiss() {
        sleep(2)
        for _ in 1...10 {
            app.buttons["Нет"].tap()
            sleep(2)
        }
        
        let alert = app.alerts["Игра окончена!"]
        alert.buttons.firstMatch.tap()
        
        sleep(2)
        
        let indexLabel = app.staticTexts["Index"]
        
        XCTAssertFalse(alert.exists)
        XCTAssertTrue(indexLabel.label == "1/10")    }
}
