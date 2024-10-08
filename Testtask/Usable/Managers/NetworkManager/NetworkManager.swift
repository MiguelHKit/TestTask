//
//  NetworkManager.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation
import Combine

actor NetworkManager {
    //GENERAL CONFIGURATION
//    static nonisolated let IS_PRODUCTION: Bool = false
    static nonisolated let BASE_URL: String   = "https://frontend-test-assignment-api.abz.agency/api"
    static nonisolated let printLogs: Bool = false
    private init() { }
    
    public static func request(request req: NetworkRequest) async throws -> NetworkResponse {
        //URL
        let url: URL = try {
            var components = req.url.getComponents()
            guard components?.path.first == "/" else { throw NetworkError.URLPathHasNoSlash  }
            let queryItems = req.params
                .filter{ $0.on == .query }
                .map{
                    URLQueryItem(name: $0.name, value: $0.value)
                }
//            let authQueryItems =
            components?.queryItems = queryItems
            guard let finalUrl: URL = components?.url else { throw NetworkError.invalidURL }
            return finalUrl
        }()
        //
        var request = URLRequest(url: url)
        //Add Method
        request.httpMethod = req.method.rawValue
        //Add Body
        request.httpBody = try req.body.encodedAsData()
        //Add headers
        req.headers.forEach {
            request.addValue($0.getValue(), forHTTPHeaderField: $0.getKey())
        }
        // Configuration
        let configuration = URLSessionConfiguration.default
//        configuration.requestCachePolicy
        let session = URLSession(configuration: configuration)
        // MAKING THE RESQUEST
        let (data, rawResponse) = try await session.data(for: request)
        guard let response = rawResponse as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        //Printing Values
        if Self.printLogs {
            log("🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️[NEW SERVICE CALL]🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️")
            let responseDescription = """
                ⚔️[Method]: \(request.httpMethod ?? "UNKNOWN")
                ⚔️[Status]: \(response.statusCode)
                📡[URL]: \(request.url?.absoluteString ?? "INVALID URL")
                🛸[Request Headers]: \(String(describing: request.allHTTPHeaderFields))
                🛩️[RESPONSE]: \(getPrettyJSONString(data))
            """
            log(responseDescription)
        }
        //
        return NetworkResponse(
            status: response.statusCode,
            time: 1,
            size: rawResponse.expectedContentLength,
            data: data
        )
    }
    /// Make a request using a NetwortRequest and returning a Codable Model
    /// - Parameter req: NetworkRequest
    /// - Returns: Codable Model
    public static func request<T: Codable>(request req: NetworkRequest) async throws -> T {
        let response = try await NetworkManager.request(request: req)
        //Decoding
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let dataDecoded = try? jsonDecoder.decode(T.self, from: response.data) else { throw NetworkError.decodingError }
        return dataDecoded
    }
    /// Upload a multipartRequest using form data in order to send files,
    /// the header for multipart/formadata is already setted, no need to added
    /// - Parameters:
    ///   - url: NetworkRequest.NetworkURL
    ///   - params: Array of NetworkRequest.NetworkParameter
    ///   - receivedHeaders: NetworkRequest.NetworkHeader]
    ///   - formData: Array of NetworkRequest.NetworkBody.FormData
    ///   - autorization: NetworkRequest.NetworkAutorization
    /// - Returns: Codable model
    public static func multipartRequest<T: Codable>(url: NetworkRequest.NetworkURL, params: [NetworkRequest.NetworkParameter] = [], headers receivedHeaders: [NetworkRequest.NetworkHTTPHeader] = [], formData: [NetworkRequest.NetworkHTTPBody.FormData],autorization: NetworkRequest.NetworkAutorization = .none) async throws -> T {
        let boundary = UUID().uuidString
        var headers = receivedHeaders
        headers.append(.contentType(value: "multipart/form-data; boundary=\(boundary)"))
        return try await self.request(
            request: .init(
                url: url,
                method: .post,
                params: params,
                authorization: autorization,
                headers: headers,
                body: .formData(
                    boundary: boundary,
                    params: formData
                )
            )
        )
    }
}
