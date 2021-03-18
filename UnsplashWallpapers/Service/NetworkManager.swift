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

public enum RequestType: String {
    case get = "GET", post = "POST", put = "PUT", delete = "DELETE"
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
        }
    }
}

class NetworkManager {
    
    enum NetworkEndpoint {
        
        case random
        case search

        var url: URL {
            switch self {
            case .random:
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                  components.path = "/photos/random"
                
                components.queryItems = [
                  URLQueryItem(name: "count", value: "20"),
                  URLQueryItem(name: "client_id", value: UnsplashAPI.key)
                ]
                
                return components.url!
            case .search:
                var components = URLComponents()
                components.scheme = UnsplashAPI.scheme
                components.host = UnsplashAPI.host
                  components.path = "/search/photos"
                
                components.queryItems = [
                  URLQueryItem(name: "count", value: "20"),
                  URLQueryItem(name: "client_id", value: UnsplashAPI.key)
                ]
                
                return components.url!
            }
        }
    }
    
    typealias JSONTaskCompletionHandler = (Decodable?, ServerError?) -> Void

    private var session: URLSessionProtocol
    private var resourceURL: NetworkEndpoint

    init(resourceURL: NetworkEndpoint, withSession session: URLSessionProtocol = URLSession.shared) {
        self.session = session
        self.resourceURL = resourceURL
    }
    
    private func decodingTask<T: Decodable>(with request: URLRequest, decodingType: T.Type, completionHandler completion: @escaping JSONTaskCompletionHandler) -> URLSessionDataTaskProtocol {
        
        let decoder = JSONDecoder()
        
        let task = session.dataTask(with: request) { data, response, error in
            
            guard error == nil else {
                if let error = error {
                    completion(nil, ServerError.encounteredError(error))
                    return
                }
                return
            }
            
            guard let httpResponse = response as? HTTPURLResponse else {
                return
            }
            
            if httpResponse.statusCode == 200 {
                guard let data = data else {
                    completion(nil, ServerError.badData)
                    return
                }
                
                do {
                    let genericModel = try decoder.decode(decodingType, from: data)
                    completion(genericModel, nil)
                } catch(let error) {
                    completion(nil, ServerError.encounteredError(error))
                }
                
            } else {
                completion(nil, ServerError.statusCodeError(httpResponse.statusCode))
            }
        }
        return task
    }

    func fetch<T: Decodable>(with request: URLRequest, decode: @escaping (Decodable) -> T?, completion: @escaping (APIResult<T, ServerError>) -> Void) {
        
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
        task.resume()
    }
   
    func createURLRequest(method: RequestType, params: Dictionary<String, AnyObject>? = nil) -> NSMutableURLRequest {
       
        let request = NSMutableURLRequest(url: resourceURL.url, cachePolicy: .returnCacheDataElseLoad, timeoutInterval: 30.0)
        
        request.httpMethod = method.rawValue
        
        if let params = params {
            var paramString = ""
            for (key, value) in params {
                let escapedKey = key.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                let escapedValue = value.addingPercentEncoding(withAllowedCharacters: .urlQueryAllowed)
                paramString += "\(String(describing: escapedKey))=\(String(describing: escapedValue))&"
            }
            request.httpBody = paramString.data(using: String.Encoding.utf8)
        }
        request.addValue("application/json", forHTTPHeaderField: "Content-Type")
        
        if UserDefaults.standard.object(forKey: "ETag") != nil {
           let tag = UserDefaults.standard.string(forKey: "ETag")
           if let etag = tag {
               request.addValue(etag, forHTTPHeaderField: "If-None-Match")
           }
        }
        
        return request
    }
}
