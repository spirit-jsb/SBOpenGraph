//
//  SBOpenGraph.swift
//  SBOpenGraph
//
//  Created by JONO-Jsb on 2023/8/2.
//

#if canImport(Foundation)

import Foundation

public struct SBOpenGraph {
    private let source: [SBOpenGraphMetadata: String]

    #if compiler(>=5.5.2) && canImport(_Concurrency)
    @available(iOS 13.0, *)
    public static func fetch(url: URL?, headers: [String: String]? = nil) async throws -> SBOpenGraph {
        return try await withCheckedThrowingContinuation { continuation in
            self.fetch(url: url, headers: headers) { result in
                switch result {
                    case let .success(successResult):
                        continuation.resume(returning: successResult)
                    case let .failure(failureError):
                        continuation.resume(throwing: failureError)
                }
            }
        }
    }

    #elseif compiler(>=5.5) && canImport(_Concurrency)
    @available(iOS 15.0, *)
    public static func fetch(url: URL?, headers: [String: String]? = nil) async throws -> SBOpenGraph {
        return try await withCheckedThrowingContinuation { continuation in
            self.fetch(url: url, headers: headers) { result in
                switch result {
                    case let .success(successResult):
                        continuation.resume(returning: successResult)
                    case let .failure(failureError):
                        continuation.resume(throwing: failureError)
                }
            }
        }
    }
    #endif

    public static func fetch(url: URL, headers: [String: String]? = nil, completion: @escaping (Swift.Result<SBOpenGraph, Error>) -> Void) -> URLSessionDataTask {
        let urlSession = URLSession(configuration: .default)

        var urlRequest = URLRequest(url: url)
        if let headers = headers {
            headers.forEach {
                urlRequest.setValue($1, forHTTPHeaderField: $0)
            }
        }

        let task = urlSession.dataTask(with: urlRequest) { data, urlResponse, error in
            if let error = error {
                completion(.failure(error))
            } else {
                guard let data = data, let urlResponse = urlResponse as? HTTPURLResponse else {
                    completion(.failure(SBOpenGraphError.unknown))
                    return
                }

                if !(200 ..< 300).contains(urlResponse.statusCode) {
                    completion(.failure(SBOpenGraphError.unexpectedStatusCode(urlResponse.statusCode)))
                } else {
                    guard let htmlString = String(data: data, encoding: .utf8) else {
                        completion(.failure(SBOpenGraphError.encodingError))
                        return
                    }

                    let og = SBOpenGraph(htmlString: htmlString)

                    completion(.success(og))
                }
            }
        }

        task.resume()

        return task
    }

    public init(htmlString: String) {
        self.source = SBOpenGraphParser.parser(htmlString: htmlString)
    }

    public subscript(attributeName: SBOpenGraphMetadata) -> String? {
        return self.source[attributeName]
    }
}

#endif
