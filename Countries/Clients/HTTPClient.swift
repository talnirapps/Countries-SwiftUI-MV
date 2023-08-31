//
//  HTTPClient.swift
//  Countries
//
//  Created by Tal Nir on 2023-08-28.
//

// TOTO: Use Repository

import Foundation

enum NetworkError: Error, Equatable {
    static func == (lhs: NetworkError, rhs: NetworkError) -> Bool {
        lhs.localizedDescription == rhs.localizedDescription
    }
    
    case badRequest
    case serverError(String)
    case decodingError(Error)
    case invalidResponse
    case invalidURL
    case httpError(Int)
}

extension NetworkError: LocalizedError {
    
    var errorDescription: String? {
        switch self {
        case .badRequest:
            return NSLocalizedString("Unable to perform request", comment: "badRequestError")
        case .serverError(let errorMessage):
            return NSLocalizedString(errorMessage, comment: "serverError")
        case .decodingError(let error):
            return NSLocalizedString("Unable to decode successfully. \(error)", comment: "decodingError")
        case .invalidResponse:
            return NSLocalizedString("Invalid response", comment: "invalidResponse")
        case .invalidURL:
            return NSLocalizedString("Invalid URL", comment: "invalidURL")
        case .httpError(_):
            return NSLocalizedString("Bad request", comment: "badRequest")
        }
    }
    
}

enum HTTPMethod {
    case get([URLQueryItem])
    case post(Data?)
    case delete
    
    var name: String {
        switch self {
        case .get:
            return "GET"
        case .post:
            return "POST"
        case .delete:
            return "DELETE"
        }
    }
}

struct Resource<T: Codable> {
    let url: URL
    var method: HTTPMethod = .get([])
    var modelType: T.Type
}

struct DataResource {
    let url: URL
    var method: HTTPMethod = .get([])
}

protocol HTTPClient {
    func load<T: Codable>(_ resource: Resource<T>) async throws -> T
    func loadData(_ resource: DataResource) async throws -> Data
}


struct RealHTTPClient: HTTPClient {
    private let session: URLSession
    
    init(session: URLSession? = nil) {
        if let session = session {
            self.session = session
        } else {
            let configuration = URLSessionConfiguration.default
            configuration.httpAdditionalHeaders = ["Accept": "application/json"]
            self.session = URLSession(configuration: configuration)
        }
    }
    
    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
        let dataResource = DataResource(url: resource.url)
        let data = try await loadData(dataResource)
        
        do {
            let result = try JSONDecoder().decode(resource.modelType, from: data)
            return result
        } catch {
            throw NetworkError.decodingError(error)
        }
    }
    
    func loadData(_ resource: DataResource) async throws -> Data {
        var request = URLRequest(url: resource.url)
        request.httpMethod = resource.method.name
        
        switch resource.method {
        case .get(let queryItems):
            if !queryItems.isEmpty {
                var components = URLComponents(url: resource.url, resolvingAgainstBaseURL: false)
                components?.queryItems = queryItems
                if let url = components?.url {
                    request.url = url
                }
            }
            
        case .post(let data):
            request.httpBody = data
            
        case .delete:
            break
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        guard (200..<300).contains(httpResponse.statusCode) else {
            throw NetworkError.httpError(httpResponse.statusCode)
        }
        
        return data
    }
}


#if DEBUG
class MockHTTPClient: HTTPClient {
    
    // This dictionary will store URL and Data pairs to return mocked responses
    private var mockedResponses: [URL: Data] = [:]
    
    // When initializing the MockHTTPClient, we can specify which URLs should return which mock data
    init(mockedResponses: [URL: Data]) {
        self.mockedResponses = mockedResponses
    }
    
    func load<T: Codable>(_ resource: Resource<T>) async throws -> T {
        if let mockedData = mockedResponses[resource.url] {
            do {
                let result = try JSONDecoder().decode(resource.modelType, from: mockedData)
                return result
            } catch {
                throw NetworkError.decodingError(error)
            }
        }
        throw NetworkError.badRequest
    }
    
    func loadData(_ resource: DataResource) async throws -> Data {
        if let mockedData = mockedResponses[resource.url] {
            return mockedData
        }
        throw NetworkError.badRequest
    }
}
#endif
