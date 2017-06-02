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

        delegate.pusherChat?.connect(userId: "ham", delegate: self) { currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error!)")
                return
            }

            print("Connected!")
            self.pusherChatUser = currentUser!

            print(currentUser!.rooms.flatMap { String($0.id) }.joined(separator: ", "))
            self.currentRoom = currentUser!.rooms[0]
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
    func newMessage(message: PCMessage) {
        print("Room sub received message: \(message.text)")
    }

    func usersPopulated() {
        print("User list has been populated: \(self.currentRoom!.users.map { $0.name! }.joined(separator: ","))")
    }

    public func userJoined(user: PCUser) {
        print("User \(user.name ?? user.id) joined room: \(self.currentRoom!.name)")
    }

    public func userLeft(user: PCUser) {
        print("User \(user.name ?? user.id) left room: \(self.currentRoom!.name)")
    }

    public func userStartedTyping(user: PCUser) {
        print("\(user.name ?? user.id) started typing in room \(self.currentRoom!.name)")
    }

    public func userStoppedTyping(user: PCUser) {
        print("\(user.name ?? user.id) stopped typing in room \(self.currentRoom!.name)")
    }

    func userCameOnline(user: PCUser) {
        print("\(user.name ?? user.id) came online")
    }

    func userWentOffline(user: PCUser) {
        print("\(user.name ?? user.id) went offline")
    }

//    func subscriptionStateChanged(from: PPResumableSubscriptionState, to: PPResumableSubscriptionState) {
//
//    }

    func error(error: Error) {
        print("Room sub received error: \(error.localizedDescription)")
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
        print("User \(user.name ?? user.id) joined room: \(room.name)")
    }

    public func userLeftRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.name ?? user.id) left room: \(room.name)")
    }

    public func userStartedTyping(room: PCRoom, user: PCUser) {
        print("\(user.name ?? user.id) started typing in room \(room.name)")
    }

    public func userStoppedTyping(room: PCRoom, user: PCUser) {
        print("\(user.name ?? user.id) stopped typing in room \(room.name)")
    }

    //    public func error(_ error: Error) {
    //        print("Error: \(error)")
    //    }

    //    public func messageReceived(room: PCRoom, message: PCMessage) {
    //        print("Message received 2 \(message)")
    //    }

}
