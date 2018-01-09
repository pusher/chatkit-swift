import Foundation
import PusherPlatform

struct PCPayloadDeserializer {
    static func createUserFromPayload(_ userPayload: [String: Any]) throws -> PCUser {
        let basicUser = try createBasicUserFromPayload(userPayload)

        return PCUser(
            id: basicUser.id,
            createdAt: basicUser.createdAt,
            updatedAt: basicUser.updatedAt,
            name: userPayload["name"] as? String,
            avatarURL: userPayload["avatar_url"] as? String,
            customData: userPayload["custom_data"] as? [String: Any]
        )
    }

    static func createCurrentUserFromPayload(_ userPayload: [String: Any], instance: Instance, userStore: PCGlobalUserStore) throws -> PCCurrentUser {
        let basicUser = try createBasicUserFromPayload(userPayload)

        return PCCurrentUser(
            id: basicUser.id,
            createdAt: basicUser.createdAt,
            updatedAt: basicUser.updatedAt,
            name: userPayload["name"] as? String,
            avatarURL: userPayload["avatar_url"] as? String,
            customData: userPayload["custom_data"] as? [String: Any],
            instance: instance,
            userStore: userStore
        )
    }

    static func createRoomFromPayload(_ roomPayload: [String: Any]) throws -> PCRoom {
        guard
            let roomId = roomPayload["id"] as? Int,
            let roomName = roomPayload["name"] as? String,
            let isPrivate = roomPayload["private"] as? Bool,
            let roomCreatorUserId = roomPayload["created_by_id"] as? String,
            let roomCreatedAt = roomPayload["created_at"] as? String,
            let roomUpdatedAt = roomPayload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCRoom.self), payload: roomPayload)
        }

        var memberUserIdsSet: Set<String>?

        if let memberUserIds = roomPayload["member_user_ids"] as? [String] {
            memberUserIdsSet = Set<String>(memberUserIds)
        }

        return PCRoom(
            id: roomId,
            name: roomName,
            isPrivate: isPrivate,
            createdByUserId: roomCreatorUserId,
            createdAt: roomCreatedAt,
            updatedAt: roomUpdatedAt,
            deletedAt: roomPayload["deleted_at"] as? String,
            userIds: memberUserIdsSet
        )
    }

    // This returns a PCBasicMessage mainly to signal that it needs to be enriched with
    // information about its associated sender and the room it belongs to
    static func createMessageFromPayload(_ messagePayload: [String: Any]) throws -> PCBasicMessage {
        guard
            let messageId = messagePayload["id"] as? Int,
            let messageSenderId = messagePayload["user_id"] as? String,
            let messageRoomId = messagePayload["room_id"] as? Int,
            let messageText = messagePayload["text"] as? String,
            let messageCreatedAt = messagePayload["created_at"] as? String,
            let messageUpdatedAt = messagePayload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCBasicMessage.self), payload: messagePayload)
        }

        return PCBasicMessage(
            id: messageId,
            senderId: messageSenderId,
            roomId: messageRoomId,
            text: messageText,
            createdAt: messageCreatedAt,
            updatedAt: messageUpdatedAt
        )
    }

    static func createPresencePayloadFromPayload(_ payload: [String: Any]) throws -> PCPresencePayload {
        guard
            let userId = payload["user_id"] as? String,
            let stateString = payload["state"] as? String,
            let state = PCPresenceState(rawValue: stateString)
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCPresencePayload.self), payload: payload)
        }

        return PCPresencePayload(
            userId: userId,
            state: state,
            lastSeenAt: payload["last_seen_at"] as? String
        )
    }

    fileprivate static func createBasicUserFromPayload(_ payload: [String: Any]) throws -> PCBasicUser {
        guard
            let userId = payload["id"] as? String,
            let createdAt = payload["created_at"] as? String,
            let updatedAt = payload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCUser.self), payload: payload)
        }

        return PCBasicUser(id: userId, createdAt: createdAt, updatedAt: updatedAt)
    }
}

public enum PCPayloadDeserializerError: Error {
    case incompleteOrInvalidPayloadToCreteEntity(type: String, payload: [String: Any])
}

extension PCPayloadDeserializerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case let .incompleteOrInvalidPayloadToCreteEntity(type, payload):
            return "Incomplete or invalid data in order to create \(type) in provided payload: \(payload)"
        }
    }
}
