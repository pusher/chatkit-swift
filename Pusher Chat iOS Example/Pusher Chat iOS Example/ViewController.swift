import UIKit
import PusherChat
import PusherPlatform

class ViewController: UIViewController {
    @IBOutlet var feedLabel: UILabel!
    var delegate: AppDelegate!

    public var pusherChatUser: PCCurrentUser? = nil

    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate

        // user id 4 on kube, 60 on local
        delegate.pusherChat?.connect(userId: 60, delegate: self) { currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error)")
                return
            }

            print("Connected!")
            self.pusherChatUser = currentUser!

//            self.getJoinableRooms()
//
//            DispatchQueue.main.async {
//                self.tableView.reloadData()
//            }


            print(currentUser!.roomStore.rooms.flatMap { String($0.id) }.joined(separator: ", "))

            let room = currentUser!.roomStore.rooms[currentUser!.roomStore.rooms.count - 1]

            print(room.id)

            currentUser!.subscribeToRoom(room: room, roomDelegate: self)

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

    func subscriptionStateChanged(from: PPResumableSubscriptionState, to: PPResumableSubscriptionState) {

    }

    func error(_ error: Error) {
        print("Room sub received error: \(error.localizedDescription)")
    }
}

extension ViewController: PCUserSubscriptionDelegate {
    public func addedToRoom(_ room: PCRoom) {
        print("Added to room: \(room.name)")

//        self.pusherChatUser!.getRoom(id: room.id) { roomWithUsers, err in
//            if err != nil {
//                print("Error when getting room: \(err)")
//            } else {
//                room.users = roomWithUsers!.users
//            }
//        }
    }

    public func userStartedTyping(_ room: PCRoom, user: PCUser) {
        print("\(user.name) started typing in room \(room.name)")
    }

    public func userStoppedTyping(_ room: PCRoom, user: PCUser) {
        print("\(user.name) stopped typing in room \(room.name)")
    }

    public func removedFromRoom(_ room: PCRoom) {
        print("Removed from room: \(room.name)")
    }

    public func messageReceived(room: PCRoom, message: PCMessage) {
        print("Message received 2 \(message)")
    }

//    public func error(_ error: Error) {
//        print("Error: \(error)")
//    }

    public func userJoinedRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.name) joined room: \(room.name)")
    }

    public func userLeftRoom(_ room: PCRoom, user: PCUser) {
        print("User \(user.name) left room: \(room.name)")
    }

    public func roomDeleted(_ room: PCRoom) {
        print("Room deleted: \(room.name)")
    }

    public func roomUpdated(_ room: PCRoom) {
        print("Room updated: \(room.name)")
    }

}
