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
    
    func topic(id: String, pageRequest: UnsplashTopicRequest, completion: @escaping (APIResult<Topic, ServerError>) -> Void) {
        
        networkManager.topic(id: id, pageRequest: pageRequest, method: .get, decode: { json -> Topic? in
            guard let feedResult = json as? Topic else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func topicPhotos(id: String, pageRequest: UnsplashTopicRequest, completion: @escaping (APIResult<Topic, ServerError>) -> Void) {
        
        networkManager.topic(id: id, pageRequest: pageRequest, method: .get, decode: { json -> Topic? in
            guard let feedResult = json as? Topic else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func listUserPhotos(username: String, pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        networkManager.listUserData(username: username, endPoint:"photos", pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
            guard let feedResult = json as? [CollectionResponse] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func listUserLikePhotos(username: String, pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        networkManager.listUserData(username: username, endPoint:"likes", pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
            guard let feedResult = json as? [CollectionResponse] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func listUserCollections(username: String, pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[UserCollectionRespone], ServerError>) -> Void) {
        
        networkManager.listUserData(username: username, endPoint:"collections" , pageRequest: pageRequest, method: .get, decode: { json -> [UserCollectionRespone]? in
            guard let feedResult = json as? [UserCollectionRespone] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func collection(id: String, pageRequest: UnsplashCollectionRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        networkManager.get_Collection(id: id, pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
            guard let feedResult = json as? [CollectionResponse] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func getPhotoInfo(id: String, pageRequest: UnsplashUserPhotoRequest, completion: @escaping (APIResult<UnsplashPhotoInfo, ServerError>) -> Void) {
        
        networkManager.getPhotoInfo(id: id, pageRequest: pageRequest, method: .get, decode: { json -> UnsplashPhotoInfo? in
            guard let feedResult = json as? UnsplashPhotoInfo else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func getAllAlbum(query: String, pageRequest: UnsplashAlbumsRequest, completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        networkManager.getAlbum(query: query, pageRequest: pageRequest, method: .get, decode: { json -> [Response]? in
            guard let feedResult = json as? [Response] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func fetchRandomWithQuery(query: String, pageRequest: UnsplashPagedRequest, completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        networkManager.queryWithRandom(query: query, pageRequest: pageRequest, method: .get, decode: { json -> [Response]? in
            guard let feedResult = json as? [Response] else { return  nil }
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
