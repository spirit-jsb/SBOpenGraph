//
//  SBOpenGraphError.swift
//  SBOpenGraph
//
//  Created by JONO-Jsb on 2023/8/3.
//

#if canImport(Foundation)

import Foundation

public enum SBOpenGraphError: Error {
    case unknown
    case unexpectedStatusCode(Int)
    case encodingError
}

#endif
