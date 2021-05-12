//
//  DetailViewTests.swift
//  UnsplashWallpapersTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/11.
//

import XCTest
@testable import UnsplashWallpapers

class DetailViewTests: XCTestCase {
    var info : [Response]!
    
    var viewModel: DetailViewModel!
    var detailView: DetailView!
    var photoInfo: PhotoInfo!
    
    override func setUpWithError() throws {
        
        let nav = UINavigationController()
        
        let fakeData = getFakeData()
        info = try JSONDecoder().decode([Response].self, from: fakeData)
        viewModel = DetailViewModel()
        viewModel.navItem = nav.navigationItem
        viewModel.createBarItem()
        detailView = DetailView(viewModel: viewModel, coordinator: viewModel.coordinator)
        
        let id = info[0].id
        let urls = info[0].urls
        let width = CGFloat(info[0].width)
        let height = CGFloat(info[0].height)
        
        guard let profile = info[0].user?.profile_image else {
            return
        }
        
        photoInfo = PhotoInfo(id: id, title: "Test", url: urls, profile_image: profile, width: width, height: height)
        viewModel.photoInfo.value = photoInfo
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        viewModel = nil
        detailView = nil
        info = []
        UserDefaults.standard.removeObject(forKey: SearchResultsViewTests.searchKey)
        // Put teardown code here. This method is called after the invocation of each test method in the class.
    }
}

extension DetailViewTests {
    func testImageViewHaveImage() throws {
        let expectation = XCTestExpectation()
        
        detailView.createView()
        detailView.observerBindData()
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 3.0)
        
        let image = detailView.imageView.image
        
        XCTAssertNotNil(image)
    }
    
    func testInfoButtonPress() {
        
        let expectation = XCTestExpectation()
        detailView.infoButtonTouch()
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1.0)
        
        let unsplashPhotoInfo = viewModel.photoRespone.value
        
        XCTAssertNotNil(unsplashPhotoInfo)
    }
    
    func testfavoriteButtonPress() {
        
        let expectation = XCTestExpectation()
        viewModel.favoriteAction()
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1.0)
        
        let favorites = FavoriteManager.sharedInstance.favorites.value
        
        XCTAssertNotNil(favorites)
    }
    
    func testLoadfavorite() {
        
        let expectation = XCTestExpectation()
        viewModel.loadFavorite()
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1.0)
        
        let favorites = FavoriteManager.sharedInstance.favorites.value
        
        XCTAssertNotNil(favorites)
    }
}
