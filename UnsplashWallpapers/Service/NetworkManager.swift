//
//  NetworkManager.swift
//  CodeableNetworkManager
//
//  Created by 雲端開發部-廖彥勛 on 2021/3/2.
//

import Foundation

public enum APIResult<T, U> where U: Error  {
    case success(T)
    case failure(U)
}

public enum ServerError: Error {
    case encounteredError(Error)
    case statusCodeError(Int)
    case badRequest
    case forbidden
    case notFound
    case methodNotAllowed
    case timeOut
    case serverError
    case serverUnavailable
    case jsonDecodeFailed
    case badURL
    case badData
    case invalidURL
    case noHTTPResponse
    
    var localizedDescription: String {
        switch self {
        case .encounteredError(let error):
            return NSLocalizedString(error.localizedDescription, comment: "")
        case .notFound:
            return NSLocalizedString("notFound", comment: "")
        case .serverError:
            return NSLocalizedString("serverError", comment: "")
        case .serverUnavailable:
            return NSLocalizedString("serverUnavailable", comment: "")
        case .timeOut:
            return NSLocalizedString("timeOut", comment: "")
        case .jsonDecodeFailed:
            return NSLocalizedString("jsonDecodeFailed", comment: "")
        case .badURL:
            return NSLocalizedString("Bad Url", comment: "")
        case .badRequest:
            return NSLocalizedString("badRequest", comment: "")
        case .methodNotAllowed:
            return NSLocalizedString("methodNotAllowed", comment: "")
        case .forbidden:
            return NSLocalizedString("forbidden", comment: "")
        case .badData:
            return NSLocalizedString("badData", comment: "")
        case .statusCodeError(let code):
            return NSLocalizedString("statusCodeError:\(code)", comment: "")
        case .invalidURL:
            return NSLocalizedString("invalidURL", comment: "")
        case .noHTTPResponse:
            return NSLocalizedString("noHTTPResponse", comment: "")
        }
    }
}

class NetworkManager {
    
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
    private var failureCodes: CountableRange<Int> = 400..<499
    var timeoutInterval = 30.0
    private var task: URLSessionDataTaskProtocol?
   // var cursor: UnsplashPagedRequest.Cursor!
    //var unsplashSearchService: UnsplashSearchRequest = UnsplashSearchRequest()
    
    enum NetworkEndpoint {
        case random
        case topic
        case search(String, UnsplashSearchPagedRequest)
        case collections(String, UnsplashSearchPagedRequest)
        case users(String, UnsplashSearchPagedRequest)
        case get_collection(String, UnsplashCollectionRequest)
        case user_photo(String, String, UnsplashUserListRequest)
        case mock(URL)
    }
    //APIResult
    typealias JSONTaskCompletionHandler = (Decodable?, ServerError?) -> Void

    private var session: URLSessionProtocol
    private var endPoint: NetworkEndpoint
    
    init(endPoint: NetworkEndpoint = .random, withSession session: URLSessionProtocol = urlSession()) {
        self.session = session
        self.endPoint = endPoint
    }
    
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
                    
                ]
                
                return components
                
            case .topic:
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                components.path = "/topics"
                
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

    func prepareParameters() -> [String: Any]? {
        return nil
    }

    func prepareHeaders() -> [String: String]? {
        var headers = [String: String]()
        headers["Authorization"] = "Client-ID \(UnsplashAPI.accessKey)"
        return headers
    }
    
    func fetch<T: Decodable>(method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        guard var request = try? createURLRequest() else {
            completion(APIResult.failure(ServerError.invalidURL))
            return
        }
        //request.setValue("v1", forKey: "Accept-Version")
        request.httpMethod = method.rawValue

        request.allHTTPHeaderFields = prepareHeaders()
        
        if UserDefaults.standard.object(forKey: "ETag") != nil {
            let tag = UserDefaults.standard.string(forKey: "ETag")
            if let etag = tag {
                request.addValue(etag, forHTTPHeaderField: "If-None-Match")
            }
        }
        
        let task = decodingTask(with: request, decodingType: T.self) { (json , error) in
            
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
    
    func queryWithRandom<T: Decodable>(query: String, pageRequest: UnsplashPagedRequest, method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        var components = prepareURLComponents()
        
        components?.queryItems = [
            URLQueryItem(name: "query", value: query),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
            URLQueryItem(name: "orientation", value: "landscape"),
            URLQueryItem(name: "count", value: String(pageRequest.cursor.page))
        ]
        
        guard let url = components?.url else {
            return
        }
        
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        let task = decodingTask(with: mutableRequest, decodingType: T.self) { (json , error) in
            
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
    
    func query<T: Decodable>(pageRequest: UnsplashSearchPagedRequest, method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        let components = prepareURLComponents()
        
        guard let url = components?.url else {
            return
        }
        
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        let task = decodingTask(with: mutableRequest, decodingType: T.self) { (json , error) in
            
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
    
    func topic<T: Decodable>(id: String, pageRequest: UnsplashTopicRequest, method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        let urlString = "/topics/\(id)"
        
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
        components.path = urlString
        
        components.queryItems = [
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)
        ]
        
        guard let url = components.url else {
            return
        }
        
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        let task = decodingTask(with: mutableRequest, decodingType: T.self) { (json , error) in
            
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
    
    func topicPhotos<T: Decodable>(id: String, pageRequest: UnsplashTopicRequest, method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        let urlString = "/topics/\(id)/photos"
        
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
        components.path = urlString
        
        components.queryItems = [
            URLQueryItem(name: "per_page", value: String(pageRequest.cursor.perPage)),
            URLQueryItem(name: "page", value: String(pageRequest.cursor.page)),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)
        ]
        
        guard let url = components.url else {
            return
        }
        
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        let task = decodingTask(with: mutableRequest, decodingType: T.self) { (json , error) in
            
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
    
    func get_Collection<T: Decodable>(pageRequest: UnsplashCollectionRequest, method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        let components = prepareURLComponents()
        
        guard let url = components?.url else {
            return
        }
        
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        let task = decodingTask(with: mutableRequest, decodingType: T.self) { (json , error) in
            
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
    
    func listUserData<T: Decodable>(pageRequest: UnsplashUserListRequest, method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        let components = prepareURLComponents()
        
        guard let url = components?.url else {
            return
        }
        
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        let task = decodingTask(with: mutableRequest, decodingType: T.self) { (json , error) in
            
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
    
    func getPhotoInfo<T: Decodable>(id: String, pageRequest: UnsplashUserPhotoRequest, method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        let urlString = "/photos/\(id)/"
        
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
        components.path = urlString
        
        components.queryItems = [
            URLQueryItem(name: "per_page", value: String(pageRequest.cursor.perPage)),
            URLQueryItem(name: "page", value: String(pageRequest.cursor.page)),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey)
        ]
        
        guard let url = components.url else {
            return
        }
        
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        let task = decodingTask(with: mutableRequest, decodingType: T.self) { (json , error) in
            
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
    
    func getAlbum<T: Decodable>(query: String, pageRequest: UnsplashAlbumsRequest, method: RequestType, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
        let urlString = "/photos/random"
        
        var components = URLComponents()
        components.scheme = UnsplashAPI.scheme
        components.host = UnsplashAPI.host
        components.path = urlString
        
        components.queryItems = [
            URLQueryItem(name: "count", value: "10"),
            URLQueryItem(name: "per_page", value: String(pageRequest.cursor.perPage)),
            URLQueryItem(name: "page", value: String(pageRequest.cursor.page)),
            URLQueryItem(name: "client_id", value: UnsplashAPI.accessKey),
            URLQueryItem(name: "query", value: query),
        ]
        
        guard let url = components.url else {
            return
        }
        
        let mutableRequest = URLRequest(url: url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: timeoutInterval)
        
        let task = decodingTask(with: mutableRequest, decodingType: T.self) { (json , error) in
            
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
    
    func mock(pageRequest: UnsplashSearchPagedRequest, method: RequestType, completion: @escaping (APIResult<Data, Error>) -> Void) {
        
        let components = prepareURLComponents()
        
        guard let url = components?.url else {
            return
        }
       
        let task = session.dataTask(with: url) { data, _, error in
            
            if let data = data {
                let string = String(data: data, encoding: String.Encoding.utf8)
                print(string ?? "(no data)")
            }
            
            let result = data.map(APIResult.success) ?? .failure(error!)
            completion(result)
        }

        task.resume()
    }
   
    func createURLRequest(params: Dictionary<String, AnyObject>? = nil) throws -> URLRequest {
        
        
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
                    return mutableRequest
                case .urlEncoded:
                    var components = URLComponents(url: url, resolvingAgainstBaseURL: true)!
                    components.query = queryParameters(params)
                    return URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
                }
                
            case .path:
                guard let components = prepareURLComponents() else {
                    throw ServerError.invalidURL
                }
                
                return URLRequest(url: components.url!, cachePolicy: .reloadIgnoringLocalAndRemoteCacheData, timeoutInterval: timeoutInterval)
        }
    }
    
    func cancel() {
        task?.cancel()
    }
}

extension NetworkManager {
    private func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTaskProtocol? {
        
        let decoder = JSONDecoder()
        
        task = session.dataTask(with: request) { data, response, error in
            
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
                
//                guard let object = try? JSONSerialization.jsonObject(with: data, options: []),
//                let responeData = try? JSONSerialization.data(withJSONObject: object, options: [.prettyPrinted]),
//                let prettyPrintedString = NSString(data: responeData, encoding: String.Encoding.utf8.rawValue) else { return }
//                
//                print(prettyPrintedString)
                
                do {
                    let genericModel = try decoder.decode(decodingType, from: data)
                    completion(genericModel, nil)
                } catch(let error) {
                    completion(nil, ServerError.encounteredError(error))
                }
                
            } else if self.failureCodes.contains(httpResponse.statusCode) {
                if let data = data, let responseBody = try? JSONSerialization.jsonObject(with: data, options: []) {
                    debugPrint(responseBody)
                }
                completion(nil, ServerError.statusCodeError(httpResponse.statusCode))
            } else {
                // Server returned response with status code different than expected `successCodes`.
                let info = [
                    NSLocalizedDescriptionKey: "Request failed with code \(httpResponse.statusCode)",
                    NSLocalizedFailureReasonErrorKey: "Wrong handling logic, wrong endpoing mapping or backend bug."
                ]
                let error = NSError(domain: "NetworkService", code: httpResponse.statusCode, userInfo: info)
                completion(nil, ServerError.encounteredError(error))
            }
        }
        
        return task
    }

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
}

private extension Int {
    var megabytes: Int { return self * 1024 * 1024 }
}

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
