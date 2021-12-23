//
//  NetworkManager+Mock.swift
//  CodeableNetworkManager
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/2.
//

import Foundation

class MockURLSessionDataTask: URLSessionDataTaskProtocol {
    
    private (set) var resumeWasCalled = false
    
    func cancel() {}
    func resume() {
        resumeWasCalled = true
    }
}

class MockURLSession: URLSessionProtocol {
    
    private (set) var lastURL: URL?
    
    var nextData: Data?
    var nextResponse: URLResponse?
    var nextError: Error?
    var result = Result<Data, Error>.success(Data())
    var dataTask = MockURLSessionDataTask()
    var completionHandler: (Data?, URLResponse?, Error?)

    init(completionHandler: (Data?, URLResponse?, Error?)) {
        self.completionHandler = completionHandler
    }

    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        completionHandler(self.completionHandler.0, self.completionHandler.1, self.completionHandler.2)
        return dataTask
    }
    
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTaskProtocol {
        completionHandler(self.completionHandler.0, self.completionHandler.1, self.completionHandler.2)
        return dataTask
    }
    
    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
        lastURL = url
        
        nextData = self.completionHandler.0
        nextResponse = self.completionHandler.1
        nextError = self.completionHandler.2
        completion(self.completionHandler.0, self.completionHandler.1, self.completionHandler.2)
        return dataTask
    }
    
    func dataTask(with url: URL) async -> URLSessionDataTaskProtocol {
        lastURL = url
        
        nextData = self.completionHandler.0
        nextResponse = self.completionHandler.1
        nextError = self.completionHandler.2
        return dataTask
    }
    
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> URLSessionDataTaskProtocol {
        return try (result.get(), URLResponse()) as! URLSessionDataTaskProtocol
    }
    
    func data(
        from url: URL,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse) {
        try (result.get(), URLResponse())
    }
}
