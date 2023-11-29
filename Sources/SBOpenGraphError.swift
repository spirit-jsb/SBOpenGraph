//
//  SBOpenGraphError.swift
//
//  Created by Max on 2023/10/2
//
//  Copyright © 2023 Max. All rights reserved.
//

#if canImport(Foundation)

import Foundation

public enum SBOpenGraphError: Error {
    case unknown
    case unexpectedStatusCode(Int)
    case encodingError
}

#endif
