import XCTest
import PusherPlatform
@testable import PusherChatkit

class MessagesTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var bobChatManager: ChatManager!
    var roomID: String!

    override func setUp() {
        super.setUp()

        aliceChatManager = newTestChatManager(userID: "alice")
        bobChatManager = newTestChatManager(userID: "bob")

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let createRoomEx = expectation(description: "create room")
        let sendMessagesEx = expectation(description: "send messages")

        deleteInstanceResources() { err in
            XCTAssertNil(err)
            deleteResourcesEx.fulfill()
        }

        wait(for: [deleteResourcesEx], timeout: 15)

        createStandardInstanceRoles() { err in
            XCTAssertNil(err)
            createRolesEx.fulfill()
        }

        createUser(id: "alice", name: "Alice") { err in
            XCTAssertNil(err)
            createAliceEx.fulfill()
        }

        createUser(id: "bob", name: "Bob") { err in
            XCTAssertNil(err)
            createBobEx.fulfill()
        }
        wait(for: [createRolesEx, createAliceEx, createBobEx], timeout: 15)

        createRoom(
            creatorID: "alice",
            name: "mushroom",
            addUserIDs: ["bob"]
        ) { err, data in
            XCTAssertNil(err)
            XCTAssertNotNil(data)
            let roomObject = try! JSONSerialization.jsonObject(with: data!, options: []) as! [String: Any]
            let roomIDFromJSON = roomObject["id"] as! String
            self.roomID = roomIDFromJSON

            createRoomEx.fulfill()
        }
        wait(for: [createRoomEx], timeout: 15)

        let messages = ["hello", "hey", "hi", "ho"]
        sendOrderedMessages(
            messages: messages,
            fromUserID: "alice",
            toRoomID: self.roomID
        ) { err in
            XCTAssertNil(err)
            sendMessagesEx.fulfill()
        }

        wait(for: [sendMessagesEx], timeout: 15)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        aliceChatManager = nil
        bobChatManager.disconnect()
        bobChatManager = nil
        roomID = nil
    }

    func testFetchMessages() {
        let ex = expectation(description: "fetch four messages")

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.fetchMessagesFromRoom(
                bob!.rooms.first(where: { $0.id == self.roomID })!
            ) { messages, err in
                XCTAssertNil(err)

                XCTAssertEqual(
                    messages!.map { $0.text },
                    ["hello", "hey", "hi", "ho"]
                )

                XCTAssert(messages!.all { $0.sender.id == "alice" })
                XCTAssert(messages!.all { $0.sender.name == "Alice" })
                XCTAssert(messages!.all { $0.room.id == self.roomID })
                XCTAssert(messages!.all { $0.room.name == "mushroom" })

                ex.fulfill()
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testFetchMessagesPaginated() {
        let ex = expectation(description: "fetch four messages in pairs")

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.fetchMessagesFromRoom(
                bob!.rooms.first(where: { $0.id == self.roomID })!,
                limit: 2
            ) { messages, err in
                XCTAssertNil(err)

                XCTAssertEqual(messages!.map { $0.text }, ["hi", "ho"])
                XCTAssert(messages!.all { $0.sender.id == "alice" })
                XCTAssert(messages!.all { $0.sender.name == "Alice" })
                XCTAssert(messages!.all { $0.room.id == self.roomID })
                XCTAssert(messages!.all { $0.room.name == "mushroom" })

                bob!.fetchMessagesFromRoom(
                    bob!.rooms.first(where: { $0.id == self.roomID })!,
                    initialID: String(messages!.map { $0.id }.min()!)
                ) { messages, err in
                    XCTAssertNil(err)

                    XCTAssertEqual(messages!.map { $0.text }, ["hello", "hey"])
                    XCTAssert(messages!.all { $0.sender.id == "alice" })
                    XCTAssert(messages!.all { $0.sender.name == "Alice" })
                    XCTAssert(messages!.all { $0.room.id == self.roomID })
                    XCTAssert(messages!.all { $0.room.name == "mushroom" })

                    ex.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    func testSubscribeToRoomAndFetchInitial() {
        let ex = expectation(description: "subscribe and get initial messages")

        var expectedMessageTexts = ["hello", "hey", "hi", "ho"]

        let bobRoomDelegate = TestingRoomDelegate(onMessage: { message in
            XCTAssertEqual(message.text, expectedMessageTexts.removeFirst())
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomID)
            XCTAssertEqual(message.room.name, "mushroom")

            if expectedMessageTexts.isEmpty {
                ex.fulfill()
            }
        })

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: bobRoomDelegate,
                completionHandler: { err in
                    XCTAssertNil(err)
                }
            )
        }

        waitForExpectations(timeout: 15)
    }

    func testSubscribeToRoomAndFetchLastTwoMessagesOnly() {
        let ex = expectation(description: "subscribe and fetch last two messages only")

        var expectedMessageTexts = ["ho", "hi"]

        let bobRoomDelegate = TestingRoomDelegate(onMessage: { message in
            XCTAssertEqual(message.text, expectedMessageTexts.popLast()!)
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomID)
            XCTAssertEqual(message.room.name, "mushroom")

            if expectedMessageTexts.isEmpty {
                ex.fulfill()
            }
        })

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: bobRoomDelegate,
                messageLimit: 2,
                completionHandler: { err in
                    XCTAssertNil(err)
                }
            )
        }

        waitForExpectations(timeout: 15)
    }

    func testSubscribeToRoomAndReceiveSentMessages() {
        let connectEx = expectation(description: "bob connected")
        let subscribeEx = expectation(description: "bob subscribed to room")
        let sendMessagesEx = expectation(description: "messages sent")
        let messagesReceivedEx = expectation(description: "received sent messages")

        var expectedMessageTexts = ["yooo", "yo"]

        let bobRoomDelegate = TestingRoomDelegate(onMessage: { message in
            XCTAssertEqual(message.text, expectedMessageTexts.popLast()!)
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomID)
            XCTAssertEqual(message.room.name, "mushroom")

            if expectedMessageTexts.isEmpty {
                messagesReceivedEx.fulfill()
            }
        })

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)
            connectEx.fulfill()

            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: bobRoomDelegate,
                messageLimit: 0,
                completionHandler: { err in
                    XCTAssertNil(err)
                    subscribeEx.fulfill()
                }
            )
        }
        wait(for: [connectEx, subscribeEx], timeout: 15)

        let messages = ["yo", "yooo"]
        sendOrderedMessages(
            messages: messages,
            fromUserID: "alice",
            toRoomID: self.roomID
        ) { err in
            XCTAssertNil(err)
            sendMessagesEx.fulfill()
        }
        wait(for: [sendMessagesEx, messagesReceivedEx], timeout: 15)
    }

    func testSendAndReceiveMessageWithLinkAttachment() {
        let veryImportantImage = "https://i.imgur.com/rJbRKLU.gif"

        let onMessageHookCalledEx = expectation(description: "subscribe and receive sent messages")
        let messageSentEx = expectation(description: "message sent successfully")

        let bobRoomDelegate = TestingRoomDelegate(onMessage: { message in
            XCTAssertEqual(message.text, "see attached")
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomID)
            XCTAssertEqual(message.room.name, "mushroom")
            XCTAssertEqual(message.attachment!.link, veryImportantImage)
            XCTAssertEqual(message.attachment!.type, "image")
            XCTAssertEqual(message.attachment!.name, "rJbRKLU.gif")

            onMessageHookCalledEx.fulfill()
        })

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomID })!,
                roomDelegate: bobRoomDelegate,
                messageLimit: 0,
                completionHandler: { err in
                    XCTAssertNil(err)

                    self.aliceChatManager.connect(
                        delegate: TestingChatManagerDelegate()
                    ) { alice, err in
                        alice!.sendMessage(
                            roomID: self.roomID,
                            text: "see attached",
                            attachment: .link(veryImportantImage, type: "image")
                        ) { _, err in
                            XCTAssertNil(err)
                            messageSentEx.fulfill()
                        }
                    }
                }
            )
        }

        waitForExpectations(timeout: 15)
    }

    func testUnsubscribingFromARoomMeansYouStopReceivingMessages() {
        let connectEx = expectation(description: "bob connected successfully")
        let subscribedFirstEx = expectation(description: "subscribed to room first time successfully")
        let subscribedSecondEx = expectation(description: "subscribed to room second time successfully")
        let firstOnMessageHookCalledEx = expectation(description: "received first message")
        let secondOnMessageHookCalledEx = expectation(description: "received third message")
        let firstMessageSentEx = expectation(description: "first message sent successfully")
        let secondMessageSentEx = expectation(description: "second message sent successfully")
        let thirdMessageSentEx = expectation(description: "third message sent successfully")

        var messageCountReceived = 0

        let bobRoomDelegate = TestingRoomDelegate(onMessage: { message in
            switch messageCountReceived {
            case 0:
                XCTAssertEqual(message.text, "some text")
                XCTAssertEqual(message.sender.id, "alice")
                XCTAssertEqual(message.sender.name, "Alice")
                XCTAssertEqual(message.room.id, self.roomID)
                XCTAssertEqual(message.room.name, "mushroom")

                messageCountReceived += 1
                firstOnMessageHookCalledEx.fulfill()
            case 1:
                XCTAssertEqual(message.text, "message three")
                XCTAssertEqual(message.sender.id, "alice")
                XCTAssertEqual(message.sender.name, "Alice")
                XCTAssertEqual(message.room.id, self.roomID)
                XCTAssertEqual(message.room.name, "mushroom")

                messageCountReceived += 1
                secondOnMessageHookCalledEx.fulfill()
            default:
                XCTFail("Too many messages received")
            }

        })

        var bob: PCCurrentUser!

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { b, err in
            XCTAssertNil(err)
            bob = b
            connectEx.fulfill()
        }

        wait(for: [connectEx], timeout: 15)

        bob.subscribeToRoom(
            id: self.roomID,
            roomDelegate: bobRoomDelegate,
            messageLimit: 0,
            completionHandler: { err in
                XCTAssertNil(err)
                subscribedFirstEx.fulfill()
            }
        )

        wait(for: [subscribedFirstEx], timeout: 15)

        sendMessage(asUser: "alice", toRoom: self.roomID, text: "some text") { err in
            XCTAssertNil(err)
            firstMessageSentEx.fulfill()
        }

        wait(for: [firstOnMessageHookCalledEx, firstMessageSentEx], timeout: 15)

        bob.rooms.first { $0.id == self.roomID }!.unsubscribe()

        sendMessage(asUser: "alice", toRoom: self.roomID, text: "message 2") { err in
            XCTAssertNil(err)
            secondMessageSentEx.fulfill()
        }

        wait(for: [secondMessageSentEx], timeout: 15)

        bob.subscribeToRoom(
            id: self.roomID,
            roomDelegate: bobRoomDelegate,
            messageLimit: 0,
            completionHandler: { err in
                XCTAssertNil(err)
                subscribedSecondEx.fulfill()
            }
        )

        wait(for: [subscribedSecondEx], timeout: 15)

        sendMessage(asUser: "alice", toRoom: self.roomID, text: "message three") { err in
            XCTAssertNil(err)
            thirdMessageSentEx.fulfill()
        }

        wait(for: [secondOnMessageHookCalledEx, thirdMessageSentEx], timeout: 15)
    }

    // Unsure why this doesn't work on iOS but it does work for macOS. Uploading
    // using the same method as is used here works in the iOS example app, so I
    // think it must be some test-specific oddity
    #if os(macOS)
    func testSendAndReceiveMessageWithDataAttachment() {
        let bundle = Bundle(for: type(of: self))
        let veryImportantImage = bundle.path(
            forResource: "test-image",
            ofType: "gif"
        )!

        let onMessageHookCalledEx = expectation(description: "subscribe and receive sent message")
        let messageSentEx = expectation(description: "message sent successfully")
        let bobConnectedEx = expectation(description: "bob connected")
        let bobSubscribedToRoomEx = expectation(description: "bob subscribed to room")

        let bobRoomDelegate = TestingRoomDelegate(onMessage: { message in
            XCTAssertEqual(message.text, "see attached")
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomID)
            XCTAssertEqual(message.room.name, "mushroom")
            XCTAssertEqual(message.attachment!.type, "image")
            XCTAssertEqual(message.attachment!.name, "test-image.gif")

            onMessageHookCalledEx.fulfill()
        })

        var bob: PCCurrentUser!

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { b, err in
            XCTAssertNil(err)
            bob = b
            bobConnectedEx.fulfill()
        }

        wait(for: [bobConnectedEx], timeout: 15)

        bob.subscribeToRoom(
            room: bob.rooms.first(where: { $0.id == self.roomID })!,
            roomDelegate: bobRoomDelegate,
            messageLimit: 0,
            completionHandler: { err in
                XCTAssertNil(err)
                bobSubscribedToRoomEx.fulfill()
            }
        )

        wait(for: [bobSubscribedToRoomEx], timeout: 15)

        self.aliceChatManager.connect(
            delegate: TestingChatManagerDelegate()
        ) { alice, err in
            alice!.sendMessage(
                roomID: self.roomID,
                text: "see attached",
                attachment: .fileURL(
                    URL(fileURLWithPath: veryImportantImage),
                    name: "test-image.gif"
                )
            ) { _, err in
                XCTAssertNil(err)
                messageSentEx.fulfill()
            }
        }

        wait(for: [messageSentEx, onMessageHookCalledEx], timeout: 15)
    }

    func testSendAndReceiveMessageWithDataAttachmentThatHasAHorribleName() {
        let bundle = Bundle(for: type(of: self))

        let testFilePath = bundle.path(
            forResource: "lol ? wut ?&..",
            ofType: "json"
        )!

        let onMessageHookCalledEx = expectation(description: "subscribe and receive sent message")
        let messageSentEx = expectation(description: "message sent successfully")
        let bobConnectedEx = expectation(description: "bob connected")
        let bobSubscribedToRoomEx = expectation(description: "bob subscribed to room")

        let bobRoomDelegate = TestingRoomDelegate(onMessage: { message in
            XCTAssertEqual(message.text, "see attached")
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomID)
            XCTAssertEqual(message.room.name, "mushroom")
            XCTAssertEqual(message.attachment!.type, "file")
            XCTAssertEqual(message.attachment!.name, "lol ? wut ?&...json")

            onMessageHookCalledEx.fulfill()
        })

        var bob: PCCurrentUser!

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { b, err in
            XCTAssertNil(err)
            bob = b
            bobConnectedEx.fulfill()
        }

        wait(for: [bobConnectedEx], timeout: 15)

        bob.subscribeToRoom(
            room: bob.rooms.first(where: { $0.id == self.roomID })!,
            roomDelegate: bobRoomDelegate,
            messageLimit: 0,
            completionHandler: { err in
                XCTAssertNil(err)
                bobSubscribedToRoomEx.fulfill()
        }
        )

        wait(for: [bobSubscribedToRoomEx], timeout: 15)

        self.aliceChatManager.connect(
            delegate: TestingChatManagerDelegate()
        ) { alice, err in
            alice!.sendMessage(
                roomID: self.roomID,
                text: "see attached",
                attachment: .fileURL(
                    URL(fileURLWithPath: testFilePath),
                    name: "lol ? wut ?&...json"
                )
            ) { _, err in
                XCTAssertNil(err)
                messageSentEx.fulfill()
            }
        }

        wait(for: [messageSentEx, onMessageHookCalledEx], timeout: 15)
    }
    #endif
}
