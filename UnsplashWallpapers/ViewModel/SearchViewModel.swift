//
//  SearchViewModel.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/4/26.
//

import Foundation

class SearchViewModel {
    var searchRespone: Observable<SearchRespone?> = Observable(nil)
    var error: Observable<Error?> = Observable(nil)
    var isLoading: Observable<Bool> = Observable(false)
    
    var isSearching: Observable<Bool> = Observable(false)
    var service: UnsplashService = UnsplashService()
    
    var searchCursor: Cursor!
    var collectionsCursor: Cursor!
    var usersCursor: Cursor!
    
    var unsplashSearchPagedRequest: UnsplashSearchPagedRequest!
    var unsplashSearchUserPagedRequest: UnsplashSearchPagedRequest!
    
    var coordinator: MainCoordinator?
    private(set) var isFetching = false
    private var canFetchMore = true
    
    var query = ""
    var category: SearchResults.Category!
}

extension SearchViewModel {
   
    func search(keyword: String, category: SearchResults.Category) {
        
        isSearching.value = true
        query = keyword
        //self.searchHistory.value.append(keyword)
        isLoading.value = true
        self.category = category
        
        switch category {
            case .photos:
                
                if searchCursor == nil {
                    searchCursor = Cursor(query: keyword, page: 1, perPage: 10, parameters: [:])
                    unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: searchCursor)
                }
                
                service = UnsplashService(endPoint: .search(keyword, unsplashSearchPagedRequest))
                
                break
            case .collections:
                
                if collectionsCursor == nil {
                    collectionsCursor = Cursor(query: keyword, page: 1, perPage: 10, parameters: [:])
                    unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: collectionsCursor)
                }

                service = UnsplashService(endPoint: .collections(keyword, unsplashSearchPagedRequest))
                
                break
            case .users:
                
                if usersCursor == nil {
                    usersCursor = Cursor(query: keyword, page: 1, perPage: 10, parameters: [:])
                    unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: usersCursor)
                }

                service = UnsplashService(endPoint: .users(keyword, unsplashSearchPagedRequest))

                break
        
        }
        
        service.search(pageRequest: unsplashSearchPagedRequest) { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
        
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self.error.value = error
                    }
            }
        }
    }
    
    func fetchNextPage() {
        if isLoading.value {
            return
        }
        
        if canFetchMore == false {
            return
        }
        
        switch category {
            case .photos:
                unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: searchCursor)
                break
            case .collections:
                unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: collectionsCursor)
                break
            case .users:
                unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: usersCursor)
                break
            case .none:
                break
        }
        
        
        isLoading.value = true
        
        service.search(pageRequest: unsplashSearchPagedRequest) { [weak self] (result) in
            self?.isLoading.value = false
            
            switch result {
                case .success(let respone):
                   
                    guard var new = self?.searchRespone.value  else {
                        return
                    }
                    
                    if new.results.count == respone.results.count {
                       self?.canFetchMore = false
                        return
                    }
                    
                    new.total = respone.total
                    new.total_pages = respone.total_pages
                    for index in 0...respone.results.count - 1 {
                        if !new.results.contains(respone.results[index]) {
                            new.results.append(respone.results[index])
                        }
                    }
                    
                    self?.searchRespone.value = new
                    
                    guard let cursor = self?.searchCursor else {
                        return
                    }
                    
                    if new.results.count < cursor.perPage {
                        self?.canFetchMore = false
                    } else {
                        self?.searchCursor = self?.unsplashSearchPagedRequest.nextCursor()
                    }
                    
                case .failure(let error):
                    
                    switch error {
                        case .statusCodeError(let code):
                            print(code)
                        default:
                            self?.error.value = error
                    }
            }
        }
    }
    
    func reset() {
        isSearching.value = false
        //query = ""
        isLoading.value = false
        canFetchMore = false
        searchCursor = nil
        collectionsCursor = nil
        usersCursor = nil
        searchRespone.value = nil
    }
    
    func didCloseSearchFunction() {
        isSearching.value = false
        query = ""
        isLoading.value = false
        canFetchMore = false
        searchCursor = nil
        collectionsCursor = nil
        usersCursor = nil
    }
}
