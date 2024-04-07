//
//  test_news_viewmodel.swift
//  iOS_assignmentTests
//
//  Created by Yasir Khan on 07/04/2024.
//

import XCTest
@testable import iOS_assignment

class test_news_viewmodel: XCTestCase {
    
    var viewModel: NewsViewModel!
    var mockNetworkService: MockNetworkService!

    
    override func setUp() {
        super.setUp()
        mockNetworkService = MockNetworkService()
        viewModel = NewsViewModel(networkService: mockNetworkService)
    }
    
    override func tearDown() {
        viewModel = nil
        mockNetworkService = nil
        super.tearDown()
    }
    
    func testFetchNewsFromLocalStorage() {
        viewModel.fetchNewsFromLocalStorage()
        XCTAssertFalse(viewModel.loading.value)
        XCTAssertNotNil(viewModel.newsDataSource)

    }
    
    func testLoadNewsFromAPI(){
        viewModel.loadNewsFromAPI()
        XCTAssertNotNil(viewModel.newsDataSource)
    }
    
    func testFetchNewsDataSuccess() {
        let mockNewsResults = [NewsResult.loadDummyData()]
        mockNetworkService.mockResult = .success(NewsModel(status: "", copyright: "", numResults: 10, results: mockNewsResults))
        viewModel.loadNewsFromAPI()
        XCTAssertFalse(viewModel.loading.value)
        XCTAssertNotNil(viewModel.newsDataSource.value)
        XCTAssertEqual(viewModel.error.value, ErrorResponse.none)
    }
    
    func testFetchNewsDataFailure() {
        mockNetworkService.mockResult = .failure(.init(message: .apiError))
        viewModel.loadNewsFromAPI()
        XCTAssertFalse(viewModel.loading.value)
        XCTAssertEqual(viewModel.error.value, ErrorResponse.apiError)
    }
    
    func testLocalStorageWithData() {
        viewModel.newsDataSource.value = [NewsResult.loadDummyData()]
        viewModel.fetchNewsFromLocalStorage()
        XCTAssertNotNil(viewModel.newsDataSource)
    }
    
    func testLocalStorageWithoutData() {
        viewModel.newsDataSource.value = nil
        viewModel.fetchNewsFromLocalStorage()
    }
}

// Mock NetworkService for testing
class MockNetworkService: NetworkService {
  
    var mockResult: Result<NewsModel, NetworkError>?
    
    func getRequest<Request>(_ request: Request, completion: @escaping (Result<Request.Response, NetworkError>) -> Void) where Request : DataRequest {
        switch mockResult {
        case .success(let data):
            completion(.success(data as! Request.Response))
        case .failure(_):
            completion(.failure(.init(message: .apiError)))
        case .none:
            break
        }
      
        
    }
}
