//
//  SearchResultsViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/27.
//

import Foundation

class SearchResultsViewModel {
    var trending: Observable<[SearchResults]?> = Observable([])
    var searchHistory: Observable<Set<SearchResults>> = Observable(Set<SearchResults>())
}

extension SearchResultsViewModel {
    func setupDefaultTrending() {
        let trending = [SearchResults(title: "Cat", category: .photos), SearchResults(title: "Dog", category: .photos), SearchResults(title: "Food", category: .photos)]
        self.trending.value = trending
    }
    
    func saveSearchHistory() {
        do {
            try UserDefaults.standard.setObject(self.searchHistory.value, forKey: "searchHistory")
            UserDefaults.standard.synchronize()
        } catch  {
            print("saveSearchHistory error \(error)")
        }
    }
    
    func loadSearchHistory(key: String, completionHandler: CompletionHandler) {
        let userDefaults = UserDefaults.standard
        if UserDefaults.standard.object(forKey: key) != nil {
            do {
                self.searchHistory.value = try userDefaults.getObject(forKey: key, castTo: Set<SearchResults>.self)
                completionHandler(true)
            } catch  {
                print("loadSearchHistory error \(error)")
                completionHandler(false)
            }
        }
    }
}
