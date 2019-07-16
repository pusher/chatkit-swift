import UIKit
import PusherChatkit

class ViewController: UIViewController {
    @IBOutlet weak var messagesTableView: UITableView!

    var delegate: AppDelegate!
    var cmDelegate: PCChatManagerDelegate!
    var pusherChatUser: PCCurrentUser?
    var currentRoom: PCRoom?
    var messages = [PCMessage]()

    @IBAction func disconnectButton(_ sender: Any) {
        print("About to disconnect from Chatkit")
        delegate.pusherChat?.disconnect()
    }

    @IBAction func reconnectButton(_ sender: Any) {
        print("About to reconnect to Chatkit")
        connectToChatkit()
    }

    @IBAction func sendMessageButton(_ sender: Any) {
        print("About to send a message")
        sendRandomMessage()
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        delegate = (UIApplication.shared.delegate as! AppDelegate)
        messagesTableView.delegate = self
        messagesTableView.dataSource = self
        connectToChatkit()
    }

    func connectToChatkit() {
        cmDelegate = MyDelegate()

        delegate.pusherChat?.connect(delegate: cmDelegate) { [weak self] currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error!)")
                return
            }
            print("Connected!")
            guard let strongSelf = self, let currentUser = currentUser else { return }
            strongSelf.pusherChatUser = currentUser

            // Enable Push Notifications service.
            strongSelf.pusherChatUser?.enablePushNotifications()

            print(currentUser.rooms.compactMap { String($0.id) }.joined(separator: ", "))

            if currentUser.rooms.count != 0 {
                strongSelf.currentRoom = currentUser.rooms.last!
                currentUser.subscribeToRoom(
                    room: strongSelf.currentRoom!,
                    roomDelegate: strongSelf,
                    messageLimit: 1
                ) { err in
                    guard err == nil else {
                        print("Error subscribing to room: \(strongSelf.currentRoom!.debugDescription)")
                        return
                    }

                    // Uncomment to send a message to the last room in the currentUser.rooms list, if any

//                    let imageName = Bundle.main.path(forResource: "somedog", ofType: "jpg")
//                    let imageURL = URL(fileURLWithPath: imageName!)

//                    print("About to send message")
//                    currentUser.sendMessage(
//                        roomId: currentUser.rooms.last!.id,
//                        text: "Just a message with an attachment",
//                        attachment: .fileURL(imageURL, name: "somedog.jpg")
////                        attachment: .link("https://i.giphy.com/RpByGPT5VlZiE.gif", type: "image")
//                    ) { messageID, err in
//                        guard err == nil else {
//                            print("Error sending message \(err!.localizedDescription)")
//                            return
//                        }
//                    }
                }
            }
        }
    }

    func sendRandomMessage() {
        let messageText = "Some random message \(arc4random_uniform(1001))"
        self.pusherChatUser!.sendMessage(
            roomID: currentRoom!.id,
            text: messageText
        ) { messageID, err in
            guard err == nil else {
                print("Error sending message \(err!.localizedDescription)")
                return
            }

            print("Message successfully sent with ID \(messageID!)")
        }
    }
}

extension ViewController: PCRoomDelegate {
    func onUsersUpdated() {
        print("Users updated " + self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: "; "))
    }

    func onUserJoined(user: PCUser) {
        print("User \(user.displayName) joined room: \(self.currentRoom!.name)")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: ","))
    }

    func onUserLeft(user: PCUser) {
        print("User \(user.displayName) left room: \(self.currentRoom!.name)")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: ","))
    }

    func onUserStartedTyping(user: PCUser) {
        print("\(user.displayName) started typing in room \(self.currentRoom!.name)")
    }

    func onUserStoppedTyping(user: PCUser) {
        print("\(user.displayName) stopped typing in room \(self.currentRoom!.name)")
    }

    public func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser) {
        print("\(user.displayName)'s presence state went from \(stateChange.previous.rawValue) to \(stateChange.current.rawValue)")
    }

    func onNewReadCursor(_ cursor: PCCursor) {
        print("New cursor for \(cursor.user.displayName) at position \(cursor.position)")
    }

    func onMessage(_ message: PCMessage) {
        print("Received message: \(message.debugDescription)")

        self.messages.append(message)

        DispatchQueue.main.async {
            self.messagesTableView.reloadData()
        }

//        Uncomment to test fetching message attachments, if present

//        if let attachment = message.attachment {
//            self.pusherChatUser?.downloadAttachment(
//                attachment.link,
//                to: PCSuggestedDownloadDestination(options: [.createIntermediateDirectories, .removePreviousFile]),
//                onSuccess: { url in
//                    print("Downloaded successfully to \(url.absoluteString)")
//                },
//                onError: { error in
//                    print("Failed to download \(error.localizedDescription)")
//                },
//                progressHandler: { bytesReceived, totalBytesToReceive in
//                    print("Download progress: \(bytesReceived) / \(totalBytesToReceive)")
//                }
//            )
//        }
    }
}

public class MyDelegate: PCChatManagerDelegate {
    public func onAddedToRoom(_ room: PCRoom) {
        print("Added to room: \(room.name)")
    }

    public func onRemovedFromRoom(_ room: PCRoom) {
        print("Removed from room: \(room.name)")
    }

    public func onRoomUpdated(room: PCRoom) {
        print("Room updated: \(room.name)")
    }

    public func onRoomDeleted(room: PCRoom) {
        print("Room deleted: \(room.name)")
    }

    public func onUserJoinedRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.displayName) joined room: \(room.name)")
    }

    public func onUserLeftRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.displayName) left room: \(room.name)")
    }

    public func onPresenceChanged(stateChange: PCPresenceStateChange, user: PCUser) {
        print("\(user.displayName)'s presence state went from \(stateChange.previous.rawValue) to \(stateChange.current.rawValue)")
    }

    public func onUserStartedTyping(inRoom room: PCRoom, user: PCUser) {
        print("\(user.displayName) started typing in room \(room.name)")
    }

    public func onUserStoppedTyping(inRoom room: PCRoom, user: PCUser) {
        print("\(user.displayName) stopped typing in room \(room.name)")
    }

    public func onError(error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}

extension ViewController: UITableViewDelegate {}

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return messages.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "MessageCell", for: indexPath)
        let message = messages.reversed()[indexPath.row]
        let senderDisplayName = message.sender.displayName
        let messageText = message.text
        cell.textLabel?.text = "\(senderDisplayName): \(messageText)"
        return cell
    }
}
