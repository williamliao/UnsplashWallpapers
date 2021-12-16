//
//  NetworkManager+MockConcurrency.swift
//  UnsplashWallpapers
//
//  Created by 雲端開發部-廖彥勛 on 2021/11/19.
//

import Foundation

class MockConcurrencyURLSessionDataTask: URLSessionDataTaskProtocol {
    
    private (set) var resumeWasCalled = false
    
    func cancel() {}
    func resume() {
        resumeWasCalled = true
    }
}

class MockConcurrencyURLSession: URLSessionProtocol {
    
    
   
    private (set) var lastURL: URL?
    
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?
    
    var dataTask = MockConcurrencyURLSessionDataTask()
    var completionHandler: (Data?, URLResponse?, Error?)

    init(completionHandler: (Data?, URLResponse?, Error?)) {
        self.completionHandler = completionHandler
    }
    
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) async -> URLSessionDataTaskProtocol  {
        lastURL = url
        completionHandler(self.completionHandler.0, self.completionHandler.1, self.completionHandler.2)
        return dataTask as URLSessionDataTaskProtocol
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) async -> URLSessionDataTaskProtocol {
        lastURL = request.url
        completionHandler(self.completionHandler.0, self.completionHandler.1, self.completionHandler.2)
        return dataTask as URLSessionDataTaskProtocol
    }
    
    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) async -> URLSessionDataTaskProtocol {
        lastURL = url
        
        nextData = self.completionHandler.0
        nextResponse = self.completionHandler.1
        nextError = self.completionHandler.2
        completion(self.completionHandler.0, self.completionHandler.1, self.completionHandler.2)
        return dataTask as URLSessionDataTaskProtocol
    }
    
    func dataTask(with url: URL) async -> URLSessionDataTaskProtocol {
        lastURL = url
        nextData = self.completionHandler.0
        nextResponse = self.completionHandler.1
        nextError = self.completionHandler.2
        return dataTask as URLSessionDataTaskProtocol
    }
}
