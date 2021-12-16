//
//  URLSessionDataTaskProtocol.swift
//  CodeableNetworkManager
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/2.
//

import Foundation

typealias DataTaskResult = (Data?, URLResponse?, Error?) -> Void

protocol URLSessionDataTaskProtocol {
    func resume()
    func cancel()
}

extension URLSessionDataTask: URLSessionDataTaskProtocol {}

protocol URLSessionProtocol {

    @available(iOS 13.0.0, *)
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) async -> URLSessionDataTaskProtocol
    
    @available(iOS 13.0.0, *)
    func dataTask(with url: URL) async -> URLSessionDataTaskProtocol
    
    @available(iOS 13.0.0, *)
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) async -> URLSessionDataTaskProtocol
    
    @available(iOS 13.0.0, *)
    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) async -> URLSessionDataTaskProtocol
    
    @available(iOS 15.0.0, *)
    func data(
        from url: URL,
        delegate: URLSessionTaskDelegate?
    ) async throws -> URLSessionDataTaskProtocol
}

extension URLSession: URLSessionProtocol {
    
    @available(iOS 15.0.0, *)
    func data(from url: URL, delegate: URLSessionTaskDelegate?) async throws -> URLSessionDataTaskProtocol {
        try await data(from: url, delegate: nil) as (Data, URLResponse) as! URLSessionDataTaskProtocol
    }
    
    @available(iOS 13.0.0, *)
    func dataTask(with url: URL) async -> URLSessionDataTaskProtocol {
        return (dataTask(with: url) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
    
    @available(iOS 13.0.0, *)
    func dataTask(with url: URL, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) async -> URLSessionDataTaskProtocol   {
        
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
    
    @available(iOS 13.0.0, *)
    func dataTask(with request: URLRequest, completionHandler: @escaping (Data?, URLResponse?, Error?) -> Void) async -> URLSessionDataTaskProtocol {
        
        return (dataTask(with: request, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
    
//    func dataTaskWithURL(_ url: URL, completion: @escaping DataTaskResult) -> URLSessionDataTaskProtocol {
//        return (dataTask(with: url, completionHandler: completion) as URLSessionDataTask) as URLSessionDataTaskProtocol
//    }
    
    @available(iOS 13.0.0, *)
    func dataTaskWithURL(_ url: URL, completion completionHandler: @escaping DataTaskResult) async
          -> URLSessionDataTaskProtocol {
        return (dataTask(with: url, completionHandler: completionHandler) as URLSessionDataTask) as URLSessionDataTaskProtocol
    }
}


protocol NetworkingMock {
    
    @available(iOS 13.0.0, *)
    func data(
        from url: URL,
        delegate: URLSessionTaskDelegate?
    ) async throws -> (Data, URLResponse)
}

extension NetworkingMock {
    // If we want to avoid having to always pass 'delegate: nil'
    // at call sites where we're not interested in using a delegate,
    // we also have to add the following convenience API (which
    // URLSession itself provides when using it directly):
    @available(iOS 13.0.0, *)
    func data(from url: URL) async throws -> (Data, URLResponse) {
        try await data(from: url, delegate: nil)
    }
}
