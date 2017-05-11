import Foundation
import PusherPlatform

public struct PCPayloadDeserializer {
    static public func createUserFromPayload(_ userPayload: [String: Any]) throws -> PCUser {
        let basicUser = try createBasicUserFromPayload(userPayload)

        return PCUser(
            id: basicUser.id,
            createdAt: basicUser.createdAt,
            updatedAt: basicUser.updatedAt,
            name: userPayload["name"] as? String,
            customId: userPayload["custom_id"] as? String,
            customData: userPayload["custom_data"] as? [String: Any]
        )
    }

    static public func createCurrentUserFromPayload(_ userPayload: [String: Any], app: App) throws -> PCCurrentUser {
        let basicUser = try createBasicUserFromPayload(userPayload)

        return PCCurrentUser(
            id: basicUser.id,
            createdAt: basicUser.createdAt,
            updatedAt: basicUser.updatedAt,
            name: userPayload["name"] as? String,
            customId: userPayload["custom_id"] as? String,
            customData: userPayload["custom_data"] as? [String: Any],
            app: app
        )
    }

    static public func createRoomFromPayload(_ roomPayload: [String: Any]) throws -> PCRoom {
        guard let roomId = roomPayload["id"] as? Int,
              let roomName = roomPayload["name"] as? String,
              let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
              let roomCreatedAt = roomPayload["created_at"] as? String,
              let roomUpdatedAt = roomPayload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCRoom.self), payload: roomPayload)
        }

        return PCRoom(
            id: roomId,
            name: roomName,
            createdByUserId: roomCreatorUserId,
            createdAt: roomCreatedAt,
            updatedAt: roomUpdatedAt,
            deletedAt: roomPayload["deleted_at"] as? String
        )
    }

    static public func createMessageFromPayload(_ messagePayload: [String: Any]) throws -> PCMessage {
        guard let messageId = messagePayload["id"] as? Int,
              let messageSenderId = messagePayload["user_id"] as? Int,
              let messageRoomId = messagePayload["room_id"] as? Int,
              let messageText = messagePayload["text"] as? String,
              let messageCreatedAt = messagePayload["created_at"] as? String,
              let messageUpdatedAt = messagePayload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCMessage.self), payload: messagePayload)
        }

        return PCMessage(
            id: messageId,
            senderId: messageSenderId,
            roomId: messageRoomId,
            text: messageText,
            createdAt: messageCreatedAt,
            updatedAt: messageUpdatedAt
        )
    }

    static fileprivate func createBasicUserFromPayload(_ payload: [String: Any]) throws -> PCBasicUser {
        guard let userId = payload["id"] as? Int,
              let createdAt = payload["created_at"] as? String,
              let updatedAt = payload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCUser.self), payload: payload)
        }

        return PCBasicUser(id: userId, createdAt: createdAt, updatedAt: updatedAt)
    }

}

fileprivate struct PCBasicUser {
    let id: Int
    let createdAt: String
    let updatedAt: String
}

public enum PCPayloadDeserializerError: Error {
    case incompleteOrInvalidPayloadToCreteEntity(type: String, payload: [String: Any])
}

extension PCPayloadDeserializerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incompleteOrInvalidPayloadToCreteEntity(let type, let payload):
            return "Incomplete or invalid data in order to create \(type) in provided payload: \(payload)"
        }
    }
}
