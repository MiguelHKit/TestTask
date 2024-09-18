//
//  NetworkManager.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
//

import Foundation

final class NetworkManager {
    private static let instance = NetworkManager()
    //GENERAL CONFIGURATION
    static let IS_PRODUCTION: Bool = false
    static let BASE_URL: String   = "https://frontend-test-assignment-api.abz.agency/api"
//    public var printLogs: Bool = false
    public var printLogs: Bool = true
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
        let session = URLSession(configuration: configuration)
        // MAKING THE RESQUEST
        let (data, rawResponse) = try await session.data(for: request)
        guard let response = rawResponse as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        //Printing Values
        let responseDescription = """
            ⚔️[Method]: \(request.httpMethod ?? "UNKNOWN")
            ⚔️[Status]: \(response.statusCode)
            📡[URL]: \(request.url?.absoluteString ?? "INVALID URL")
            🛸[Request Headers]: \(String(describing: request.allHTTPHeaderFields))
            🛩️[RESPONSE]: \(getPrettyJSONString(data))
        """
        if Self.instance.printLogs {
            log("🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️[NEW SERVICE CALL]🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️")
            log(responseDescription)
        }
        //
        return NetworkResponse(
            status: response.statusCode,
            time: 1,
            size: rawResponse.expectedContentLength,
            data: data,
            description: responseDescription
        )
    }
    //
    public static func request<T: Codable>(request req: NetworkRequest) async throws -> T {
        let response = try await NetworkManager.request(request: req)
        //Decoding
        let jsonDecoder = JSONDecoder()
        jsonDecoder.keyDecodingStrategy = .convertFromSnakeCase
        guard let dataDecoded = try? jsonDecoder.decode(T.self, from: response.data) else { throw NetworkError.decodingError }
        return dataDecoded
    }
    public static func multipartRequest<T: Codable>(url: NetworkRequest.NetworkURL, formData: [NetworkRequest.NetworkHTTPBody.FormData],autorization: NetworkRequest.NetworkAutorization = .none) async throws -> T {
        let boundary = UUID().uuidString
        return try await self.request(
            request: .init(
                url: url,
                method: .post,
                params: [],
                authorization: autorization,
                headers: [
                    .contentType(value: "multipart/form-data; boundary=\(boundary)")
                ],
                body: .formData(
                    boundary: boundary,
                    params: formData
                )
            )
        )
    }
}
