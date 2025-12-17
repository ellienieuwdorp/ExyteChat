//
//  Created by Alex.M on 16.06.2022.
//

import Foundation
import ExyteMediaPicker

public enum AttachmentType: String, Codable, Sendable {
    case image
    case video

    public var title: String {
        switch self {
        case .image:
            return "Image"
        default:
            return "Video"
        }
    }

    public init(mediaType: MediaType) {
        switch mediaType {
        case .image:
            self = .image
        default:
            self = .video
        }
    }
}

public struct Attachment: Codable, Identifiable, Hashable, Sendable {
    public let id: String
    public let thumbnail: URL
    public let full: URL
    public let type: AttachmentType
    public let mimeType: String?
    public let thumbnailCacheKey: String?
    public let fullCacheKey: String?

    public init(id: String, thumbnail: URL, full: URL, type: AttachmentType, mimeType: String? = nil,
                thumbnailCacheKey: String? = nil, fullCacheKey: String? = nil) {
        self.id = id
        self.thumbnail = thumbnail
        self.full = full
        self.type = type
        self.mimeType = mimeType
        self.thumbnailCacheKey = thumbnailCacheKey
        self.fullCacheKey = fullCacheKey
    }

    public init(id: String, url: URL, type: AttachmentType, mimeType: String? = nil, cacheKey: String? = nil) {
        self.init(id: id, thumbnail: url, full: url, type: type, mimeType: mimeType, thumbnailCacheKey: cacheKey, fullCacheKey: cacheKey)
    }
    
    public func copy(
        id: String? = nil,
        thumbnail: URL? = nil,
        full: URL? = nil,
        type: AttachmentType? = nil,
        mimeType: String? = nil,
        thumbnailCacheKey: String? = nil,
        fullCacheKey: String? = nil
    ) -> Attachment {
        Attachment(
            id: id ?? self.id,
            thumbnail: thumbnail ?? self.thumbnail,
            full: full ?? self.full,
            type: type ?? self.type,
            mimeType: mimeType ?? self.mimeType,
            thumbnailCacheKey: thumbnailCacheKey ?? self.thumbnailCacheKey,
            fullCacheKey: fullCacheKey ?? self.fullCacheKey
        )
    }
}
