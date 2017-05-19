import UIKit
import PusherChat
import PusherPlatform

class ViewController: UIViewController {
    @IBOutlet var feedLabel: UILabel!
    var delegate: AppDelegate!

    public var pusherChatUser: PCCurrentUser? = nil
    public var currentRoom: PCRoom? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate

        // user id 4 on kube, 61 on local
        delegate.pusherChat?.connect(userId: 61, delegate: self) { currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error)")
                return
            }

            print("Connected!")
            self.pusherChatUser = currentUser!

            print(currentUser!.roomStore.rooms.flatMap { String($0.id) }.joined(separator: ", "))
            self.currentRoom = currentUser!.roomStore.rooms[currentUser!.roomStore.rooms.count - 1]
            print(self.currentRoom!.id)

            currentUser!.subscribeToRoom(room: self.currentRoom!, roomDelegate: self)

//            currentUser!.createRoom(name: "hamhamtest") { room, err in
//
//                if let error = err {
//                    print("Error creating room: \(error)")
//                } else {
//                    print("Created room: \(room)")
//                }
//
//            }
        }

    }
}

extension ViewController: PCRoomDelegate {
    func newMessage(_ message: PCMessage) {
        print("Room sub received message: \(message.text)")
    }

    public func userJoined(_ user: PCUser) {
        print("User \(user.name) joined room: \(self.currentRoom?.name)")
    }

    public func userLeft(_ user: PCUser) {
        print("User \(user.name) left room: \(self.currentRoom?.name)")
    }

    public func userStartedTyping(_ user: PCUser) {
        print("\(user.name) started typing in room \(self.currentRoom?.name)")
    }

    public func userStoppedTyping(_ user: PCUser) {
        print("\(user.name) stopped typing in room \(self.currentRoom?.name)")
    }

//    func subscriptionStateChanged(from: PPResumableSubscriptionState, to: PPResumableSubscriptionState) {
//
//    }

    func error(_ error: Error) {
        print("Room sub received error: \(error.localizedDescription)")
    }
}

extension ViewController: PCUserSubscriptionDelegate {
    public func addedToRoom(_ room: PCRoom) {
        print("Added to room: \(room.name)")
    }

    public func removedFromRoom(_ room: PCRoom) {
        print("Removed from room: \(room.name)")
    }

    public func roomUpdated(_ room: PCRoom) {
        print("Room updated: \(room.name)")
    }

    public func roomDeleted(_ room: PCRoom) {
        print("Room deleted: \(room.name)")
    }

    public func userJoinedRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.name) joined room: \(room.name)")
    }

    public func userLeftRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.name) left room: \(room.name)")
    }

    public func userStartedTypingInRoom(_ room: PCRoom, user: PCUser) {
        print("\(user.name) started typing in room \(room.name)")
    }

    public func userStoppedTypingInRoom(_ room: PCRoom, user: PCUser) {
        print("\(user.name) stopped typing in room \(room.name)")
    }

    //    public func error(_ error: Error) {
    //        print("Error: \(error)")
    //    }

    //    public func messageReceived(room: PCRoom, message: PCMessage) {
    //        print("Message received 2 \(message)")
    //    }

}
