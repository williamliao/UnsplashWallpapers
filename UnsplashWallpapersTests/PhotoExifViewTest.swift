//
//  PhotoExifViewTest.swift
//  UnsplashWallpapersTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/10.
//

import XCTest
@testable import UnsplashWallpapers

class PhotoExifViewTest: XCTestCase {
    var sut : UnsplashService!
    var mockSession: MockURLSession!

    override func setUpWithError() throws {
        
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSession = nil
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

extension PhotoExifViewTest {
    func testGeoNotEmpty() throws {
        let readFromFileData = loadJsonData(file: "upRandom")
 
        do {
            let jsonData = try XCTUnwrap(readFromFileData)
            let result = try JSONDecoder().decode([Response].self, from: jsonData)
            //Alexandra Tran
        
            let position =  try XCTUnwrap(result[1].location?.position)
            XCTAssertNotNil(position.latitude)
            XCTAssertNotNil(position.longitude)
            
        } catch  {
            print(error)
            XCTFail("Deocde error")
        }
    }
    
    func testFormatLocationString() throws {
        let photoExifViewModel = PhotoExifViewModel()
        let readFromFileData = loadJsonData(file: "upRandom")
 
        do {
            let jsonData = try XCTUnwrap(readFromFileData)
            let result = try JSONDecoder().decode([Response].self, from: jsonData)
           
            let locationName =  try XCTUnwrap(result[1].location?.name)
            
            let name = photoExifViewModel.formatLocationString(location: locationName)
            
            XCTAssertNotNil(name)
            
        } catch  {
            print("testFormatLocationString error \(error)")
        }
    }
    
    func testCalcDescriptionHeight() throws {
        let photoExifViewModel = PhotoExifViewModel()
        let readFromFileData = loadJsonData(file: "upRandom")
 
        do {
            let jsonData = try XCTUnwrap(readFromFileData)
            let result = try JSONDecoder().decode([Response].self, from: jsonData)
           
            let description =  try XCTUnwrap(result[0].description)
            
            let height = photoExifViewModel.calcDescriptionHeight(description: description)
            
            XCTAssertNotNil(height)
            
            XCTAssertEqual(floor(height), 42)
            
        } catch  {
            print(error)
            XCTFail("Deocde error")
        }
    }
    
    func testGenerateImageFromMap() throws {
        let photoExifViewModel = PhotoExifViewModel()
        let readFromFileData = loadJsonData(file: "upRandom")
        
        let expectation = XCTestExpectation()
 
        do {
            let jsonData = try XCTUnwrap(readFromFileData)
            let result = try JSONDecoder().decode([Response].self, from: jsonData)
           
            let id =  try XCTUnwrap(result[1].id)
            let photoInfo = self.getPhotoInfo(id: id)
            
            photoExifViewModel.photoInfo = photoInfo
            
            photoExifViewModel.generateImageFromMap { (image) in
                XCTAssertNotNil(image)
            }
            
            let wait = XCTWaiter()
            _ = wait.wait(for: [expectation], timeout: 5.0)
            
        } catch  {
            print(error)
            XCTFail("Deocde error")
        }
    }
    
    func testGenerateInfo() throws {
        let photoExifViewModel = PhotoExifViewModel()
        let readFromFileData = loadJsonData(file: "upRandom")
        
        let expectation = XCTestExpectation()
 
        do {
            let jsonData = try XCTUnwrap(readFromFileData)
            let result = try JSONDecoder().decode([Response].self, from: jsonData)
           
            let id =  try XCTUnwrap(result[1].id)
            let photoInfo = self.getPhotoInfo(id: id)
            
            photoExifViewModel.photoInfo = photoInfo
            
            photoExifViewModel.setupInfo { (dict) in
                if let location = dict["location"] as? NSMutableAttributedString {
                    XCTAssertTrue(location.length > 0)
                }
                
                if let description = dict["description"] as? String {
                    XCTAssertFalse(description.isEmpty)
                }
                
                if let descriptionHeight = dict["descriptionHeight"] as? CGFloat {
                    XCTAssertTrue(descriptionHeight > 0)
                }
                
                if let dimension = dict["dimension"] as? String {
                    XCTAssertFalse(dimension.isEmpty)
                }
                
                if let published = dict["published"] as? String {
                    XCTAssertFalse(published.isEmpty)
                }
                
                if let focal = dict["focal"] as? String {
                    XCTAssertFalse(focal.isEmpty)
                }
                
                if let make = dict["make"] as? String {
                    XCTAssertFalse(make.isEmpty)
                }
                
                if let model = dict["model"] as? String {
                    XCTAssertFalse(model.isEmpty)
                }
                
                if let iso = dict["iso"] as? String {
                    XCTAssertFalse(iso.isEmpty)
                }
                
                if let aperture = dict["aperture"] as? String {
                    XCTAssertFalse(aperture.isEmpty)
                }
            }
            
            let wait = XCTWaiter()
            _ = wait.wait(for: [expectation], timeout: 5.0)
            
        } catch  {
            print(error)
            XCTFail("Deocde error")
        }
    }
    
    func getPhotoInfo(id: String) -> UnsplashPhotoInfo? {
        
        let expectation = XCTestExpectation()
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashUserPhotosdRequest = UnsplashUserPhotoRequest(with: fetchCursor)
        var photoInfo: UnsplashPhotoInfo?
       //photoDetail
        sut = UnsplashService(endPoint: .photoDetail(id))
        sut.getPhotoInfo(pageRequest: unsplashUserPhotosdRequest) { (result) in
            
            switch result {
                case .success(let respone):
                    
                    photoInfo = respone
                    
                case .failure(_):
                    break
            }
        }
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1.0)
        
        return photoInfo
    }
}
