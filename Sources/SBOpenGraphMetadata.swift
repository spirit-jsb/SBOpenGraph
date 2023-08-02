//
//  SBOpenGraphMetadata.swift
//  SBOpenGraph
//
//  Created by JONO-Jsb on 2023/8/2.
//

#if canImport(Foundation)

import Foundation

/// https://ogp.me/
public enum SBOpenGraphMetadata: String {
    case title
    case type
    case image
    case url
    case audio
    case description
    case determiner
    case locale
    case localeAlternate = "locale: alternate"
    case siteName = "site_name"
    case video
    case imageURL = "image:url"
    case imageSecureURL = "image:secure_url"
    case imageType = "image:type"
    case imageWidth = "image:width"
    case imageHeight = "image:height"
    case imageAlt = "image:alt"
    case musicDuration = "music:duration"
    case musicAlbum = "music:album"
    case musicAlbumDisc = "music:album:disc"
    case musicAlbumTrack = "music:album:track"
    case musicMusician = "music:musician"
    case musicSong = "music:song"
    case musicSongDisc = "music:song:disc"
    case musicSongTrack = "music:song:track"
    case musicReleaseDate = "music:release_date"
    case musicCreator = "music:creator"
    case videoActor = "video:actor"
    case videoActorRole = "video:actor:role"
    case videoDirector = "video:director"
    case videoWriter = "video:writer"
    case videoDuration = "video:duration"
    case videoReleaseDate = "video:release_date"
    case videoTag = "video:tag"
    case videoSeries = "video:series"
    case articlePublishedTime = "article:published_time"
    case articleModifiedTime = "article:modified_time"
    case articleExpirationTime = "article:expiration_time"
    case articleAuthor = "article:author"
    case articleSection = "article:section"
    case articleTag = "article:tag"
    case bookAuthor = "book:author"
    case bookISBN = "book:isbn"
    case bookReleaseDate = "book:release_date"
    case bookTag = "book:tag"
    case profileFirstName = "profile:first_name"
    case profileLastName = "profile:last_name"
    case profileUsername = "profile:username"
    case profileGender = "profile:gender"
}

#endif
