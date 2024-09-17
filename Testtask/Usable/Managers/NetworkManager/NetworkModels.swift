//
//  NetworkModels.swift
//  Testtask
//
//  Created by Miguel T on 16/09/24.
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
    case custom(message: String)
//    case noModelDefined
}

public typealias Parameters = [String: Any]

struct NetworkResponse {
    let status: Int
    let time: Int
    let size: Int64
    let data: Data
    //    let cookies:
    //    let headers:
    let description: String
}
