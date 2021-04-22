//
//  UnsplashService.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

class UnsplashService: NetworkManager {
    
    var networkManager: NetworkManager!
}

extension UnsplashService {
    
    func fetchDataWithNetworkManager(pageRequest: UnsplashPagedRequest, completion: @escaping (APIResult<[UnsplashPhoto], ServerError>) -> Void) {
        
        networkManager.fetch(method: .get, decode: { json -> [UnsplashPhoto]? in
            guard let feedResult = json as? [UnsplashPhoto] else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func search(keyword: String, pageRequest: UnsplashSearchPagedRequest, completion: @escaping (APIResult<SearchRespone, ServerError>) -> Void) {
        
        networkManager.query(query: keyword, pageRequest: pageRequest, method: .get, decode: { json -> SearchRespone? in
            guard let feedResult = json as? SearchRespone else { return  nil }
            return feedResult
        }, completion: completion)
    }
}

extension UnsplashService {
    
    func createSearchEndpoint(query: String, page: NSInteger, perPage: NSInteger = 10) {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
          components.path = "/search/photos"
        
        print("prepareURLComponents \(page)")
        
        components.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "per_page", value: String(perPage)),
            URLQueryItem(name: "page", value: String(page)),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)
        ]
    }
    
    func createCollectionEndpoint(identifier: String) {
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
          components.path = "/search/photos"
        
        components.queryItems = [
            URLQueryItem(name: "identifier", value: identifier),
            URLQueryItem(name: "per_page", value: "20"),
            URLQueryItem(name: "page", value: "1"),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)
        ]
    }
}
