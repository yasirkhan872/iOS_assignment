//
//  NewsViewModel.swift
//  iOS_assignment
//
//  Created by Yasir Khan on 05/04/2024.
//

import Foundation

// Intput: commands sent from View to ViewModel
protocol NewsViewModelInput {
    func loadNewsFromAPI(for days : Int)
}

// Output: information which is provided from ViewModel
protocol NewsViewModelOutput {
    var loading: Observable<Bool> { get }
    var error: Observable<ErrorResponse> { get }
    
    func numberOfRows() -> Int
    func currentNewsItem(at index : Int) -> NewsResult?
    var newsDataSource: Observable<[NewsResult]?> { get }
}

protocol NewsViewModelType {
    var input: NewsViewModelInput { get }
    var output: NewsViewModelOutput { get }
}


class NewsViewModel : NewsViewModelType, NewsViewModelOutput, NewsViewModelInput {
 
    //MARK: Properties
    var input: NewsViewModelInput { self }
    var output: NewsViewModelOutput { self }
    var newsDataSource: Observable<[NewsResult]?> = Observable([])
    private let networkService : NetworkService
    var loading: Observable<Bool> = Observable(false)
    var error: Observable<ErrorResponse> = Observable(.none)
    
    //MARK: init
    init(networkService : NetworkService) {
        self.networkService = networkService
    }
    
    /// Returns total number of items in news datasource array
    func numberOfRows() -> Int {
        return newsDataSource.value?.count ?? 0
    }
    
    /// Returns current News Result Item
    func currentNewsItem(at index: Int) -> NewsResult? {
        return newsDataSource.value?[index]
    }
    
    /// Intial call to fetch data from API and also start listening to internet connection availability
    func fetchNewsData(for days : Int = 7) {
        NotificationCenter.default.addObserver(self, selector: #selector(internetConnectionRestored), name: .internetConnectionRestored, object: nil)
            
        // Initial fetch
        loadNewsFromAPI()
    }
    
    /// Restore internet connection selector method
    @objc private func internetConnectionRestored() {
         // Internet connection restored, fetch news again
        loadNewsFromAPI()
     }
    
    /// Fetch News data from API
     func loadNewsFromAPI(for days : Int = 7) {
        
        loading.value = true
         networkService.getRequest(NewsRequest(days: days)) { [weak self] result in
            guard let self = self else { return }
            self.loading.value = false
            switch result {
            case .success(let data):
                self.newsDataSource.value = data.results
                LocalStorageManager.shared.saveNewsResults(data.results)
            case .failure(let error):
                self.error.value = error.message
            }
        }
    }
    
    /// Fetch Data from local storage
    func fetchNewsFromLocalStorage() {
        if let localData =  LocalStorageManager.shared.loadNewsResults() {
            self.newsDataSource.value = localData
        } else {
            self.error.value = ErrorResponse.invalidData
        }
    }
    
}
