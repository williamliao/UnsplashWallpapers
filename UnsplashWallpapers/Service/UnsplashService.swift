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
    
    func fetchDataWithNetworkManager(pageRequest: UnsplashPagedRequest, completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        networkManager.fetch(method: .get, decode: { json -> [Response]? in
            guard let feedResult = json as? [Response] else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func search(keyword: String, pageRequest: UnsplashSearchPagedRequest, completion: @escaping (APIResult<SearchRespone, ServerError>) -> Void) {
        
        networkManager.query(query: keyword, pageRequest: pageRequest, method: .get, decode: { json -> SearchRespone? in
            guard let feedResult = json as? SearchRespone else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func topic(keyword: String, pageRequest: UnsplashTopicRequest, completion: @escaping (APIResult<[Topic], ServerError>) -> Void) {
        
        networkManager.topic(query: keyword, pageRequest: pageRequest, method: .get, decode: { json -> [Topic]? in
            guard let feedResult = json as? [Topic] else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func ListUserPhotos(username: String, pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        networkManager.listUserPhotos(username: username, pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
            guard let feedResult = json as? [CollectionResponse] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func collection(id: String, pageRequest: UnsplashCollectionRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        networkManager.get_Collection(id: id, pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
            guard let feedResult = json as? [CollectionResponse] else { return  nil }
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
        
        //print("prepareURLComponents \(page)")
        
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
