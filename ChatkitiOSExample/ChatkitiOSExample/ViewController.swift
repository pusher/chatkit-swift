import UIKit
import PusherChatkit

class ViewController: UIViewController {
    @IBOutlet var feedLabel: UILabel!
    var delegate: AppDelegate!

    public var pusherChatUser: PCCurrentUser?
    public var currentRoom: PCRoom?

    @IBAction func disconnectButton(_ sender: Any) {
        print("About to disconnect from Chatkit")
        delegate.pusherChat?.disconnect()
    }

    @IBAction func reconnectButton(_ sender: Any) {
        print("About to reconnect to Chatkit")
        connectToChatkit()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = UIApplication.shared.delegate as! AppDelegate
        connectToChatkit()
    }

    func connectToChatkit() {
        delegate.pusherChat?.connect(delegate: self) { [weak self] currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error!)")
                return
            }
            print("Connected!")
            guard let strongSelf = self, let currentUser = currentUser else { return }
            strongSelf.pusherChatUser = currentUser

            print(currentUser.rooms.flatMap { String($0.id) }.joined(separator: ", "))

            if currentUser.rooms.count != 0 {
                strongSelf.currentRoom = currentUser.rooms.last!
                currentUser.subscribeToRoom(room: strongSelf.currentRoom!, roomDelegate: strongSelf, messageLimit: 1)

                // Uncomment to send a message to the last room in the currentUser.rooms list, if any

//                let imageName = Bundle.main.path(forResource: "somedog", ofType: "jpg")
//                let imageURL = URL(fileURLWithPath: imageName!)
//
//                print("About to send message")
//
//                currentUser.sendMessage(
//                    roomId: currentUser.rooms.last!.id,
//                    text: "Just a message with an attachment",
//                    attachmentType: .fileURL(imageURL, name: "cucas.jpg")
////                    attachmentType: .link("https://i.giphy.com/RpByGPT5VlZiE.gif", type: "image")
//                ) { messageId, err in
//                    guard err == nil else {
//                        print("Error sending message \(err!.localizedDescription)")
//                        return
//                    }
//                    print("Successfully sent message with ID: \(messageId!)")
//                }
            }
        }
    }
}

extension ViewController: PCRoomDelegate {
    func newMessage(message: PCMessage) {
        print("Room sub received message: \(message.debugDescription)")

        if let attachment = message.attachment {
            if attachment.fetchRequired {
                print("Fetch required for attachment")
                pusherChatUser?.fetchAttachment(attachment.link) { fetchedAttachment, err in
                    guard err == nil else {
                        print("Error fetching attachment \(err!.localizedDescription)")
                        return
                    }

                    print("Fetched attachment link: \(fetchedAttachment!.link)")

                    self.pusherChatUser?.downloadAttachment(
                        fetchedAttachment!.link,
                        to: PCSuggestedDownloadDestination(options: [.createIntermediateDirectories, .removePreviousFile]),
                        onSuccess: { url in
                            print("Downloaded successfully to \(url.absoluteString)")
                        },
                        onError: { error in
                            print("Failed to download \(error.localizedDescription)")
                        },
                        progressHandler: { bytesReceived, totalBytesToReceive in
                            print("Download progress: \(bytesReceived) / \(totalBytesToReceive)")
                        }
                    )
                }
            } else {
                print("Fetch not required for attachment: \(attachment.link)")
            }
        }
    }

    func usersUpdated() {
        print("Users updated " + self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: "; "))
    }

    public func userJoined(user: PCUser) {
        print("User \(user.displayName) joined room: \(self.currentRoom!.name)")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: ","))
    }

    public func userLeft(user: PCUser) {
        print("User \(user.displayName) left room: \(self.currentRoom!.name)")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: ","))
    }

    public func userStartedTyping(user: PCUser) {
        print("\(user.displayName) started typing in room \(self.currentRoom!.name)")
    }

    public func userStoppedTyping(user: PCUser) {
        print("\(user.displayName) stopped typing in room \(self.currentRoom!.name)")
    }

    func userCameOnlineInRoom(user: PCUser) {
        print("\(user.displayName) came online")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: "; "))
    }

    func userWentOfflineInRoom(user: PCUser) {
        print("\(user.displayName) went offline")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: "; "))
    }

    func cursorSet(cursor: PCCursor) {
        print("Cursor set for \(cursor.user.displayName) at position \(cursor.position)")
    }
}

extension ViewController: PCChatManagerDelegate {

    public func addedToRoom(room: PCRoom) {
        print("Added to room: \(room.name)")
    }

    public func removedFromRoom(room: PCRoom) {
        print("Removed from room: \(room.name)")
    }

    public func roomUpdated(room: PCRoom) {
        print("Room updated: \(room.name)")
    }

    public func roomDeleted(room: PCRoom) {
        print("Room deleted: \(room.name)")
    }

    public func userJoinedRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.displayName) joined room: \(room.name)")
    }

    public func userLeftRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.displayName) left room: \(room.name)")
    }

    public func userCameOnline(user: PCUser) {
        print("User \(user.displayName) came online")
    }

    public func userWentOffline(user: PCUser) {
        print("User \(user.displayName) went online")
    }

    public func userStartedTyping(room: PCRoom, user: PCUser) {
        print("\(user.displayName) started typing in room \(room.name)")
    }

    public func userStoppedTyping(room: PCRoom, user: PCUser) {
        print("\(user.displayName) stopped typing in room \(room.name)")
    }

    public func error(error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
