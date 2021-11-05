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
    
    @available(iOS 15.0.0, *)
    func fetchWithConcurrency(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        Task {
            let result = try? await fetchDataWithConcurrency(method: .get, decode: { json -> [Response]? in
                guard let feedResult = json as? [Response] else { return  nil }
                return feedResult
            })

            if let returnResult = result {
                completion(returnResult)
            }
        }
    }
    
    func fetchDataWithNetworkManager(completion: @escaping (APIResult<[Response], ServerError>) -> Void) {
        
        self.fetch(method: .get, decode: { json -> [Response]? in
            guard let feedResult = json as? [Response] else { return  nil }
            return feedResult
        }, completion: completion)
    }
    
    @available(iOS 15.0.0, *)
    func searchWithConcurrency(pageRequest: UnsplashSearchPagedRequest, completion: @escaping (APIResult<SearchRespone, ServerError>) -> Void) {
        
        Task {
            let result = try? await queryWithConcurrency(pageRequest: pageRequest, method: .get, decode: { json -> SearchRespone? in
                guard let feedResult = json as? SearchRespone else { return  nil }
                return feedResult
            })

            if let returnResult = result {
                completion(returnResult)
            }
        }
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
    
    func getPhotoInfo(pageRequest: UnsplashUserPhotoRequest, completion: @escaping (APIResult<UnsplashPhotoInfo, ServerError>) -> Void) {
        
        self.getPhotoInfo(pageRequest: pageRequest, method: .get, decode: { json -> UnsplashPhotoInfo? in
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
