//
//  UnsplashApiTests.swift
//  UnsplashWallpapersTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/12.
//

import XCTest
@testable import UnsplashWallpapers

class UnsplashApiTests: XCTestCase {
    var sut : UnsplashService!
    var mockSession: MockURLSession!
    var decoder: JSONDecoder!
    
    override func setUpWithError() throws {
        
        decoder = JSONDecoder()
    }
        
    override func tearDownWithError() throws {
        sut = nil
        mockSession = nil
        decoder = nil
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
    
    func testExample() throws {
        // This is an example of a functional test case.
        // Use XCTAssert and related functions to verify your tests produce the correct results.
    }
    
    func testPerformanceExample() throws {
        // This is an example of a performance test case.
        self.measure {
            // Put the code you want to measure the time of here.
        }
    }
    
    func test_Nature_API_Testing() {
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashSearchPagedRequest(with: fetchCursor)
        
        baseApiTest(endPoint: .search("nature", unsplashPagedRequest)) { [weak self] (data, response, error) in
            
            guard let data = data else {
                return
            }
            
            do {
                let genericModel = try self?.decoder.decode(SearchRespone.self, from: data)
                
                XCTAssertNotNil(genericModel)
                
            } catch  {
                XCTFail("Something worong for SearchRespone Model")
            }
        }
    }
    
    func test_UserProfile_API_Testing() {
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashUserListRequest(with: fetchCursor)
        
        baseApiTest(endPoint: .user_photo("schimiggy", "photos", unsplashPagedRequest)) { [weak self] (data, response, error) in
            
            guard let data = data else {
                return
            }
            
            do {
                let genericModel = try self?.decoder.decode([CollectionResponse].self, from: data)
                
                XCTAssertNotNil(genericModel)
                
            } catch  {
                XCTFail("Something worong for CollectionResponse Model")
            }
        }
    }
    
    func test_UserProfile_Like_API_Testing() {
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashUserListRequest(with: fetchCursor)
        
        baseApiTest(endPoint: .user_photo("schimiggy", "likes", unsplashPagedRequest)) { [weak self] (data, response, error) in
            
            guard let data = data else {
                return
            }
            
            do {
                let genericModel = try self?.decoder.decode([CollectionResponse].self, from: data)
                
                XCTAssertNotNil(genericModel)
                
            } catch  {
                XCTFail("Something worong for CollectionResponse Model")
            }
        }
    }
    
    func test_UserProfile_Collections_API_Testing() {
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashUserListRequest(with: fetchCursor)
        
        baseApiTest(endPoint: .user_photo("schimiggy", "collections", unsplashPagedRequest)) { [weak self] (data, response, error) in
            
            guard let data = data else {
                return
            }
            
            do {
                let genericModel = try self?.decoder.decode([CollectionResponse].self, from: data)
                
                XCTAssertNotNil(genericModel)
                
            } catch  {
                XCTFail("Something worong for CollectionResponse Model")
            }
        }
    }
    
    func test_Get_Collections_API_Testing() {
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashCollectionRequest(with: fetchCursor)
        
        baseApiTest(endPoint: .get_collection("pcpIADjp3Xg", unsplashPagedRequest)) { (data, response, error) in
            
            guard let data = data else {
                return
            }
            
            XCTAssertNotNil(data)
        }
    }
    
    func test_Featured_API_Testing() {
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashSearchPagedRequest(with: fetchCursor)
        
        baseApiTest(endPoint: .collections("nature", unsplashPagedRequest)) { [weak self] (data, response, error) in
            
            guard let data = data else {
                return
            }
            
            do {
                let genericModel = try self?.decoder.decode(SearchRespone.self, from: data)
                
                guard let respone = genericModel else {
                    return
                }
                
                for index in 0...respone.results.count - 1 {
                    
                    var albumDetailItems:[AlbumDetailItem] = [AlbumDetailItem]()
                    
                    guard let cover_photo = respone.results[index].cover_photo , let url = URL(string: cover_photo.urls.small), let title = respone.results[index].user?.name, let profile = respone.results[index].user?.profile_image, let owner = respone.results[index].user?.profile_image.small  else {
                        return
                    }
                    
                    
                    guard let preview_photos = respone.results[index].preview_photos  else {
                        return
                    }
                    
                    for index in 0...preview_photos.count - 1 {
                        
                        guard let detailItemUrl = URL(string: preview_photos[index].urls.small)  else {
                            return
                        }
                        
                        let albumDetailItem = AlbumDetailItem(identifier: preview_photos[index].id , title: title, photoURL: detailItemUrl, thumbnailURL: detailItemUrl, profile_image: profile, urls: preview_photos[index].urls)
                        
                        if !albumDetailItems.contains(albumDetailItem) {
                            albumDetailItems.append(albumDetailItem)
                        }
                        
                    }
                    
                    var isLandscape = false
                    if cover_photo.width > cover_photo.height {
                        isLandscape = true
                    }
                    
                    guard let ownerURL = URL(string: owner) else {
                        return
                    }
                    
                    let albumItem = AlbumItem(albumTitle: "Nature", albumURL: url, ownerTitle: title, ownerURL: ownerURL, isLandscape: isLandscape, imageItems: albumDetailItems)
                    
                    XCTAssertNotNil(albumItem)
                }
                
            } catch  {
                XCTFail("Something worong for SearchRespone Model")
            }
        }
    }
}
