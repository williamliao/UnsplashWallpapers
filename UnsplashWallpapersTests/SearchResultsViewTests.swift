//
//  SearchResultsViewTests.swift
//  UnsplashWallpapersTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/11.
//

import XCTest
@testable import UnsplashWallpapers

class SearchResultsViewTests: XCTestCase {
    static let searchKey = "searchHistory"
    
    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        UserDefaults.standard.removeObject(forKey: SearchResultsViewTests.searchKey)
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }

}

extension SearchResultsViewTests {
    func testLoadDefaultTrendingHistory() throws {
        let searchResultsViewModel = SearchResultsViewModel()
        searchResultsViewModel.setupDefaultTrending()
        
        let trending = try XCTUnwrap(searchResultsViewModel.trending.value)
        
        XCTAssertTrue(trending.count == 3)
    }
    
    func testSaveSearchHistory() throws {
        
        let searchResult = SearchResults(title: "bear", category: .photos)
        
        let searchResultsViewModel = SearchResultsViewModel()
        searchResultsViewModel.searchHistory.value.insert(searchResult)
        
        searchResultsViewModel.saveSearchHistory()
        
        searchResultsViewModel.searchHistory.value.remove(searchResult)
       
        searchResultsViewModel.loadSearchHistory(key: SearchResultsViewTests.searchKey) { (_) in
            
        }
       
        XCTAssertTrue(searchResultsViewModel.searchHistory.value.count == 1)
    }
}
