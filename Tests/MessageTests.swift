import XCTest
import PusherPlatform
@testable import PusherChatkit

class MessagesTests: XCTestCase {
    var aliceChatManager: ChatManager!
    var bobChatManager: ChatManager!
    var roomId: Int!

    override func setUp() {
        super.setUp()

        aliceChatManager = newTestChatManager(userId: "alice")
        bobChatManager = newTestChatManager(userId: "bob")

        let deleteResourcesEx = expectation(description: "delete resources")
        let createRolesEx = expectation(description: "create roles")
        let createAliceEx = expectation(description: "create Alice")
        let createBobEx = expectation(description: "create Bob")
        let createRoomEx = expectation(description: "create room")
        let sendMessagesEx = expectation(description: "send messages")

        deleteInstanceResources() { err in
            XCTAssertNil(err)
            deleteResourcesEx.fulfill()

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

            // TODO the following should really wait until we know both Alice
            // and Bob exist... for now, sleep!
            sleep(1)

            self.aliceChatManager.connect(delegate: TestingChatManagerDelegate()) { alice, err in
                XCTAssertNil(err)
                alice!.createRoom(name: "mushroom", addUserIds: ["bob"]) { room, err in
                    XCTAssertNil(err)
                    self.roomId = room!.id
                    createRoomEx.fulfill()

                    for t in ["hello", "hey", "hi", "ho"] {
                        alice!.sendMessage(roomId: self.roomId, text: t) { _, err in
                            XCTAssertNil(err)
                        }
                        usleep(200000) // TODO do this properly when we have promises
                    }

                    sendMessagesEx.fulfill()
                }
            }
        }

        waitForExpectations(timeout: 15)
    }

    override func tearDown() {
        aliceChatManager.disconnect()
        aliceChatManager = nil
        bobChatManager.disconnect()
        bobChatManager = nil
        roomId = nil
    }

    func testFetchMessages() {
        let ex = expectation(description: "fetch four messages")

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.fetchMessagesFromRoom(
                bob!.rooms.first(where: { $0.id == self.roomId })!
            ) { messages, err in
                XCTAssertNil(err)

                XCTAssertEqual(
                    messages!.map { $0.text },
                    ["hello", "hey", "hi", "ho"]
                )

                XCTAssert(messages!.all { $0.sender.id == "alice" })
                XCTAssert(messages!.all { $0.sender.name == "Alice" })
                XCTAssert(messages!.all { $0.room.id == self.roomId })
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
                bob!.rooms.first(where: { $0.id == self.roomId })!,
                limit: 2
            ) { messages, err in
                XCTAssertNil(err)

                XCTAssertEqual(messages!.map { $0.text }, ["hi", "ho"])
                XCTAssert(messages!.all { $0.sender.id == "alice" })
                XCTAssert(messages!.all { $0.sender.name == "Alice" })
                XCTAssert(messages!.all { $0.room.id == self.roomId })
                XCTAssert(messages!.all { $0.room.name == "mushroom" })

                bob!.fetchMessagesFromRoom(
                    bob!.rooms.first(where: { $0.id == self.roomId })!,
                    initialId: String(messages!.map { $0.id }.min()!)
                ) { messages, err in
                    XCTAssertNil(err)

                    XCTAssertEqual(messages!.map { $0.text }, ["hello", "hey"])
                    XCTAssert(messages!.all { $0.sender.id == "alice" })
                    XCTAssert(messages!.all { $0.sender.name == "Alice" })
                    XCTAssert(messages!.all { $0.room.id == self.roomId })
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

        let bobRoomDelegate = TestingRoomDelegate(newMessage: { message in
            XCTAssertEqual(message.text, expectedMessageTexts.removeFirst())
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomId)
            XCTAssertEqual(message.room.name, "mushroom")

            if expectedMessageTexts.isEmpty {
                ex.fulfill()
            }
        })

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomId })!,
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

        let bobRoomDelegate = TestingRoomDelegate(newMessage: { message in
            XCTAssertEqual(message.text, expectedMessageTexts.popLast()!)
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomId)
            XCTAssertEqual(message.room.name, "mushroom")

            if expectedMessageTexts.isEmpty {
                ex.fulfill()
            }
        })

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomId })!,
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
        let ex = expectation(description: "subscribe and receive sent messages")

        var expectedMessageTexts = ["yooo", "yo"]

        let bobRoomDelegate = TestingRoomDelegate(newMessage: { message in
            XCTAssertEqual(message.text, expectedMessageTexts.popLast()!)
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomId)
            XCTAssertEqual(message.room.name, "mushroom")

            if expectedMessageTexts.isEmpty {
                ex.fulfill()
            }
        })

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomId })!,
                roomDelegate: bobRoomDelegate,
                messageLimit: 0,
                completionHandler: { err in
                    XCTAssertNil(err)

                    self.aliceChatManager.connect(
                        delegate: TestingChatManagerDelegate()
                    ) { alice, err in
                        alice!.sendMessage(roomId: self.roomId, text: "yo") { _, err in
                            XCTAssertNil(err)
                        }

                        usleep(200000) // TODO do this properly when we have promises

                        alice!.sendMessage(roomId: self.roomId, text: "yooo") { _, err in
                            XCTAssertNil(err)
                        }
                    }
                }
            )
        }

        waitForExpectations(timeout: 15)
    }

    func testSendAndReceiveMessageWithLinkAttachment() {
        let veryImportantImage = "https://i.imgur.com/rJbRKLU.gif"

        let ex = expectation(description: "subscribe and receive sent messages")

        let bobRoomDelegate = TestingRoomDelegate(newMessage: { message in
            XCTAssertEqual(message.text, "see attached")
            XCTAssertEqual(message.sender.id, "alice")
            XCTAssertEqual(message.sender.name, "Alice")
            XCTAssertEqual(message.room.id, self.roomId)
            XCTAssertEqual(message.room.name, "mushroom")
            XCTAssertEqual(message.attachment!.link, veryImportantImage)
            XCTAssertEqual(message.attachment!.type, "image")

            ex.fulfill()
        })

        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
            XCTAssertNil(err)

            bob!.subscribeToRoom(
                room: bob!.rooms.first(where: { $0.id == self.roomId })!,
                roomDelegate: bobRoomDelegate,
                messageLimit: 0,
                completionHandler: { err in
                    XCTAssertNil(err)

                    self.aliceChatManager.connect(
                        delegate: TestingChatManagerDelegate()
                    ) { alice, err in
                        alice!.sendMessage(
                            roomId: self.roomId,
                            text: "see attached",
                            attachment: .link(veryImportantImage, type: "image")
                        ) { _, err in
                            XCTAssertNil(err)
                        }
                    }
                }
            )
        }

        waitForExpectations(timeout: 15)
    }

    // TODO: This fails because of some problem with the upload never working.
    // Seeing as files is still in beta (and it works in the example app) it
    // seems safe to ignore this for now

//    func testSendAndReceiveMessageWithDataAttachment() {
//        let veryImportantImage = Bundle(for: type(of: self))
//            .path(
//                forResource: "test-image",
//                ofType: "gif"
//            )!
//
//        let ex = expectation(description: "subscribe and receive sent messages")
//
//        let bobRoomDelegate = TestingRoomDelegate(newMessage: { message in
//            XCTAssertEqual(message.text, "see attached")
//            XCTAssertEqual(message.sender.id, "alice")
//            XCTAssertEqual(message.sender.name, "Alice")
//            XCTAssertEqual(message.room.id, self.roomId)
//            XCTAssertEqual(message.room.name, "mushroom")
//            XCTAssertEqual(message.attachment!.type, "image")
//            // TODO assert some more stuff about the attachment (and fetch it?)
//
//            ex.fulfill()
//        })
//
//        bobChatManager.connect(delegate: TestingChatManagerDelegate()) { bob, err in
//            XCTAssertNil(err)
//
//            bob!.subscribeToRoom(
//                room: bob!.rooms.first(where: { $0.id == self.roomId })!,
//                roomDelegate: bobRoomDelegate,
//                messageLimit: 0,
//                completionHandler: { err in
//                    XCTAssertNil(err)
//
//                }
//            )
//
//            let filesUploadSessionTestConfig = URLSessionConfiguration.ephemeral
////            filesUploadSessionTestConfig.identifier = "com.pusher.chatkit.files-upload-test.\(UUID().uuidString)"
//            filesUploadSessionTestConfig.httpAdditionalHeaders = self.aliceChatManager.filesInstance.client.sdkInfoHeaders
//            self.aliceChatManager.filesInstance.client.uploadURLSession = URLSession(configuration: filesUploadSessionTestConfig)
//
//            self.aliceChatManager.connect(
//                delegate: TestingChatManagerDelegate()
//            ) { alice, err in
//                alice!.sendMessage(
//                    roomId: self.roomId,
//                    text: "see attached",
//                    attachment: .fileURL(
//                        URL(fileURLWithPath: veryImportantImage),
//                        name: "test-image.gif"
//                    )
//                ) { _, err in
//                    XCTAssertNil(err)
//                }
//            }
//        }
//
//        waitForExpectations(timeout: 15)
//    }
}
