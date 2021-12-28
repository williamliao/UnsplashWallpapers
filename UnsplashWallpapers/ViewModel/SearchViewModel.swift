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
    
    @available(iOS 13.0.0, *)
    func searchWithConcurrency(keyword: String, category: SearchResults.Category) {
        
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
        
        service.searchWithConcurrency() { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
                    
                    self.searchCursor = self.unsplashSearchPagedRequest.nextCursor()
        
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
        
        service.search() { (result) in
            self.isLoading.value = false
            switch result {
                case .success(let respone):
                   
                    self.searchRespone.value = respone
                    
                    self.searchCursor = self.unsplashSearchPagedRequest.nextCursor()
        
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
    
    @available(iOS 13.0.0, *)
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
                service = UnsplashService(endPoint: .search(searchCursor.query ?? "", unsplashSearchPagedRequest))
                break
            case .collections:
                unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: collectionsCursor)
                service = UnsplashService(endPoint: .search(collectionsCursor.query ?? "", unsplashSearchPagedRequest))
                break
            case .users:
                unsplashSearchPagedRequest = UnsplashSearchPagedRequest(with: usersCursor)
            
                service = UnsplashService(endPoint: .users(usersCursor.query ?? "", unsplashSearchPagedRequest))
                
                break
            case .none:
                break
        }
        
        
        isLoading.value = true
        
        service.searchWithConcurrency() { [weak self] (result) in
            self?.isLoading.value = false
            
            switch result {
                case .success(let respone):
                   
                    guard var new = self?.searchRespone.value  else {
                        return
                    }
              
                    new.total = respone.total
                    new.total_pages = respone.total_pages
                    if (respone.results.count > 0) {
                        for index in 0...respone.results.count - 1 {
                            if !new.results.contains(respone.results[index]) {
                                new.results.append(respone.results[index])
                            }
                        }
                    } else {
                        self?.canFetchMore = false
                    }
                    
                    self?.searchRespone.value = new
                    
                    guard let cursor = self?.searchCursor else {
                        return
                    }
                    
                    if new.results.count < cursor.perPage {
                        self?.canFetchMore = false
                    } else {
                        
                        switch self?.category {
                            case .photos:
                                self?.searchCursor = self?.unsplashSearchPagedRequest.nextCursor()
                            case .collections:
                                self?.collectionsCursor = self?.unsplashSearchPagedRequest.nextCursor()
                                break
                            case .users:
                                self?.usersCursor = self?.unsplashSearchPagedRequest.nextCursor()
                            case .none:
                                break
                        }
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
        canFetchMore = true
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
    
    func cancelWhenViewDidDisappear() {
        service.cancelTask()
    }
}
