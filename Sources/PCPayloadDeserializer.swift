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

    static func createCurrentUserFromPayload(
        _ userPayload: [String: Any],
        id: String,
        pathFriendlyID: String,
        instance: Instance,
        v6Instance: Instance,
        chatkitBeamsTokenProviderInstance: Instance,
        filesInstance: Instance,
        cursorsInstance: Instance,
        presenceInstance: Instance,
        userStore: PCGlobalUserStore,
        roomStore: PCRoomStore,
        cursorStore: PCCursorStore,
        connectionCoordinator: PCConnectionCoordinator,
        delegate: PCChatManagerDelegate
    ) throws -> PCCurrentUser {
        let basicUser = try createBasicUserFromPayload(userPayload)

        return PCCurrentUser(
            id: id,
            pathFriendlyID: pathFriendlyID,
            createdAt: basicUser.createdAt,
            updatedAt: basicUser.updatedAt,
            name: userPayload["name"] as? String,
            avatarURL: userPayload["avatar_url"] as? String,
            customData: userPayload["custom_data"] as? [String: Any],
            instance: instance,
            v6Instance: v6Instance,
            chatkitBeamsTokenProviderInstance: chatkitBeamsTokenProviderInstance,
            filesInstance: filesInstance,
            cursorsInstance: cursorsInstance,
            presenceInstance: presenceInstance,
            userStore: userStore,
            roomStore: roomStore,
            cursorStore: cursorStore,
            connectionCoordinator: connectionCoordinator,
            delegate: delegate
        )
    }

    static func createRoomFromPayload(_ roomPayload: [String: Any]) throws -> PCRoom {
        guard
            let roomID = roomPayload["id"] as? String,
            let roomName = roomPayload["name"] as? String,
            let isPrivate = roomPayload["private"] as? Bool,
            let roomCreatorUserID = roomPayload["created_by_id"] as? String,
            let roomCreatedAt = roomPayload["created_at"] as? String,
            let roomUpdatedAt = roomPayload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCRoom.self), payload: roomPayload)
        }

        let pushNotificationTitleOverride = roomPayload["push_notification_title_override"] as? String? ?? nil

        var memberUserIDsSet: Set<String>?

        if let memberUserIDs = roomPayload["member_user_ids"] as? [String] {
            memberUserIDsSet = Set<String>(memberUserIDs)
        }

        return PCRoom(
            id: roomID,
            name: roomName,
            pushNotificationTitleOverride: pushNotificationTitleOverride,
            isPrivate: isPrivate,
            createdByUserID: roomCreatorUserID,
            createdAt: roomCreatedAt,
            updatedAt: roomUpdatedAt,
            customData: roomPayload["custom_data"] as? [String: Any],
            unreadCount: roomPayload["unread_count"] as? Int,
            lastMessageAt: roomPayload["last_message_at"] as? String,
            userIDs: memberUserIDsSet,
            deletedAt: roomPayload["deleted_at"] as? String
        )
    }

    // This returns a PCBasicMessage mainly to signal that it needs to be enriched with
    // information about its associated sender and the room it belongs to
    static func createBasicMessageFromPayload(_ messagePayload: [String: Any]) throws -> PCBasicMessage {
        guard
            let messageID = messagePayload["id"] as? Int,
            let messageSenderID = messagePayload["user_id"] as? String,
            let messageRoomID = messagePayload["room_id"] as? String,
            let messageText = messagePayload["text"] as? String,
            let messageCreatedAt = messagePayload["created_at"] as? String,
            let messageUpdatedAt = messagePayload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCBasicMessage.self), payload: messagePayload)
        }

        return PCBasicMessage(
            id: messageID,
            senderID: messageSenderID,
            roomID: messageRoomID,
            text: messageText,
            createdAt: messageCreatedAt,
            updatedAt: messageUpdatedAt,
            deletedAt: messagePayload["deleted_at"] as? String,
            attachment: createAttachmentFromPayload(messagePayload["attachment"])
        )
    }

    static func createPresencePayloadFromPayload(_ payload: [String: Any]) throws -> PCPresencePayload {
        guard let stateString = payload["state"] as? String,
              let state = PCPresenceState(rawValue: stateString)
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(
                type: String(describing: PCPresencePayload.self),
                payload: payload
            )
        }

        return PCPresencePayload(state: state)
    }

    static func createAttachmentFromPayload(_ payload: Any?) -> PCAttachment? {
        guard
            let payload = payload as? [String: Any],
            let link = payload["resource_link"] as? String,
            let type = payload["type"] as? String,
            let name = payload["name"] as? String
        else {
            return nil
        }

        return PCAttachment(link: link, type: type, name: name)
    }

    static func createAttachmentUploadResponseFromPayload(_ payload: [String: Any]) throws -> PCAttachmentUploadResponse {
        guard
            let link = payload["resource_link"] as? String,
            let type = payload["type"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCAttachmentUploadResponse.self), payload: payload)
        }

        return PCAttachmentUploadResponse(link: link, type: type)
    }

    static func createBasicCursorFromPayload(_ payload: [String: Any]) throws -> PCBasicCursor {
        guard
            let cursorTypeInt = payload["cursor_type"] as? Int,
            let cursorType = PCCursorType(rawValue: cursorTypeInt),
            let position = payload["position"] as? Int,
            let userID = payload["user_id"] as? String,
            let roomID = payload["room_id"] as? String,
            let updatedAt = payload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCBasicCursor.self), payload: payload)
        }

        return PCBasicCursor(
            type: cursorType,
            position: position,
            roomID: roomID,
            updatedAt: updatedAt,
            userID: userID
        )
    }
    
    static func createMultipartMessageFromPayload(
        _ payload: [String: Any],
        urlRefresher: PCMultipartAttachmentUrlRefresher
    ) throws -> PCBasicMultipartMessage {
        guard
            let id = payload["id"] as? Int,
            let senderID = payload["user_id"] as? String,
            let roomID = payload["room_id"] as? String,
            let parts = payload["parts"] as? [[String: Any]],
            let createdAt = payload["created_at"] as? String,
            let updatedAt = payload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCBasicMultipartMessage.self), payload: payload)
        }
        
        let messageParts = try (parts.map { try createPartFromPayload($0, urlRefresher: urlRefresher)})
        
        return PCBasicMultipartMessage(
            id: id,
            senderID: senderID,
            roomID: roomID,
            parts: messageParts,
            createdAt: createdAt,
            updatedAt: updatedAt
        )
    }
    
    static func createMultipartAttachmentFromPayload(
        _ payload: [String: Any],
        type: String,
        urlRefresher: PCMultipartAttachmentUrlRefresher
    ) throws -> PCMultipartAttachmentPayload {
        guard
            let id = payload["id"] as? String,
            let downloadUrl = payload["download_url"] as? String,
            let refreshUrl = payload["refresh_url"] as? String,
            let expiration = payload["expiration"] as? String,
            let name = payload["name"] as? String?,
            let customData = payload["custom_data"] as? [String: Any]?,
            let size = payload["size"] as? Int
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCMultipartAttachmentPayload.self), payload: payload)
        }
        
        return PCMultipartAttachmentPayload(
            type: type,
            id: id,
            name: name,
            customData: customData,
            size: size,
            urlRefresher: urlRefresher,
            refreshUrl: refreshUrl,
            downloadUrl: downloadUrl,
            expiration: expiration
        )
    }
    
    fileprivate static func createPartFromPayload(
        _ payload: [String: Any],
        urlRefresher: PCMultipartAttachmentUrlRefresher
    ) throws -> PCPart {
        // Empty mutable part
        var resultPartPayload: PCMultipartPayload = .inline(PCMultipartInlinePayload(type: "", content: ""))
        
        guard let partType = payload["type"] as? String else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCPart.self), payload: payload)
        }
        
        if let content = payload["content"] as? String {
            resultPartPayload = .inline(PCMultipartInlinePayload(type: partType, content: content))
        }
        
        if let url = payload["url"] as? String {
            resultPartPayload = .url(PCMultipartURLPayload(type: partType, url: url))
        }
        
        
        if let attachment = payload["attachment"] as? [String: Any] {
            let multipartAttachment = try createMultipartAttachmentFromPayload(attachment, type: partType, urlRefresher: urlRefresher)
            resultPartPayload = .attachment(multipartAttachment)
        }
        
        return PCPart(resultPartPayload)
    }

    fileprivate static func createBasicUserFromPayload(_ payload: [String: Any]) throws -> PCBasicUser {
        guard
            let userID = payload["id"] as? String,
            let createdAt = payload["created_at"] as? String,
            let updatedAt = payload["updated_at"] as? String
        else {
            throw PCPayloadDeserializerError.incompleteOrInvalidPayloadToCreteEntity(type: String(describing: PCUser.self), payload: payload)
        }

        return PCBasicUser(id: userID, createdAt: createdAt, updatedAt: updatedAt)
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
