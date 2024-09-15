//
//  NetworkManager.swift
//  Testtask
//
//  Created by Miguel T on 12/09/24.
//

import Foundation

enum NetworkError: Error {
    case badResponse
    case invalidURLPath
    case invalidResponse
    case urlDoesntExist
    case encodingBodyError
    case decodingError
    case dataError
    case invalidParameters
    case authorizationError
//    case noModelDefined
}

protocol NetworkEnumProtocol {
    func getTitle() -> String
}
typealias KeyValueTuple = (key: String, value: String)
public typealias Parameters = [String: Any]
public typealias FormDataParameters = [String: ValidFormDataTypes]
public protocol ValidFormDataTypes {}

struct NetworkParameter {
    let name: String
    let value: String
    let on: Self.parameterType
    enum parameterType {
        case query
        case requestBody
    }
}

struct NetworkRequest {
    let url: NetworkURL
    let method: Self.NetworkHTTPMethod
    var params: [NetworkParameter] = []
    var authorization: Self.NetworkHTTPAutorization = .none
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
        
        func getComponents() -> URLComponents {
            var components = URLComponents()
            components.host = baseURL
            components.path = "\(version.rawValue)/\(path)"
            return components
        }
    }
    //MARK: - Method
    enum NetworkHTTPMethod: String, Hashable, CaseIterable, NetworkEnumProtocol {
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
    //MARK: - Authorization
    enum NetworkHTTPAutorizationSelectable: Hashable, CaseIterable, NetworkEnumProtocol {
        case none
        case apiKey
        case bearerToken
        case jwtBearerToken
        case basicAuth
        case degestAuth
        case OAuth1
        case OAuth2
        case hawkAuth
        case awsSignature
        
        func getTitle() -> String {
            switch self {
            case .none: "none"
            case .apiKey: "API Key"
            case .bearerToken: "bearerToken"
            case .jwtBearerToken: "jwtBearerToken"
            case .basicAuth: "Basic Auth"
            case .degestAuth: "degestAuth"
            case .OAuth1: "OAuth1"
            case .OAuth2: "OAuth2"
            case .hawkAuth: "hawkAuth"
            case .awsSignature: "awsSignature"
            }
        }
    }
    struct NetworkHTTPAutorizationValues: Hashable {
        var none: String = ""
        var apiKey_Key: String = ""
        var apiKey_Value: String = ""
        var apiKey_AddTo: NetworkHTTPAutorization.AddTo = .header
        var bearerToken: String = ""
        var jwtBearerToken: String = ""
        var basicAuth: String = ""
        var degestAuth: String = ""
        var OAuth1: String = ""
        var OAuth2: String = ""
        var hawkAuth: String = ""
        var awsSignature: String = ""
    }
    enum NetworkHTTPAutorization {
        case none
        case apiKey(key: String, value: String)
        case apiKey(key: String, value: String, addTo: Self.AddTo)
        case bearerToken(token: String)
//        case jwtBearerToken(algorithm: JWTAlgorithm, secret: String, payload: String) //soon
//        case jwtBearerToken(algorithm: JWTAlgorithm, secret: String, payload: String, addTo: Self.AddTo) //soon
        case basicAuth(username: String, password: String)
//        case degestAuth //soon
        case OAuth1(signatureMethod: Self.SignatureMethod, consumerKey: String, consumerSecret: String, accessToken: String, accessSecret: String)
//        case OAuth2() //soon
        case hawkAuth(authId: String, authKey: String, algorihm: Self.Algorithm)
        case awsSignature(accessKey: String, secretKey: String)
        
        enum AddTo: Hashable, CaseIterable, NetworkEnumProtocol {
            case header
            case queryParams
            
            var allCases: [AddTo] { Self.allCases }
            func getTitle() -> String {
                switch self {
                case .header: "Header"
                case .queryParams: "query Params"
                }
            }
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
        static func getAllCases() -> [String] {
            [
                "none",
                "API Key",
                "Bearer Token",
                "Basic Auth",
                "OAuth1",
                "nawk Auth",
                "awsSignature"
            ]
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
                return Data()
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
//                return Data()
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
    public var printLogs: Bool = false
    //GENERAL CONFIGURATION
    static let IS_PRODUCTION: Bool = false
    static let BASE_URL: String   = "https://frontend-test-assignment-api.abz.agency/api"
    private init() { }
    
    public static func request(request req: NetworkRequest) async throws -> NetworkResponse {
        //URL
        let urlCalculation: URL? = {
            var components = req.url.getComponents()
            guard req.params.isNotEmpty else { return components.url }
            components.queryItems = req.params.map({ (key: String, value: String) in
                URLQueryItem(name: key, value: value)
            })
            return components.url
        }()
        //
        guard let url: URL = urlCalculation else { throw NetworkError.invalidURLPath }
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
        let (data, response) = try await session.data(for: request)
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        //Printing Values
//        🛸[Request]: \(request.urlRequest?.debugDescription ?? "")
        let responseDescription = """
            ⚔️[Method]: \(request.httpMethod ?? "UNKNOWN")
            📡[URL]: \(request.url?.absoluteString ?? "INVALID URL")
            🛸[Headers]: \(String(describing: request.allHTTPHeaderFields))
            🛩️[RESPONSE]: \(getPrettyJSONString(data))
        """
        if Self.instance.printLogs {
            log("🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️[NEW REQUEST]🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️🛰️")
            log(responseDescription)
        }
        //
        return NetworkResponse(
            status: httpResponse.statusCode,
            time: 1,
            size: 1,
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
