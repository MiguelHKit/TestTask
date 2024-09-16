//
//  NetworkManager.swift
//  Testtask
//
//  Created by Miguel T on 12/09/24.
//

import Foundation

enum NetworkError: Error {
    case badResponse
    case invalidURL
    case invalidResponse
    case urlDoesntExist
    case encodingBodyError
    case decodingError
    case dataError
    case invalidParameters
    case authorizationError
    case URLPathHasNoSlash
//    case noModelDefined
}

protocol NetworkEnumProtocol {
    func getTitle() -> String
}
typealias KeyValueTuple = (key: String, value: String)
public typealias Parameters = [String: Any]
public typealias FormDataParameters = [String: ValidFormDataTypes]
public protocol ValidFormDataTypes {}

struct NetworkRequest {
    let url: NetworkURL
    let method: Self.NetworkMethod
    var params: [Self.NetworkParameter] = []
    var authorization: Self.NetworkAutorization = .none
    var headers: [NetworkHTTPHeader] = []
    var body: Self.NetworkHTTPBody = .none
    //MARK: - URL
    struct NetworkURL {
        // FORMAT: baseURL/version/path
        // EXAMPLE: https://myapi.com/api + /v2 + /getUsers
        enum Version: String {
            case v1 = "v1"
        }
        let baseURL: String
        let version: Self.Version
        let path: String
        
        func getComponents() -> URLComponents? {
            var components = URLComponents(string: baseURL)
            let previousPath = components?.path ?? ""
            components?.path = previousPath + "/\(version.rawValue)/\(path)"
            return components
        }
    }
    //MARK: - Method
    enum NetworkMethod: String, Hashable, CaseIterable, NetworkEnumProtocol {
        case get
        case post
        case put
        case patch
        case delete
        case head
        case options
        
        var stringValue: String {
            switch self {
            case .get: "GET"
            case .post: "POST"
            case .put: "PUT"
            case .patch: "PATCH"
            case .delete: "DELETE"
            case .head: "HEAD"
            case .options: "OPTIONS"
            }
        }
        func getTitle() -> String {
            self.stringValue
        }
    }
    //MARK: - Parameters
    struct NetworkParameter {
        let name: String
        let value: String
        let on: Self.parameterType
        enum parameterType {
            case query
            case requestBody
        }
    }
    //MARK: - Authorization
    enum NetworkAutorization {
        case none
        case apiKey(key: String, value: String)
        case apiKeyAddTo(key: String, value: String, addTo: Self.AddTo)
        case bearerToken(token: String)
//        case jwtBearerToken(algorithm: JWTAlgorithm, secret: String, payload: String) //soon
//        case jwtBearerToken(algorithm: JWTAlgorithm, secret: String, payload: String, addTo: Self.AddTo) //soon
        case basicAuth(username: String, password: String)
//        case degestAuth //soon
        case OAuth1(signatureMethod: Self.SignatureMethod, consumerKey: String, consumerSecret: String, accessToken: String, accessSecret: String)
//        case OAuth2() //soon
        case hawkAuth(authId: String, authKey: String, algorihm: Self.Algorithm)
        case awsSignature(accessKey: String, secretKey: String)
        
        func getTitle() -> String {
            switch self {
            case .none: "none"
            case .apiKey: "API Key"
            case .apiKeyAddTo: "API Key"
            case .bearerToken: "bearerToken"
//            case .jwtBearerToken: "jwtBearerToken"
            case .basicAuth: "Basic Auth"
//            case .degestAuth: "degestAuth"
            case .OAuth1: "OAuth1"
//            case .OAuth2: "OAuth2"
            case .hawkAuth: "hawkAuth"
            case .awsSignature: "awsSignature"
            }
        }
        
        enum AddTo {
            case header
            case queryParams
        }
        
        enum Algorithm {
            case sha1
            case sha256
        }
        
        enum SignatureMethod {
            case HMAC_SHA1
            case HMAC_SHA256
        }
        
        enum JWTAlgorithm {
            case HS256
            case HS384
        }
    }
    //MARK: - Body
    enum NetworkHTTPBody {
        case none
        case raw(params: Parameters)
        case formData(params: FormDataParameters)
        case x_www_form_urlencoded(params: [String: Any])
        case binary(data: Data)
        case graphQL(query: String, variables: String)
        
        func encodedAsData() throws -> Data? {
            switch self {
            case .none:
                return nil
            case .raw(let params):
                do {
                    let jsonData = try JSONSerialization.data(withJSONObject: params)
                    return jsonData
                } catch {
                    throw NetworkError.encodingBodyError
                }
            case .formData(let params):
                var httpBody = NSMutableData()
                
                try params.forEach { key, value in
                    if let actualValue = value as? String {
                        
                    }
                    else if let actualValue = value as? Data {
                        
                    }
                    else {
                        throw NetworkError.invalidParameters
                    }
                }
                return Data()
            case .x_www_form_urlencoded:
                return Data()
            case .binary:
                return Data()
            case .graphQL:
                return Data()
            }
        }
        
        private func decodeFromAny() {
            
        }
    }
    enum NetworkHTTPHeader {
        case authorization(value: String)
        case accept(value: String)
        case userAgent(value: String)
        case contentType(value: String)
        case contentLength(value: String)
        case custom(key: String,value: String)
        
        func getKey() -> String {
            switch self {
            case .authorization: "Authorization"
            case .accept: "Accept"
            case .userAgent: "User-Agent"
            case .contentType: "Content-Type"
            case .contentLength: "Content-Length"
            case .custom(let key, _): key
            }
        }
        func getValue() -> String {
            switch self {
            case .authorization(let value): value
            case .accept(let value): value
            case .userAgent(let value): value
            case .contentType(let value): value
            case .contentLength(let value): value
            case .custom(_,let value): value
            }
        }
    }
}

struct NetworkResponse {
    let status: Int
    let time: Int
    let size: Int64
    let data: Data
    //    let cookies:
    //    let headers:
    let description: String
}

final class NetworkManager {
    private static let instance = NetworkManager()
    public var printLogs: Bool = true
    //GENERAL CONFIGURATION
    static let IS_PRODUCTION: Bool = false
    static let BASE_URL: String   = "https://frontend-test-assignment-api.abz.agency/api"
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
        guard let dataDecoded = try? jsonDecoder.decode(T.self, from: response.data) else { throw NetworkError.decodingError }
        return dataDecoded
    }
}
