//
//  SBOpenGraphParser.swift
//  SBOpenGraph
//
//  Created by JONO-Jsb on 2023/8/2.
//

#if canImport(Foundation)

import Foundation

struct SBOpenGraphParser {
    static func parser(htmlString: String) -> [SBOpenGraphMetadata: String] {
        // 提取 meta 标签的正则表达式
        let metaTagRegex = try! NSRegularExpression(pattern: #"<meta(?:".*?"|'.*?'|[^'"])*?>"#, options: [.dotMatchesLineSeparators])
        // 提取 meta 标签
        let metaTagResults = metaTagRegex.matches(in: htmlString, options: [], range: NSRange(location: 0, length: htmlString.count))

        // 如果 meta 标签不存在, 则返回空字典
        guard !metaTagResults.isEmpty else {
            return [:]
        }

        // 提取 property & content 标签的正则表达式
        let propertyRegex = try! NSRegularExpression(pattern: #"\sproperty=(?:"|')og:([a-zA-Z:]+)(?:"|')"#, options: [])
        let contentRegex = try! NSRegularExpression(pattern: #"\scontent=(?:"|')(.*?)(?:"|')"#, options: [])

        let parseResults = metaTagResults.reduce([SBOpenGraphMetadata: String]()) { partialResult, metaTagResult in
            var result = partialResult

            let openGraphResult = { () -> (property: String, content: String)? in
                guard let metaTagRange = Range(metaTagResult.range(at: 0), in: htmlString) else {
                    return nil
                }

                let metaTag = String(htmlString[metaTagRange])

                // 提取 property 标签 range
                let propertyResults = propertyRegex.matches(in: metaTag, options: [], range: NSRange(location: 0, length: metaTag.count))
                guard let firstPropertyResult = propertyResults.first, let propertyRange = Range(firstPropertyResult.range(at: 1), in: metaTag) else {
                    return nil
                }

                // 提取 content 标签 range
                let contentResults = contentRegex.matches(in: metaTag, options: [], range: NSRange(location: 0, length: metaTag.count))
                guard let firstContentResults = contentResults.first, let contentRange = Range(firstContentResults.range(at: 1), in: metaTag) else {
                    return nil
                }

                let property = String(metaTag[propertyRange])
                let content = String(metaTag[contentRange])

                return (property: property, content: content)
            }()

            if let openGraphResult = openGraphResult, let openGraphMetadata = SBOpenGraphMetadata(rawValue: openGraphResult.property) {
                result[openGraphMetadata] = openGraphResult.content
            }

            return result
        }

        return parseResults
    }
}

#endif
