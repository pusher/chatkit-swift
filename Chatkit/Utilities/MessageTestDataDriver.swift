//
//  MessageTestDataDriver.swift
//  Chatkit
//
//  Created by Mike Pye on 17/09/2019.
//  Copyright © 2019 Pusher Ltd. All rights reserved.
//

import Foundation

public class MessageTestDataDriver {

    private let testDataProvider: MessageTestDataProvider
    private var timer: Timer?
    private var lowMessageId = UInt(2000)
    private var highMessageId = UInt(2000)

    public init(testDataProvider: MessageTestDataProvider) {
        self.testDataProvider = testDataProvider
    }

    public func start() {
        self.createOldMessages(amount: 6)

        self.timer = Timer.scheduledTimer(withTimeInterval: 2.0, repeats: true, block: { _ in
            self.highMessageId += 1
            let _ = self.testDataProvider.createMessage(self.highMessageId)
        })
    }

    public func createOldMessages(amount: UInt) {
        self.lowMessageId = lowMessageId - amount
        let _ = self.testDataProvider.createMessages(ids: self.lowMessageId...(self.lowMessageId+amount))
    }
    
}

extension MessageTestDataDriver: ChatkitClient {
    
    func fetchMessages(room: String, from: String?, order: String, amount: UInt, completionHandler: (Error?) -> ()) {
        completionHandler(nil)
    }
    
}
