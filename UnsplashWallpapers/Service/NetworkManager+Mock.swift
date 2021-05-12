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
}

// We create a partial mock by subclassing the original class
class URLSessionDataTaskMock: URLSessionDataTask {
    private let closure: () -> Void

    init(closure: @escaping () -> Void) {
        self.closure = closure
    }

    // We override the 'resume' method and simply call our closure
    // instead of actually resuming any task.
    override func resume() {
        closure()
    }
}

class URLSessionMock: URLSession {
    typealias CompletionHandler = (Data?, URLResponse?, Error?) -> Void

    // Properties that enable us to set exactly what data or error
    // we want our mocked URLSession to return for any request.
    var data: Data?
    var error: Error?

    override func dataTask(
        with url: URL,
        completionHandler: @escaping CompletionHandler
    ) -> URLSessionDataTask {
        let data = self.data
        let error = self.error

        return URLSessionDataTaskMock {
            completionHandler(data, nil, error)
        }
    }
}

class SeededURLSession: URLSession {
    override func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) -> URLSessionDataTask {
        return SeededDataTask(url: url, completion: completionHandler)
    }
}

class SeededDataTask: URLSessionDataTask {
    private let url: URL
    private let completion: DataTaskResult

    init(url: URL, completion: @escaping DataTaskResult) {
        self.url = url
        self.completion = completion
    }

    override func resume() {
        if let json = ProcessInfo.processInfo.environment[url.absoluteString] {
            let response = HTTPURLResponse(url: url, statusCode: 200, httpVersion: nil, headerFields: nil)
            let data = json.data(using: .utf8)
            completion(data, response, nil)
        }
    }
}

struct UITestingConfig {
    static let urlSession: URLSession = UITesting() ?
        SeededURLSession() : URLSession.shared
}

private func UITesting() -> Bool {
  ProcessInfo.processInfo.arguments.contains("UI-TESTING")
}
