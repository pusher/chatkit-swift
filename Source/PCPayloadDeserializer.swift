import Foundation

public struct PCPayloadDeserializer {
    static public func createUserFromPayload(_ userPayload: [String: Any]) throws -> PCUser {
        guard let userId = userPayload["id"] as? Int,
              let createdAt = userPayload["created_at"] as? String,
              let updatedAt = userPayload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteDataInPayloadToCreateEntity(type: String(describing: PCUser.self), payload: userPayload)
        }

        return PCUser(
            id: userId,
            createdAt: createdAt,
            updatedAt: updatedAt,
            name: userPayload["name"] as? String,
            customId: userPayload["custom_id"] as? String,
            customData: userPayload["custom_data"] as? [String: Any]
        )
    }

    static public func createRoomFromPayload(_ roomPayload: [String: Any]) throws -> PCRoom {
        guard let roomId = roomPayload["id"] as? Int,
              let roomName = roomPayload["name"] as? String,
              let roomCreatorUserId = roomPayload["created_by_id"] as? Int,
              let roomCreatedAt = roomPayload["created_at"] as? String,
              let roomUpdatedAt = roomPayload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteDataInPayloadToCreateEntity(type: String(describing: PCRoom.self), payload: roomPayload)
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
            throw PCPayloadDeserializerError.incompleteDataInPayloadToCreateEntity(type: String(describing: PCMessage.self), payload: messagePayload)
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

}

public enum PCPayloadDeserializerError: Error {

    // TODO: This should probably be more like incompleteOrInvalidPayloadToCreteEntity

    case incompleteDataInPayloadToCreateEntity(type: String, payload: [String: Any])
}

extension PCPayloadDeserializerError: LocalizedError {
    public var errorDescription: String? {
        switch self {
        case .incompleteDataInPayloadToCreateEntity(type: let type, payload: let payload):
            return "Incomplete data to create \(type) in provided payload: \(payload)"
        }
    }
}
