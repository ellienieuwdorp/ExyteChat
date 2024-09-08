//
//  Created by Alex.M on 17.06.2022.
//

import Foundation

public class User: ObservableObject, Codable, Identifiable {
    private enum CodingKeys: CodingKey {
        case id
        case name
        case avatarURL
        case isCurrentUser
    }

    @Published public var id: String
    @Published public var name: String
    @Published public var avatarURL: URL?
    @Published public var isCurrentUser: Bool

    public init(id: String, name: String, avatarURL: URL?, isCurrentUser: Bool) {
        self.id = id
        self.name = name
        self.avatarURL = avatarURL
        self.isCurrentUser = isCurrentUser
    }
    
    required public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        id = try container.decode(String.self, forKey: .id)
        name = try container.decode(String.self, forKey: .name)
        avatarURL = try container.decode(URL?.self, forKey: .avatarURL)
        isCurrentUser = try container.decode(Bool.self, forKey: .isCurrentUser)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(id, forKey: .id)
        try container.encode(name, forKey: .name)
        try container.encode(avatarURL, forKey: .avatarURL)
        try container.encode(isCurrentUser, forKey: .isCurrentUser)
    }
}

extension User: Equatable {
    public static func == (lhs: User, rhs: User) -> Bool {
        lhs.id == rhs.id &&
        lhs.name == rhs.name &&
        lhs.avatarURL == rhs.avatarURL &&
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
