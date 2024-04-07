//
//  NetworkManager.swift
//  iOS_assignment
//
//  Created by Yasir Khan on 05/04/2024.
//

import Foundation
import UIKit

enum ErrorResponse : String {
    case invalidData
    case apiError
    case invalidEndpoint
    case internet
    case none
    public var description : String {
        switch self {
        case .invalidData: return "Invalid data response"
        case .apiError: return "Api error"
        case .invalidEndpoint: return "Invalid API end point"
        case .internet: return "No internet connection"
        default: return ""
        }
    }
}

struct NetworkError : Error {
    let message : ErrorResponse
}

protocol NetworkService {
    func getRequest<Request : DataRequest>(_ request : Request, completion: @escaping (Result<Request.Response,NetworkError>) -> Void)
    func postRequest<Request : DataRequest>(_ request : Request, completion: @escaping (Result<Request.Response,NetworkError>) -> Void)
}

extension NetworkService {
    func postRequest<Request : DataRequest>(_ request : Request, completion: @escaping (Result<Request.Response,NetworkError>) -> Void) {}
}

final class NetworkManager : NetworkService {
    
    /// Get Requestion function which takes Request as a parameter & Returns Required Response or Error
    func getRequest<Request>(_ request: Request, completion: @escaping (Result<Request.Response, NetworkError>) -> Void) where Request : DataRequest {
        if !InternetConnectionManager.isConnectedToNetwork() {
            return completion(.failure(NetworkError(message: .internet)))
        }
        guard var urlComponent = URLComponents(string: request.url) else {
            return completion(.failure(NetworkError(message: .invalidEndpoint)))
        }
        var queryItems: [URLQueryItem] = []
        if request.queryItems.count > 0 {
            request.queryItems.forEach {
                let urlQueryItem = URLQueryItem(name: $0.key, value: $0.value as? String)
                urlComponent.queryItems?.append(urlQueryItem)
                queryItems.append(urlQueryItem)
            }
            urlComponent.queryItems = queryItems
            
        }
        guard let url = URL(string: request.url) else {
            return completion(.failure(NetworkError(message: .invalidEndpoint)))
        }
        
        var urlRequest = URLRequest(url: url)
        urlRequest.httpMethod = request.method.rawValue
        urlRequest.allHTTPHeaderFields = request.headers
        
        URLSession.shared.dataTask(with: urlRequest) { (data, response, error) in
            if error != nil {
                return completion(.failure(NetworkError(message: .invalidData)))
            }
            guard let data = data else {
                return completion(.failure(NetworkError(message: .invalidData)))
            }
            
            do {
                try completion(.success(request.decode(data)))
            } catch let err as NSError {
                print(err)
                return completion(.failure(NetworkError(message: .invalidData)))
            }
        }
        .resume()
        
    }
 
}
