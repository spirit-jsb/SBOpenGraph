//
//  SBOpenGraph.swift
//
//  Created by Max on 2023/10/2
//
//  Copyright © 2023 Max. All rights reserved.
//

#if canImport(Foundation)

import Foundation

public struct SBOpenGraph {
    private let source: [SBOpenGraphMetadata: String]

    #if compiler(>=5.5.2) && canImport(_Concurrency)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    public static func fetch(url: URL, headers: [String: String]? = nil) async throws -> SBOpenGraph {
        let fetchRequest = FetchRequestWrap(url: url, headers: headers)

        return try await withTaskCancellationHandler(operation: {
            try await withCheckedThrowingContinuation { continuation in
                Task {
                    await fetchRequest.start { result in
                        switch result {
                            case let .success(successResult):
                                continuation.resume(returning: successResult)
                            case let .failure(failureError):
                                continuation.resume(throwing: failureError)
                        }
                    }
                }
            }
        }, onCancel: {
            Task {
                await fetchRequest.cancel()
            }
        })
    }
    #endif

    @discardableResult
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

private extension SBOpenGraph {
    #if compiler(>=5.5.2) && canImport(_Concurrency)
    @available(macOS 10.15, iOS 13.0, tvOS 13.0, watchOS 6.0, *)
    actor FetchRequestWrap {
        let url: URL
        let headers: [String: String]?

        var task: URLSessionTask?

        init(url: URL, headers: [String: String]?) {
            self.url = url
            self.headers = headers
        }

        func start(completion: @Sendable @escaping (Swift.Result<SBOpenGraph, Error>) -> Void) {
            self.task = SBOpenGraph.fetch(url: self.url, headers: self.headers, completion: completion)
        }

        func cancel() {
            self.task?.cancel()
        }
    }
    #endif
}

#endif
