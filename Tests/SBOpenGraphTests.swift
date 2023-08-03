//
//  SBOpenGraphTests.swift
//  SBOpenGraphTests
//
//  Created by JONO-Jsb on 2023/8/2.
//

import OHHTTPStubs
import OHHTTPStubsSwift
@testable import SBOpenGraph
import XCTest

final class SBOpenGraphTests: XCTestCase {
    override func setUp() {
        super.setUp()
    }

    override func tearDown() {
        super.tearDown()

        HTTPStubs.removeAllStubs()
    }

    func testFetch() {
        let responseArrived = self.expectation(description: "response of async request has arrived")

        self.setupStub(htmlFileName: "ogp")

        let url = URL(string: "https://www.example.com")!

        var og: SBOpenGraph?
        var error: Error?

        SBOpenGraph.fetch(url: url) { result in
            switch result {
                case let .success(_og):
                    og = _og
                case let .failure(_error):
                    error = _error
            }

            responseArrived.fulfill()
        }

        self.waitForExpectations(timeout: 10.0) { _ in
            XCTAssertEqual(og?[.title], " < It's example.com title > ")
            XCTAssertEqual(og?[.type], "website")
            XCTAssertEqual(og?[.image], "https://www.example.com/images/example.png")
            XCTAssertEqual(og?[.url], "https://www.example.com")
            XCTAssertEqual(og?[.description], "example.com description")
            XCTAssertEqual(og?[.imageType], "image/png")

            XCTAssertNil(error)
        }
    }

    @available(iOS 13.0, *)
    @MainActor
    func testFetchOfConcurrency() async {
        let responseArrived = self.expectation(description: "response of async request has arrived")

        self.setupStub(htmlFileName: "ogp")

        let url = URL(string: "https://www.example.com")!

        Task {
            var og: SBOpenGraph?
            var error: Error?

            do {
                og = try await SBOpenGraph.fetch(url: url)
            } catch let _error {
                error = _error
            }

            XCTAssertEqual(og?[.title], " < It's example.com title > ")
            XCTAssertEqual(og?[.type], "website")
            XCTAssertEqual(og?[.image], "https://www.example.com/images/example.png")
            XCTAssertEqual(og?[.url], "https://www.example.com")
            XCTAssertEqual(og?[.description], "example.com description")
            XCTAssertEqual(og?[.imageType], "image/png")

            XCTAssertNil(error)

            await MainActor.run {
                responseArrived.fulfill()
            }
        }

        await self.fulfillment(of: [responseArrived], timeout: 10.0)
    }

    func testFetchEmptyOGP() {
        let responseArrived = self.expectation(description: "response of async request has arrived")

        self.setupStub(htmlFileName: "empty_ogp")

        let url = URL(string: "https://www.example.com")!

        var og: SBOpenGraph?
        var error: Error?

        SBOpenGraph.fetch(url: url) { result in
            switch result {
                case let .success(_og):
                    og = _og
                case let .failure(_error):
                    error = _error
            }

            responseArrived.fulfill()
        }

        self.waitForExpectations(timeout: 10.0) { _ in
            XCTAssertNil(og?[.title])
            XCTAssertNil(og?[.type])
            XCTAssertNil(og?[.image])
            XCTAssertNil(og?[.url])
            XCTAssertNil(og?[.description])
            XCTAssertNil(og?[.imageType])

            XCTAssertNil(error)
        }
    }

    func testHTTPParseErrorResponseError() {
        let responseArrived = self.expectation(description: "response of async request has arrived")

        OHHTTPStubsSwift.stub { _ in
            true
        } response: { _ in
            HTTPStubsResponse(jsonObject: [:], statusCode: 404, headers: nil)
        }

        let url = URL(string: "https://www.example.com")!

        var og: SBOpenGraph?
        var error: Error?

        SBOpenGraph.fetch(url: url) { result in
            switch result {
                case let .success(_og):
                    og = _og
                case let .failure(_error):
                    error = _error
            }

            responseArrived.fulfill()
        }

        self.waitForExpectations(timeout: 10.0) { _ in
            XCTAssertNil(og)

            XCTAssertNotNil(error)
            XCTAssert(error! is SBOpenGraphError)

            var statusCode = 0
            switch error as! SBOpenGraphError {
                case let .unexpectedStatusCode(_statusCode):
                    statusCode = _statusCode
                default:
                    break
            }
            XCTAssertEqual(statusCode, 404)
        }
    }

    func testParseError() {
        let responseArrived = self.expectation(description: "response of async request has arrived")

        OHHTTPStubsSwift.stub { _ in
            true
        } response: { _ in
            HTTPStubsResponse(data: "にほんご".data(using: String.Encoding.shiftJIS)!, statusCode: 200, headers: nil)
        }

        let url = URL(string: "https://www.example.com")!

        var og: SBOpenGraph?
        var error: Error?

        SBOpenGraph.fetch(url: url) { result in
            switch result {
                case let .success(_og):
                    og = _og
                case let .failure(_error):
                    error = _error
            }

            responseArrived.fulfill()
        }

        self.waitForExpectations(timeout: 10.0) { _ in
            XCTAssertNil(og)

            XCTAssertNotNil(error)
            XCTAssert(error! is SBOpenGraphError)
            XCTAssertEqual(error as! SBOpenGraphError, SBOpenGraphError.encodingError)
        }
    }

    func testParsing() {
        var html = "<meta content=\"It's a description\" property=\"og:description\" />"
        XCTAssertEqual(SBOpenGraph(htmlString: html)[.description], "It's a description")

        html = "<meta property=\"og:title\" content=\"It's a title contains single quote\"/>"
        XCTAssertEqual(SBOpenGraph(htmlString: html)[.title], "It's a title contains single quote")

        html = "<meta content='It&#39;s a description' property='og:description' />"
        XCTAssertEqual(SBOpenGraph(htmlString: html)[.description], "It&#39;s a description")

        html = "<meta content='It is a title contains double quote \"' property='og:title' />"
        XCTAssertEqual(SBOpenGraph(htmlString: html)[.title], "It is a title contains double quote \"")
    }

    private func setupStub(htmlFileName: String) {
        OHHTTPStubsSwift.stub { _ in
            true
        } response: { _ in
            let path = Bundle(for: type(of: self)).path(forResource: htmlFileName, ofType: "html")!
            return HTTPStubsResponse(fileAtPath: path, statusCode: 200, headers: nil)
        }
    }
}

extension SBOpenGraphError: Equatable {
    public static func == (lhs: SBOpenGraphError, rhs: SBOpenGraphError) -> Bool {
        switch (lhs, rhs) {
            case (.unknown, .unknown), (.encodingError, .encodingError):
                return true
            case let (.unexpectedStatusCode(lhs), .unexpectedStatusCode(rhs)):
                return lhs == rhs
            default:
                return false
        }
    }
}
