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

    public static func fetch(url: URL?, headers: [String: String]? = nil, completion: @escaping (Swift.Result<SBOpenGraph, Error>) -> Void) {
        fatalError("parse(url:completion:) has not been implemented")
    }

        }

    public init(htmlString: String) {
        self.source = SBOpenGraphParser.parser(htmlString: htmlString)
    }

    public subscript(attributeName: SBOpenGraphMetadata) -> String? {
        return self.source[attributeName]
    }
}

#endif
