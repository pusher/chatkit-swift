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

    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
    }

    func createUser() -> UserEntity {
        let now = Date()
        let number = Int.random(in: 1..<10000)

        let user = self.persistenceController.mainContext.create(UserEntity.self)
        user.identifier = "user\(number)"
        user.name = "Greg \(number)"
        user.createdAt = now
        user.updatedAt = now

        self.persistenceController.save()

        return user
    }

    func createMessage(_ id: UInt) -> MessageEntity {
        let now = Date()

        let part = self.persistenceController.mainContext.create(InlinePartEntity.self)
        part.type = "test/plain"
        part.content = "Message \(id)"

        let message = self.persistenceController.mainContext.create(MessageEntity.self)
        message.identifier = "\(id)"
        message.sender = self.createUser()
        message.parts = Set([part])
        message.createdAt = now
        message.updatedAt = now

        part.message = message

        self.persistenceController.save()

        return message
    }

    func createMessages(ids: ClosedRange<UInt>) -> [MessageEntity] {
        return ids.map { id in
            self.createMessage(id)
        }
    }
}

