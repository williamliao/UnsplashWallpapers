//
//  ImageCombineDownloaderTests.swift
//  UnsplashWallpapersTests
//
//  Created by 雲端開發部-廖彥勛 on 2021/5/11.
//

import XCTest
import Combine
import Network
import NetworkExtension


@testable import UnsplashWallpapers

class ImageCombineDownloaderTests: XCTestCase {
    var sut : UnsplashService!
    var mockSession: MockURLSession!
    var downloader: ImageLoader!
    let networkMonitor = NetworkConnectivityManager()

    override func setUpWithError() throws {
        networkMonitor.start()
        // Put setup code here. This method is called before the invocation of each test method in the class.
    }

    override func tearDownWithError() throws {
        sut = nil
        mockSession = nil
        networkMonitor.close()
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

extension XCTestCase {
    func awaitCompletion<T: Publisher>(
        of publisher: T,
        timeout: TimeInterval = 10
    ) throws -> [T.Output] {
        // An expectation lets us await the result of an asynchronous
        // operation in a synchronous manner:
        let expectation = self.expectation(
            description: "Awaiting publisher completion"
        )

        var completion: Subscribers.Completion<T.Failure>?
        var output = [T.Output]()

        let cancellable = publisher.sink {
            completion = $0
            expectation.fulfill()
        } receiveValue: {
            output.append($0)
        }

        // Our test execution will stop at this point until our
        // expectation has been fulfilled, or until the given timeout
        // interval has elapsed:
        waitForExpectations(timeout: timeout)

        switch completion {
        case .failure(let error):
            throw error
        case .finished:
            return output
        case nil:
            // If we enter this code path, then our test has
            // already been marked as failing, since our
            // expectation was never fullfilled.
            cancellable.cancel()
            return []
        }
    }
}

extension ImageCombineDownloaderTests {
    func testFailingWhenEncounteringError() {

        let session = URLSession(mockResponder: MockErrorURLResponder.self)
        
        let url = URL(string: "https://www.example.com/test")
        
        downloader = ImageLoader(urlSession: session)
        
        let publisher = downloader.publisher(for: url!)
        
        //let result = try? awaitCompletion(of: publisher)
        XCTAssertThrowsError(try awaitCompletion(of: publisher))
    }
    
    func testCacheImage() throws {
        
        try XCTSkipUnless(
            networkMonitor.isConnected(),
          "Network connectivity needed for this test.")
        
        let data = getFakeData()
        
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
        
        let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
        URLProtocolMock.mockURLs = [url: (nil, data, response)]

        let sessionConfiguration = URLSessionConfiguration.ephemeral
        sessionConfiguration.protocolClasses = [URLProtocolMock.self]
        let mockURLSession = URLSession(configuration: sessionConfiguration)
     
        sut = UnsplashService(endPoint: .random, withSession: mockURLSession)
        
        let downloader  = ImageCombineDownloader()
        
        let imageLoader  = ImageLoader.shared
        
        let expectation = XCTestExpectation()
        
        sut.fetchDataWithNetworkManager() { (result) in

            switch result {
                case .success(let respone):
                    
                    guard let downloadUrl = URL(string: respone[0].urls.small)  else {
                        return
                    }
                    
                    downloader.downloadWithErrorHandler(url: downloadUrl) { (image, error) in
                        
                    }
                    
                    
                case .failure(_):
                    break
            }
        }
        
        let wait = XCTWaiter()
        _ = wait.wait(for: [expectation], timeout: 5.0)
        
        let url2 = URL(string: "https://ichef.bbci.co.uk/news/976/cpsprodpb/12A9B/production/_111434467_gettyimages-1143489763.jpg")!
        
        let image = imageLoader.getCacheImage(url: url2)
        
        XCTAssertNotNil(image)
    }
}

