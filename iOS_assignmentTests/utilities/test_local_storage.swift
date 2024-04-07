//
//  test_local_storage.swift
//  iOS_assignmentTests
//
//  Created by Yasir Khan on 07/04/2024.
//

import XCTest
@testable import iOS_assignment

class test_local_storage: XCTestCase {

    func testSaveAndLoadNewsResults() {
        
        let manager = LocalStorageManager.shared
        let newsResults = [
            NewsResult.loadDummyData(),
            NewsResult.loadDummyData()
        ]
        manager.saveNewsResults(newsResults)
        let loadedNewsResults = manager.loadNewsResults()
        
        XCTAssertNotNil(loadedNewsResults)
        XCTAssertEqual(loadedNewsResults?.count, 2)
        XCTAssertEqual(loadedNewsResults?[0].title, "test")
        XCTAssertEqual(loadedNewsResults?[1].publishedDate, "test")
    }

}
