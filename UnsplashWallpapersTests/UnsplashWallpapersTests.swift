//
//  UnsplashWallpapersTests.swift
//  UnsplashWallpapersTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/18.
//

import XCTest
@testable import UnsplashWallpapers

class UnsplashWallpapersTests: XCTestCase {
    
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

extension UnsplashWallpapersTests {
    func testNetworkClient_successResult() {
        
        let exception = XCTestExpectation()
        sut = UnsplashService(endPoint: .random)
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 30, parameters: [:])
        let unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        
        sut.fetchDataWithNetworkManager(pageRequest: unsplashPagedRequest) { (result) in

            switch result {
                case .success(let respone):
                   
                    XCTAssertNotNil(respone)
                    XCTAssertTrue(respone.count == 30)
                    
                case .failure(let error):
                    XCTAssertNotNil(error)
            }
        }
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 1)
    }
    
    func testAlbumViewSuccessfulResponse() {
        
        let exception = XCTestExpectation()
        
        // Create data and tell the session to always return it
        let fakeData = Data([0, 1, 0, 1])
    
        let url = URL(string: "/mock")!
    
        // Setup our objects
        let session = createMockSession(data: fakeData, andStatusCode: 200, andError: nil)
    
        guard let mockSession = session else {
            return
        }
        
        sut = UnsplashService(endPoint: .mock(url), withSession: mockSession)
    
        let fetchCursor = Cursor(query: "nature", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashSearchPagedRequest(with: fetchCursor)
        
            // Perform the request and verify the result
        sut.mock(pageRequest: unsplashPagedRequest) { (result) in
            switch result {
                case .success(let data):
                
                    XCTAssertEqual(fakeData, data)
                    
                case .failure(let error):
                    XCTAssertNotNil(error)
            }
        }
            
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 5)
    }
    
    
}

extension UnsplashWallpapersTests {
   
    private func createMockSession(data: Data,
                            andStatusCode code: Int,
                            andError error: Error?) -> MockURLSession? {

        let response = HTTPURLResponse(url: URL(string: "TestUrl")!, statusCode: code, httpVersion: nil, headerFields: nil)
        return MockURLSession(completionHandler: (data, response, error))
    }
}
