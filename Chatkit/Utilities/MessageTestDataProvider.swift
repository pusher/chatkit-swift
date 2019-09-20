//
//  MessageTestDataProvider.swift
//  Chatkit
//
//  Created by Mike Pye on 17/09/2019.
//  Copyright © 2019 Pusher Ltd. All rights reserved.
//

import Foundation
import PusherPlatform

public class MessageTestDataProvider {

    private let persistenceController: PersistenceController
    private let user: UserEntity
    private let room: RoomEntity

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.user = MessageTestDataProvider.createUser(persistenceController: persistenceController)
        self.room = MessageTestDataProvider.createRoom(persistenceController: persistenceController)
    }

    static func createUser(persistenceController: PersistenceController) -> UserEntity {
        let now = Date()
        let number = Int.random(in: 1..<10000)

        let user = persistenceController.mainContext.create(UserEntity.self)
        user.identifier = "user\(number)"
        user.name = "Greg \(number)"
        user.createdAt = now
        user.updatedAt = now

        persistenceController.save()

        return user
    }
    
    static func createRoom(persistenceController: PersistenceController) -> RoomEntity {
        let now = Date()
        
        let room = persistenceController.mainContext.create(RoomEntity.self)
        room.identifier = "testRoom"
        room.name = "Room"
        room.createdAt = now
        room.updatedAt = now
        room.isPrivate = false
        room.unreadCount = 3
        
        persistenceController.save()
        
        return room
    }

    func createMessage(_ id: UInt) -> MessageEntity {
        let now = Date()

        let part = self.persistenceController.mainContext.create(InlinePartEntity.self)
        part.type = "test/plain"
        part.content = "Message \(id)"

        let message = self.persistenceController.mainContext.create(MessageEntity.self)
        message.identifier = "\(id)"
        message.sender = self.user
        message.parts = Set([part])
        message.createdAt = now
        message.updatedAt = now
        message.room = self.room
        
        message.addToParts(part)
        
        self.persistenceController.save()

        return message
    }

    func createMessages(ids: ClosedRange<UInt>) -> [MessageEntity] {
        return ids.map { id in
            self.createMessage(id)
        }
    }
}

