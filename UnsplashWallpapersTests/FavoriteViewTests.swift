//
//  FavoriteViewTests.swift
//  UnsplashWallpapersTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/10.
//

import XCTest
@testable import UnsplashWallpapers

class FavoriteViewTests: XCTestCase {
    var sut : UnsplashService!
    var mockSession: MockURLSession!
    let favoriteManager = FavoriteManager.sharedInstance

    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSession = nil
        UserDefaults.standard.removeObject(forKey: "favorites")
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
}

extension FavoriteViewTests {
    func testSaveFavorite() {
        let urls = Urls(raw: "https://images.unsplash.com/photo-1611908829935-19fa66e22db3", full: "https://images.unsplash.com/photo-1611908829935-19fa66e22db3", regular: "https://images.unsplash.com/photo-1611908829935-19fa66e22db3", small: "https://images.unsplash.com/photo-1611908829935-19fa66e22db3", thumb: "https://images.unsplash.com/photo-1611908829935-19fa66e22db3")
        
        let profile = Profile_image(small: "", medium: "", large: "")
        
        let photoInfo = PhotoInfo(id: "", title: "", url: urls, profile_image: profile, width: 100, height: 100)
        
        favoriteManager.favorites.value.insert(photoInfo)
        favoriteManager.saveToFavorite()
        
        let saveArray = Array(favoriteManager.favorites.value)
        XCTAssertNotNil(saveArray)
        XCTAssertTrue(saveArray.count == 1)
    }
    
    func testLoadFavorite() {
        let _ = favoriteManager.loadFavorite(key: "favorites") { (success) in
            let saveArray = Array(favoriteManager.favorites.value)
            
            XCTAssertNotNil(saveArray)
            XCTAssertTrue(saveArray.count == 1)
        }
    }
}
