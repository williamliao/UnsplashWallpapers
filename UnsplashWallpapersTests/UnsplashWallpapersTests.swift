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
    
    func test_GET_StartsTheRequest() {
     
        let fakeData = Data([0, 1, 0, 1])
        mockSession = createMockSession(data: fakeData, andStatusCode: 200, andError: nil)

        let dataTask = MockURLSessionDataTask()
        mockSession.dataTask = dataTask

        let url = URL(string: "https://api.unsplash.com/photos/random?count=30&client_id=d0bd0d66796be14d38b9f5e45852397c35457a7479978ff4db3eea2fcd7e2383")!
        
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        
        sut.get { (data, res, error) in
            XCTAssertNotNil(data)
        }
        
        XCTAssertEqual(mockSession.lastURL, url)
        XCTAssert(dataTask.resumeWasCalled)
    }
    
    func test_GET_WithResponseData_ReturnsTheData() {
        
        let expectedData = "{}".data(using: .utf8)
        mockSession = createMockSession(data: expectedData!, andStatusCode: 200, andError: nil)
        mockSession.nextData = expectedData

        var actualData: Data?
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        sut.get() { (data, _, _)  in
            actualData = data
        }

        XCTAssertEqual(actualData, expectedData)
    }
    
    func test_GET_WithANetworkError_ReturnsANetworkError() {
        
        mockSession = createMockSessionFromFile(fromJsonFile: "A", andStatusCode: 200, andError: nil)
        
        mockSession.nextError = NSError(domain: "error", code: 0, userInfo: nil)

        var error: Error?
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        sut.get() { (_, _, networkError) -> Void in
            error = networkError
        }
        
        XCTAssertNotNil(error)
    }
    
    func testNetworkClient_successResult() {
        
        let expectation = XCTestExpectation()
        sut = UnsplashService(endPoint: .random)
        
        sut.fetchDataWithNetworkManager() { (result) in

            switch result {
                case .success(let respone):
                   
                    XCTAssertNotNil(respone)
                    XCTAssertTrue(respone.count == 30)
                    expectation.fulfill()
                    
                case .failure(let error):
                    XCTAssertNotNil(error)
            }
        }
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1)
    }
    
    func testSuccessfulResponse() {
        
        let expectation = XCTestExpectation()
        
        let fakeData = Data([0, 1, 0, 1])
    
        mockSession = createMockSession(data: fakeData, andStatusCode: 200, andError: nil)
        
        let fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        let unsplashPagedRequest = UnsplashSearchPagedRequest(with: fetchCursor)
        
        sut = UnsplashService(endPoint: .collections("mock", unsplashPagedRequest), withSession: mockSession)
        
        sut.mock() { (result) in
            switch result {
                case .success(let data):
                    XCTAssertEqual(fakeData, data)
                    expectation.fulfill()
                case .failure(_):
                    break
            }
        }
            
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1)
    }
    
    func testNetworkClient_404Result() {
        let fakeData = Data([0, 1, 0, 1])
        mockSession = createMockSession(data: fakeData, andStatusCode: 404, andError: nil)
        
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        
        let expectation = XCTestExpectation()
        
        sut.fetchDataWithNetworkManager() { (result) in

            switch result {
                case .success(let respone):
                   
                    XCTAssertNotNil(respone)
                    
                case .failure(let error):
                    switch error {
                        case .statusCodeError(let error):
                            let err = error as NSError
                            XCTAssertEqual(404, err.code)
                            XCTAssertNotNil(error)
                            expectation.fulfill()
                            
                        default:
                            break
                    }
            }
        }
       
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1)
    }
    
    func testNetworkClient_NoData() {
        
        mockSession = createMockSessionFromFile(fromJsonFile: "A", andStatusCode: 200, andError: nil)
       
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        
        let expectation = XCTestExpectation()

        sut.fetchDataWithNetworkManager() { (result) in

            switch result {
                case .success(_):
                    break
                case .failure(let error):
                   
                    switch error {
                        case .badData:
                            XCTAssertNotNil(error)
                            XCTAssertTrue(error.localizedDescription == "badData")
                            expectation.fulfill()
                        default:
                            break
                    }
            }
        }
       
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1)
    }
    
    func testNetworkClient_UnExpectStatusCode() {
        let fakeData = Data([0, 1, 0, 1])
        mockSession = createMockSession(data: fakeData, andStatusCode: 500, andError: nil)
        
        sut = UnsplashService(endPoint: .random, withSession: mockSession)
        
        let expectation = XCTestExpectation()
        
        sut.fetchDataWithNetworkManager() { (result) in

            switch result {
                case .success(_):
                    break
                case .failure(let error):
                    switch error {
                        case .encounteredError(let error):
                            
                            let err = error as NSError
                            
                            XCTAssertNotNil(error)
                            XCTAssertEqual(500, err.code)
                            
                            expectation.fulfill()
                            
                        default:
                            break
                    }
                    
            }
        }
       
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1)
    }
    
    func testWithURLProtocolMock() {
        
        let expectation = XCTestExpectation()
        
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
        components.path = "/photos/random"
        
        components.queryItems = [
            URLQueryItem(name: "count", value: "30"),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
        ]
        
        guard let url = components.url  else {
            return
        }
        
        let data = getFakeData()
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolMock.mockURLs = [url: (nil, data, response)]

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        let mockURLSession = URLSession(configuration: sessionConfiguration)
     
        sut = UnsplashService(endPoint: .random, withSession: mockURLSession)
        
        sut.fetchDataWithNetworkManager() { (result) in

            switch result {
                case .success(let respone):
                    
                    XCTAssertNotNil(respone)
                    XCTAssertTrue(respone.count == 1)
                    expectation.fulfill()
                    
                case .failure(let error):
                    print("error \(error)")
                    XCTAssertNotNil(error)
            }
        }
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 1.0)
    }
    
    func testWithPageNumber() {
        //fetch First page
        var fetchCursor = Cursor(query: "", page: 1, perPage: 10, parameters: [:])
        var unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        
        XCTAssertTrue(unsplashPagedRequest.cursor.page == 1)
        
        
        //fetch next page
        fetchCursor = unsplashPagedRequest.nextCursor()
        
        unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        
        XCTAssertTrue(unsplashPagedRequest.cursor.page == 2)
        
        //fetch three page
        fetchCursor = unsplashPagedRequest.nextCursor()
        
        unsplashPagedRequest = UnsplashPagedRequest(with: fetchCursor)
        
        XCTAssertTrue(unsplashPagedRequest.cursor.page == 3)
    }
    
    func testDecoding() throws {
        /// When the Data initializer is throwing an error, the test will fail.
        let jsonData = loadJsonData(file: "upRandom")
        
        guard let json = jsonData else {
            return
        }

        /// The `XCTAssertNoThrow` can be used to get extra context about the throw
        XCTAssertNoThrow(try JSONDecoder().decode([Response].self, from: json))
    }
    
    func testUserNameNotEmpty() throws {
        let readFromFileData = loadJsonData(file: "upRandom")
 
        do {
            let jsonData = try XCTUnwrap(readFromFileData)
            let result = try JSONDecoder().decode([Response].self, from: jsonData)
            //Alexandra Tran
        
            let name =  try XCTUnwrap(result[0].user?.name)
            XCTAssertFalse(name.isEmpty)
            
        } catch  {
            print(error)
            XCTFail("Deocde error")
        }
    }
}
