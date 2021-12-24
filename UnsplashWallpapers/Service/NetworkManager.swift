//
//  NetworkManager.swift
//  CodeableNetworkManager
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/2.
//

import Foundation
import UIKit

public enum APIResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}

public enum ServerError: Error {
    case encounteredError(Error)
    case statusCodeError(Error)
    case statusCode(NSInteger)
    case statusClientCode(NSInteger)
    case statusBackendCode(NSInteger)
    case badRequest //400
    case unAuthorized //401
    case forbidden //403
    case notFound //404
    case methodNotAllowed // 405
    case timeOut //408
    case unSupportedMediaType //415
    case rateLimitted //429
    case serverError //500
    case serverUnavailable //503
    case gatewayTimeout //504
    case networkAuthenticationRequired //511
    case httpVersionNotSupported
    case jsonDecodeFailed
    case badData
    case invalidURL
    case invalidImage
    case invalidResponse
    case noHTTPResponse
    case noInternetConnect
    case networkConnectionLost
    case unKnown
    
    static func map(_ error: Error) -> ServerError {
        return (error as? ServerError) ?? .encounteredError(error)
    }
    
    var localizedDescription: String {
        switch self {
        case .encounteredError(let error):
            return NSLocalizedString(error.localizedDescription, comment: "")
        case .notFound:
            return NSLocalizedString("notFound", comment: "")
        case .serverError:
            return NSLocalizedString("Internal Server Error", comment: "")
        case .serverUnavailable:
            return NSLocalizedString("server Unavailable", comment: "")
        case .gatewayTimeout:
            return NSLocalizedString("Gateway Timeout", comment: "")
        case .httpVersionNotSupported:
            return NSLocalizedString("HTTP Version Not Supported", comment: "")
        case .networkAuthenticationRequired:
            return NSLocalizedString("Network Authentication Required", comment: "")
        case .timeOut:
            return NSLocalizedString("timeOut", comment: "")
        case .unSupportedMediaType:
            return NSLocalizedString("The media format of the requested data is not supported by the server, so the server is rejecting the request.", comment: "")
        case .jsonDecodeFailed:
            return NSLocalizedString("jsonDecodeFailed", comment: "")
        case .badRequest:
            return NSLocalizedString("badRequest", comment: "")
        case .methodNotAllowed:
            return NSLocalizedString("methodNotAllowed", comment: "")
        case .forbidden:
            return NSLocalizedString("forbidden", comment: "")
        case .badData:
            return NSLocalizedString("badData", comment: "")
        case .statusCodeError(let error):
            return NSLocalizedString("statusCodeError:\(error.localizedDescription)", comment: "")
        case .statusCode(let code):
            return NSLocalizedString("Error With Status Code:\(code)", comment: "")
        case .statusClientCode(let code):
            return NSLocalizedString("Client Error With Status Code:\(code)", comment: "")
        case .statusBackendCode(let code):
            return NSLocalizedString("Backend Error With Status Code:\(code)", comment: "")
        case .invalidURL:
            return NSLocalizedString("invalidURL", comment: "")
        case .invalidImage:
            return NSLocalizedString("invalidImage", comment: "")
        case .invalidResponse:
            return NSLocalizedString("badServerResponse", comment: "")
        case .noHTTPResponse:
            return NSLocalizedString("noHTTPResponse", comment: "")
        case .noInternetConnect:
            return NSLocalizedString("notConnectedToInternet", comment: "")
        case .networkConnectionLost:
            return NSLocalizedString("networkConnectionLost", comment: "")
        case .rateLimitted:
            return NSLocalizedString("Too Many Requests", comment: "")
        case .unAuthorized:
            return NSLocalizedString("Unauthorized, client must authenticate itself to get the requested response", comment: "")
        case .unKnown:
            return NSLocalizedString("unknown", comment: "")
        }
    }
}

private extension Int {
    var megabytes: Int { return self * 1024 * 1024 }
}

class NetworkManager {
    
    static let sharedInstance = NetworkManager()
    
    enum RequestType: String {
        case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
    }
    
    enum QueryFormat {
        case json
        case urlEncoded
    }

    enum QueryType {
        case body
        case path
    }
    
    var format: NetworkManager.QueryFormat { return .urlEncoded }
    var type: NetworkManager.QueryType { return .path }
    
    private static var cache: URLCache = {
        let memoryCapacity = 50 * 1024 * 1024
        let diskCapacity = 100 * 1024 * 1024
        let diskPath = "unsplash"
        
        if #available(iOS 13.0, *) {
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                directory: URL(fileURLWithPath: diskPath, isDirectory: true)
            )
        }
        else {
            #if !targetEnvironment(macCatalyst)
            return URLCache(
                memoryCapacity: memoryCapacity,
                diskCapacity: diskCapacity,
                diskPath: diskPath
            )
            #else
            fatalError()
            #endif
        }
    }()
    
    private var successCodes: CountableRange<Int> = 200..<299
    private var failureClientCodes: CountableRange<Int> = 400..<499
    private var failureBackendCodes: CountableRange<Int> = 500..<511
    var timeoutInterval = 30.0
    private var task: URLSessionDataTaskProtocol?
    
    enum NetworkEndpoint {
        case random
        case randomWith(String, UnsplashPagedRequest)
        case topic(String, UnsplashPagedRequest)
        case topicDetail(String, UnsplashPagedRequest)
        case search(String, UnsplashSearchPagedRequest)
        case collections(String, UnsplashSearchPagedRequest)
        case users(String, UnsplashSearchPagedRequest)
        case get_collection(String, UnsplashCollectionRequest)
        case user_photo(String, String, UnsplashUserListRequest)
        case photoDetail(String)
        case mock(URL)
    }

    typealias JSONTaskCompletionHandler = (Decodable?, ServerError?) -> Void
   
    private var session: URLSessionProtocol
    private var endPoint: NetworkEndpoint
    
    init(endPoint: NetworkEndpoint = .random, withSession session: URLSessionProtocol = urlSession()) {
        self.session = session
        self.endPoint = endPoint
    }
    
    // MARK: - Base
    
    public static var urlSessionConfiguration: URLSessionConfiguration = {
        let sessionConfiguration = URLSessionConfiguration.default
        sessionConfiguration.requestCachePolicy = .returnCacheDataElseLoad
        sessionConfiguration.timeoutIntervalForRequest = 3.0
        sessionConfiguration.timeoutIntervalForResource = 15.0
        sessionConfiguration.urlCache = cache
        sessionConfiguration.waitsForConnectivity = true
        return sessionConfiguration
    }()
    
    internal static func urlSession() -> URLSession {
        let networkingHandler = NetworkingHandler()
        let session = URLSession(configuration: NetworkManager.urlSessionConfiguration, delegate: networkingHandler, delegateQueue: nil)
        return session
    }

    static let defaultHeaders = [
        "Content-Type": "application/json",
        "cache-control": "no-cache",
    ]
    
    internal static func buildHeaders(key: String, value: String) -> [String: String] {
        var headers = defaultHeaders
        headers[key] = value
        return headers
    }
    
    internal static func basicAuthorization(email: String, password: String) -> String {
        let loginString = String(format: "%@:%@", email, password)
        let loginData: Data = loginString.data(using: .utf8)!
        return loginData.base64EncodedString()
    }
    
    func prepareURLComponents() -> URLComponents? {
        switch endPoint {
            case .random:
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/photos/random"
                
                components.queryItems = [
                    URLQueryItem(name: "count", value: "30"),
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
                ]
                
                return components
                
            case .randomWith(let query, let request):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/photos/random"
                
                components.queryItems = [
                    URLQueryItem(name: "query", value: query),
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
                    URLQueryItem(name: "orientation", value: "landscape"),
                    URLQueryItem(name: "count", value: "10"),
                    URLQueryItem(name: "per_page", value: String(request.cursor.perPage)),
                    URLQueryItem(name: "page", value: String(request.cursor.page)),
                ]
                
                return components
                
            case .topic(let id, let request):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/topics/\(id)"
                
                components.queryItems = [
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
                    URLQueryItem(name: "count", value: String(request.cursor.page))
                ]
                
                return components
                
            case .topicDetail(let id, let request):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/topics/\(id)/photos"
                
                components.queryItems = [
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
                    URLQueryItem(name: "count", value: String(request.cursor.page))
                ]
                
                return components
                
            case .photoDetail(let id):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/photos/\(id)/"
                
                components.queryItems = [
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)
                ]
                
                return components

            case .search(let query, let request):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/search/photos"
                
                components.queryItems = [
                    URLQueryItem(name: "query", value: query),
                    URLQueryItem(name: "per_page", value: String(request.cursor.perPage)),
                    URLQueryItem(name: "page", value: String(request.cursor.page)),
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
                    URLQueryItem(name: "orientation", value: "landscape"),
                ]
                
                return components
                
            case .collections(let query, let request):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/search/collections"
                
                components.queryItems = [
                    URLQueryItem(name: "query", value: query),
                    URLQueryItem(name: "per_page", value: String(request.cursor.perPage)),
                    URLQueryItem(name: "page", value: String(request.cursor.page)),
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
                    URLQueryItem(name: "orientation", value: "landscape"),
                ]
                
                return components
            
            case .users(let query, let request):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                  components.path = "/search/users"
                
                components.queryItems = [
                    URLQueryItem(name: "query", value: query),
                    URLQueryItem(name: "per_page", value: String(request.cursor.perPage)),
                    URLQueryItem(name: "page", value: String(request.cursor.page)),
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
                ]
                
                return components
                
            case .get_collection(let id, let request):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/collections/\(id)/photos"
                
                components.queryItems = [
                    URLQueryItem(name: "per_page", value: String(request.cursor.perPage)),
                    URLQueryItem(name: "page", value: String(request.cursor.page)),
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)
                ]
                
                return components
            case .user_photo(let username, let endPoint, let request):
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/users/\(username)/\(endPoint)"
                
                components.queryItems = [
                    URLQueryItem(name: "per_page", value: String(request.cursor.perPage)),
                    URLQueryItem(name: "page", value: String(request.cursor.page)),
                    URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)
                ]
                
                return components
            case .mock(let url):
                
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = "api.testExample.com"
                components.path = url.absoluteString
                
                return components
        }
    }

    func prepareHeaders() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Client-ID \(UnsplashAPI.accessKey)"
        return headers
    }
    
    // MARK: - Help Method
    
    @available(iOS 13.0.0, *)
    func get(completion: @escaping DataTaskResult) {
        
        let components = prepareURLComponents()
        
        guard let url = components?.url else {
            return
        }
        
        let task = URLSession.shared.dataTask(with: url) { (data, _, error) -> Void in
            if let _ = error {
                completion(nil, nil, ServerError.invalidURL)
            } else {
                completion(data, nil, nil)
            }
        }
        task.resume()
    }
    
    @available(iOS 13.0.0, *)
    func getConcurrency(completion: @escaping DataTaskResult) async throws {
        
        let components = prepareURLComponents()
        
        guard let url = components?.url else {
            return
        }
        
        let task = await session.dataTaskWithURL(url) { (data, _, error) -> Void in
            if let _ = error {
                completion(nil, nil, ServerError.invalidURL)
            } else {
                completion(data, nil, nil)
            }
        }
        task.resume()
    }
    
    @available(iOS 13.0.0, *)
    func createConcurrencyRequestWithURL<T: Decodable>(url: URL, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        Task {
            let task = try await decodingTaskWithConcurrency(with: mutableRequest, decodingType: T.self) { (json , error) in
                
                DispatchQueue.main.async {
                    guard let json = json else {
                        if let error = error {
                            completion(APIResult.failure(error))
                        }
                        return
                    }

                    if let value = decode(json) {
                        completion(.success(value))
                    }
                }
            }
            task?.resume()
        }
    }
    
    @available(iOS 13.0.0, *)
    func createRequestWithURL<T: Decodable>(url: URL, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        Task {
            do {
                let task = try await decodingTaskWithConcurrency(with: mutableRequest, decodingType: T.self) { (json , error) in
                    
                    DispatchQueue.main.async {
                        guard let json = json else {
                            if let error = error {
                                completion(APIResult.failure(error))
                            }
                            return
                        }

                        if let value = decode(json) {
                            completion(.success(value))
                        }
                    }
                }
                task?.resume()
            } catch  {
                
                print(error)
                
                if let error = error as? ServerError {
                    completion(APIResult.failure(error))
                } else {
                    completion(APIResult.failure(ServerError.unKnown))
                }
                
            }
        }
    }
    
    func createURLRequest(params: Dictionary<String, AnyObject>? = nil, method: RequestType ) throws -> URLRequest {
     
        guard let url = prepareURLComponents()?.url else {
            throw ServerError.invalidURL
        }
        
        switch type {
            case .body:
                switch format {
                case .json:
                    
                    var mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
                    mutableRequest.addValue("application/json", forHTTPHeaderField: "Content-Type")
                    if let parameters = params {
                        switch format {
                        case .json:
                            mutableRequest.httpBody = try JSONSerialization.data(withJSONObject: parameters, options: [])
                        case .urlEncoded:
                            mutableRequest.httpBody = queryParameters(parameters, urlEncoded: true).data(using: .utf8)
                        }
                    }
                    mutableRequest.httpMethod = method.rawValue
                    return mutableRequest
                case .urlEncoded:
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
                    components.query = queryParameters(params)
                    var mutableRequest = URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
                    mutableRequest.httpMethod = method.rawValue
                    
                    return mutableRequest
                }
                
            case .path:
                guard let components = prepareURLComponents() else {
                    throw ServerError.invalidURL
                }
            
                var mutableRequest = URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
                mutableRequest.httpMethod = method.rawValue
                
                return mutableRequest
        }
    }
    
    func query<T: Decodable>(method: RequestType, decode: @escaping (Decodable) -> T?) async throws ->
    APIResult<T, ServerError> {
        do {
            
            if UnsplashAPI.secretKey.isEmpty && UnsplashAPI.accessKey.isEmpty {
                throw ServerError.unAuthorized
            }
            
            let components = prepareURLComponents()
             
            try Task.checkCancellation()
             
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(APIResult<T, ServerError>), Error>) in
                
                guard let url = components?.url else {
                    continuation.resume(returning: APIResult.failure(ServerError.invalidURL))
                    return
                }
                
                createRequestWithURL(url: url, decode: decode) { result in
                    continuation.resume(returning: result)
                }
            })
        } catch {
            print("queryWithConcurrency error \(error)")
            return APIResult.failure(ServerError.unKnown)
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}

// MARK: - Base URLSession

extension NetworkManager {
    
    private func queryParameters(_ parameters: [String: Any]?, urlEncoded: Bool = false) -> String {
        var allowedCharacterSet = CharacterSet.alphanumerics
        allowedCharacterSet.insert(charactersIn: ".-_")

        var query = ""
        parameters?.forEach { key, value in
            let encodedValue: String
            if let value = value as? String {
                encodedValue = urlEncoded ? value.addingPercentEncoding(withAllowedCharacters: allowedCharacterSet) ?? "" : value
            } else {
                encodedValue = "\(value)"
            }
            query = "\(query)\(key)=\(encodedValue)&"
        }
        return query
    }
    
    private func jsonPrettyPrint(data: Data) {
        guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
        let responeData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
        let prettyPrintedString = NSString(data: responeData, encoding: String.Encoding.utf8.rawValue) else { return }
        print(prettyPrintedString)
    }
    
    private func handleHTTPResponse(statusCode: Int) -> ServerError {
       
        if self.failureClientCodes.contains(statusCode) { //400..<499
            switch statusCode {
                case 401:
                    return ServerError.unAuthorized
                case 403:
                    return ServerError.forbidden
                case 404:
                    return ServerError.notFound
                case 405:
                    return ServerError.methodNotAllowed
                case 408:
                    return ServerError.timeOut
                case 415:
                    return ServerError.unSupportedMediaType
                case 429:
                    return ServerError.rateLimitted
                default:
                    return ServerError.statusClientCode(statusCode)
            }
            
        } else if self.failureBackendCodes.contains(statusCode) { //500..<511
            switch statusCode {
                case 500:
                    return ServerError.serverError
                case 503:
                    return ServerError.serverUnavailable
                case 504:
                    return ServerError.gatewayTimeout
                case 511:
                    return ServerError.networkAuthenticationRequired
                default:
                    return ServerError.statusClientCode(statusCode)
            }
        } else {
            // Server returned response with status code different than expected `successCodes`.
            let info = [
                NSLocalizedDescriptionKey: "Request failed with code \(statusCode)",
                NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoint mapping or backend bug."
            ]
            let error = NSError(domain: "NetworkService", code: statusCode, userInfo: info)
            return ServerError.encounteredError(error)
        }
    }
    
    func handleETag(url: URL, timeoutInterval: TimeInterval) -> URLRequest {
        
        var request = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        request.allHTTPHeaderFields = prepareHeaders()

        if UserDefaults.standard.object(forKey: "ETag") != nil {
            let tag = UserDefaults.standard.string(forKey: "ETag")
            if let etag = tag {
                request.addValue(etag, forHTTPHeaderField: "If-None-Match")
            }
        }
        
        return request
        
    }
}

// MARK: - Concurrency

extension NetworkManager {
    
    @available(iOS 13.0.0, *)
    private func decodingTaskWithConcurrency<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) async throws -> URLSessionDataTaskProtocol? {
        
        let decoder = JSONDecoder()
        
        task = await session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                if let error = error {
                    
                    let errorCode = (error as NSError).code
                    
                    switch errorCode {
                        case NSURLErrorTimedOut:
                            completion(nil, ServerError.timeOut)
                        default:
                            completion(nil, ServerError.encounteredError(error))
                    }
                    return
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                completion(nil, ServerError.noHTTPResponse)
                return
            }
            
            if self.successCodes.contains(httpResponse.statusCode) {
                
                guard let data = data else {
                    completion(nil, ServerError.badData)
                    return
                }

                do {
                    let genericModel = try decoder.decode(decodingType, from: data)
                    completion(genericModel, nil)
                } catch {
                    completion(nil, ServerError.encounteredError(error))
                }
                
            } else {
                completion(nil, self.handleHTTPResponse(statusCode: httpResponse.statusCode))
            }
        }
        
        return task
    }
    
    @available(iOS 13.0.0, *)
    func fetchWithConcurrency<T: Decodable>(method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        guard let request = try? createURLRequest(method: method) else {
            completion(APIResult.failure(ServerError.invalidURL))
            return
        }
     
        Task {
            let task = try await decodingTaskWithConcurrency(with: request, decodingType: T.self) { (json , error) in
                
                DispatchQueue.main.async {
                    guard let json = json else {
                        if let error = error {
                            completion(APIResult.failure(error))
                        }
                        return
                    }

                    if let value = decode(json) {
                        completion(.success(value))
                    }
                }
            }
            task?.resume()
        }
        
        
    }
    
    @available(iOS 13.0.0, *)
    func fetchDataWithConcurrency<T: Decodable>(method: RequestType, decode: @escaping (Decodable) -> T?) async throws -> APIResult<T, ServerError> {
        try Task.checkCancellation()
        
        if UnsplashAPI.secretKey.isEmpty && UnsplashAPI.accessKey.isEmpty {
            throw ServerError.unAuthorized
        }
        
        do {
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(APIResult<T, ServerError>), Error>) in
                fetchWithConcurrency(method: method, decode: decode) { result in
                    continuation.resume(returning: result)
                }
            })
        } catch ServerError.unAuthorized  {
            return APIResult.failure(ServerError.unAuthorized)
        } catch ServerError.timeOut  {
            return APIResult.failure(ServerError.timeOut)
        } catch {
            print("fetchDataWithConcurrency error \(error)")
            return APIResult.failure(ServerError.unKnown)
        }
    }

    @available(iOS 13.0.0, *)
    func queryWithConcurrency<T: Decodable>(pageRequest: UnsplashSearchPagedRequest, method: RequestType, decode: @escaping (Decodable) -> T?) async throws -> APIResult<T, ServerError> {
        
        if UnsplashAPI.secretKey.isEmpty && UnsplashAPI.accessKey.isEmpty {
            throw ServerError.unAuthorized
        }
        
        let components = prepareURLComponents()
        
        try Task.checkCancellation()
        
        do {
            return try await withCheckedThrowingContinuation({
                (continuation: CheckedContinuation<(APIResult<T, ServerError>), Error>) in
                
                if let url = components?.url {
                    createRequestWithURL(url: url, decode: decode) { result in
                        continuation.resume(returning: result)
                    }
                } else {
                    continuation.resume(returning: APIResult.failure(ServerError.invalidURL))
                }
            })
        } catch {
            print("queryWithConcurrency error \(error)")
            return APIResult.failure(ServerError.unKnown)
        }
    }
    
}

// MARK: - URLSessionTaskDelegate

class NetworkingHandler: NSObject, URLSessionTaskDelegate {
    
    func urlSession(_ session: URLSession, taskIsWaitingForConnectivity task: URLSessionTask) {
        // Indicate network status, e.g., offline mode
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OfflineModeOn"), object: nil)
    }
    
    func urlSession(_ session: URLSession, task: URLSessionTask, willBeginDelayedRequest: URLRequest, completionHandler: (URLSession.DelayedRequestDisposition, URLRequest?) -> Void) {
        // Indicate network status, e.g., back to online
        NotificationCenter.default.post(name: NSNotification.Name(rawValue: "OfflineModeOff"), object: nil)
    }
}
