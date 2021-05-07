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
    
    func testSuccessfulResponse() {
        
        let exception = XCTestExpectation()
        
        let fakeData = Data([0, 1, 0, 1])
    
        mockSession = createMockSession(data: fakeData, andStatusCode: 200, andError: nil)
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashSearchPagedRequest(with: fetchCursor)
        
        sut = UnsplashService(endPoint: .collections("mock", unsplashPagedRequest), withSession: mockSession)
        
        sut.mock(pageRequest: unsplashPagedRequest) { (result) in
            switch result {
                case .success(let data):
                    XCTAssertEqual(fakeData, data)
                case .failure(_):
                    break
            }
        }
            
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 1)
    }
    
    func testNetworkClient_404Result() {
        let fakeData = Data([0, 1, 0, 1])
        mockSession = createMockSession(data: fakeData, andStatusCode: 404, andError: nil)
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        
        let exception = XCTestExpectation()
        
        sut.fetchDataWithNetworkManager(pageRequest: unsplashPagedRequest) { (result) in

            switch result {
                case .success(let respone):
                   
                    XCTAssertNotNil(respone)
                    
                case .failure(let error):
                    switch error {
                        case .statusCodeError(let error):
                            let err = error as NSError
                            XCTAssertEqual(404, err.code)
                            XCTAssertNotNil(error)
                            
                        default:
                            break
                    }
            }
        }
       
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 1)
    }
    
    func testNetworkClient_NoData() {
        
        mockSession = createMockSessionFromFile(fromJsonFile: "A", andStatusCode: 200, andError: nil)
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        
        let exception = XCTestExpectation()

        sut.fetchDataWithNetworkManager(pageRequest: unsplashPagedRequest) { (result) in

            switch result {
                case .success(_):
                    break
                case .failure(let error):
                   
                    switch error {
                        case .badData:
                            XCTAssertNotNil(error)
                            XCTAssertTrue(error.localizedDescription == "badData")
                        default:
                            break
                    }
            }
        }
       
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 1)
    }
    
    func testNetworkClient_UnExpectStatusCode() {
        let fakeData = Data([0, 1, 0, 1])
        mockSession = createMockSession(data: fakeData, andStatusCode: 500, andError: nil)
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        
        let exception = XCTestExpectation()
        
        sut.fetchDataWithNetworkManager(pageRequest: unsplashPagedRequest) { (result) in

            switch result {
                case .success(_):
                    break
                case .failure(let error):
                    switch error {
                        case .encounteredError(let error):
                            
                            let err = error as NSError
                            
                            XCTAssertNotNil(error)
                            XCTAssertEqual(500, err.code)
                            
                        default:
                            break
                    }
                    
            }
        }
       
        let wait = XCTWaiter()
        _ = wait.wait(for: [exception], timeout: 1)
    }
}

extension UnsplashWallpapersTests {
    
    private func loadJsonData(file: String) -> Data? {
        //1
        if let jsonFilePath = Bundle(for: type(of:  self)).path(forResource: file, ofType: "json") {
            let jsonFileURL = URL(fileURLWithPath: jsonFilePath)
            //2
            if let jsonData = try? Data(contentsOf: jsonFileURL) {
                return jsonData
            }
        }
        //3
        return nil
    }
   
    private func createMockSession(data: Data,
                            andStatusCode code: Int,
                            andError error: Error?) -> MockURLSession? {

        let response = HTTPURLResponse(url: URL(string: "TestUrl")!, statusCode: code, httpVersion: nil, headerFields: nil)
        return MockURLSession(completionHandler: (data, response, error))
    }
    
    private func createMockSessionFromFile(fromJsonFile file: String,
                            andStatusCode code: Int,
                            andError error: Error?) -> MockURLSession? {

        let data = loadJsonData(file: file)
        let response = HTTPURLResponse(url: URL(string: "TestUrl")!, statusCode: code, httpVersion: nil, headerFields: nil)
        return MockURLSession(completionHandler: (data, response, error))
    }
}
