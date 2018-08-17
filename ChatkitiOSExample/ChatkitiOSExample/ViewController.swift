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
        cmDelegate = MyDelegate(
            currentUser: pusherChatUser,
            onMessageReceivedHandler: { message in
                self.messages.append(message)

                DispatchQueue.main.async {
                    self.messagesTableView.reloadData()
                }
            }
        )

        delegate.pusherChat?.connect(delegate: cmDelegate, messageLimit: 1) { [weak self] currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error!)")
                return
            }
            print("Connected!")
            guard let strongSelf = self, let currentUser = currentUser else { return }
            strongSelf.pusherChatUser = currentUser

            print(currentUser.rooms.compactMap { String($0.id) }.joined(separator: ", "))

            if currentUser.rooms.count != 0 {
                strongSelf.currentRoom = currentUser.rooms.last!
//                    Uncomment to send a message to the last room in the currentUser.rooms list, if any
//
//                    let imageName = Bundle.main.path(forResource: "somedog", ofType: "jpg")
//                    let imageURL = URL(fileURLWithPath: imageName!)
//
//                    print("About to send message")
//                    currentUser.sendMessage(
//                        roomId: currentUser.rooms.last!.id,
//                        text: "Just a message with an attachment",
//                        attachment: .fileURL(imageURL, name: "cucas.jpg")
// //                        attachment: .link("https://i.giphy.com/RpByGPT5VlZiE.gif", type: "image")
//                    ) { messageID, err in
//                        guard err == nil else {
//                            print("Error sending message \(err!.localizedDescription)")
//                            return
//                        }
//                    }
//                }
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

public class MyDelegate: PCChatManagerDelegate {
    public weak var cUser: PCCurrentUser?
    let onMessageReceivedHandler: (PCMessage) -> Void

    public init(currentUser: PCCurrentUser?, onMessageReceivedHandler: @escaping (PCMessage) -> Void) {
        self.cUser = currentUser
        self.onMessageReceivedHandler = onMessageReceivedHandler
    }

    public func addedToRoom(_ room: PCRoom) {
        print("Added to room: \(room.name)")
    }

    public func removedFromRoom(_ room: PCRoom) {
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

    public func userStartedTyping(inRoom room: PCRoom, user: PCUser) {
        print("\(user.displayName) started typing in room \(room.name)")
    }

    public func userStoppedTyping(inRoom room: PCRoom, user: PCUser) {
        print("\(user.displayName) stopped typing in room \(room.name)")
    }

    public func newMessage(_ message: PCMessage) {
        print("Room sub received message: \(message.debugDescription)")

        onMessageReceivedHandler(message)

        // Uncomment to test fetching message attachments, if present
        // if let attachment = message.attachment {
        //     if attachment.fetchRequired {
        //         print("Fetch required for attachment")
        //         cUser!.fetchAttachment(attachment.link) { fetchedAttachment, err in
        //             guard err == nil else {
        //                 print("Error fetching attachment \(err!.localizedDescription)")
        //                 return
        //             }

        //             print("Fetched attachment link: \(fetchedAttachment!.link)")

        //             self.cUser!.downloadAttachment(
        //                 fetchedAttachment!.link,
        //                 to: PCSuggestedDownloadDestination(options: [.createIntermediateDirectories, .removePreviousFile]),
        //                 onSuccess: { url in
        //                     print("Downloaded successfully to \(url.absoluteString)")
        //                 },
        //                 onError: { error in
        //                     print("Failed to download \(error.localizedDescription)")
        //                 },
        //                 progressHandler: { bytesReceived, totalBytesToReceive in
        //                     print("Download progress: \(bytesReceived) / \(totalBytesToReceive)")
        //                 }
        //             )
        //         }
        //     } else {
        //         print("Fetch not required for attachment: \(attachment.link)")
        //     }
        // }
    }

    public func newCursor(_ cursor: PCCursor) {
        print("New cursor for \(cursor.user.displayName) at position \(cursor.position)")
    }

    public func error(error: Error) {
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
