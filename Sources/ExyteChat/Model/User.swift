//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

public enum UserType: Int, Codable, Sendable {
    case current = 0, other, system
}

open class User: ObservableObject, Codable, Identifiable {
    public enum CodingKeys: CodingKey {
        case id
        case name
        case avatarURL
        case avatarData
        case type
    }

    @Published public var id: String
    @Published open var name: String
    @Published open var avatarURL: URL?
    @Published open var avatarData: Data?
    open let type: UserType
    open var isCurrentUser: Bool { type == .current }

    public init(id: String, name: String, avatarURL: URL? = nil, avatarData: Data? = nil, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.avatarData = avatarData
        self.type = isCurrentUser ? .current : .other
    }

    public init(id: String, name: String, avatarURL: URL? = nil, avatarData: Data? = nil, type: UserType) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.avatarData = avatarData
        self.type = type
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        avatarURL = try container.decode(URL?.self, forKey: .avatarURL)
        avatarData = try container.decode(Data?.self, forKey: .avatarData)
        type = try container.decode(UserType.self, forKey: .type)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(avatarURL, forKey: .avatarURL)
        try container.encode(avatarData, forKey: .avatarData)
        try container.encode(type, forKey: .type)
    }
}

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.avatarURL == rhs.avatarURL &&
        lhs.avatarData == rhs.avatarData &&
        lhs.isCurrentUser == rhs.isCurrentUser
    }
}

extension User: Hashable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(self.id)
        hasher.combine(self.name)
        hasher.combine(self.isCurrentUser)
    }
}
