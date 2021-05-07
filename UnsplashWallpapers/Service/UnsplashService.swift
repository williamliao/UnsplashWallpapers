//
//  UnsplashService.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import Foundation

class UnsplashService: NetworkManager {
    
    //var networkManager: NetworkManager!
}

extension UnsplashService {
    
    func fetchDataWithNetworkManager(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        self.fetch(method: .get, decode: { json -> [Response]? in
            guard let feedResult = json as? [Response] else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func search(pageRequest: UnsplashSearchPagedRequest, completion: @escaping (APIResult<SearchRespone, ServerError>) -> Void) {
        
        self.query(pageRequest: pageRequest, method: .get, decode: { json -> SearchRespone? in
            guard let feedResult = json as? SearchRespone else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func topic(id: String, pageRequest: UnsplashTopicRequest, completion: @escaping (APIResult<Topic, ServerError>) -> Void) {
        
        self.topic(id: id, pageRequest: pageRequest, method: .get, decode: { json -> Topic? in
            guard let feedResult = json as? Topic else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func topicPhotos(id: String, pageRequest: UnsplashTopicRequest, completion: @escaping (APIResult<Topic, ServerError>) -> Void) {
        
        self.topic(id: id, pageRequest: pageRequest, method: .get, decode: { json -> Topic? in
            guard let feedResult = json as? Topic else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func listUserPhotos(pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        self.listUserData(pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
            guard let feedResult = json as? [CollectionResponse] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func listUserLikePhotos(username: String, pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        self.listUserData(pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
            guard let feedResult = json as? [CollectionResponse] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func listUserCollections(username: String, pageRequest: UnsplashUserListRequest, completion: @escaping (APIResult<[UserCollectionRespone], ServerError>) -> Void) {
        
        self.listUserData(pageRequest: pageRequest, method: .get, decode: { json -> [UserCollectionRespone]? in
            guard let feedResult = json as? [UserCollectionRespone] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func collection(pageRequest: UnsplashCollectionRequest, completion: @escaping (APIResult<[CollectionResponse], ServerError>) -> Void) {
        
        self.get_Collection(pageRequest: pageRequest, method: .get, decode: { json -> [CollectionResponse]? in
            guard let feedResult = json as? [CollectionResponse] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func getPhotoInfo(id: String, pageRequest: UnsplashUserPhotoRequest, completion: @escaping (APIResult<UnsplashPhotoInfo, ServerError>) -> Void) {
        
        self.getPhotoInfo(id: id, pageRequest: pageRequest, method: .get, decode: { json -> UnsplashPhotoInfo? in
            guard let feedResult = json as? UnsplashPhotoInfo else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func getAllAlbum(pageRequest: UnsplashAlbumsRequest, completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        self.getAlbum(pageRequest: pageRequest, method: .get, decode: { json -> [Response]? in
            guard let feedResult = json as? [Response] else { return  nil }
            return feedResult
        }, completion: completion)

    }
    
    func fetchRandomWithQuery(query: String, pageRequest: UnsplashPagedRequest, completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        self.queryWithRandom(query: query, pageRequest: pageRequest, method: .get, decode: { json -> [Response]? in
            guard let feedResult = json as? [Response] else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    func mock(completion: @escaping (APIResult<Data, Error>) -> Void) {
        self.mock(method: .get, completion: completion)
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
