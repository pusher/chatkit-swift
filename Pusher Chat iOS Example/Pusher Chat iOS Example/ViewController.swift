import UIKit
import PusherChat
import PusherPlatform

class ViewController: UIViewController {
    @IBOutlet var feedLabel: UILabel!
    var delegate: AppDelegate!

    public var pusherChatUser: PCCurrentUser?
    public var currentRoom: PCRoom?

    override func viewDidLoad() {
        super.viewDidLoad()

        let delegate = UIApplication.shared.delegate as! AppDelegate

        delegate.pusherChat?.connect(delegate: self) { [weak self] currentUser, error in
            guard error == nil else {
                print("Error connecting: \(error!)")
                return
            }

            print("Connected!")

            guard
                let strongSelf = self,
                let currentUser = currentUser
            else { return }

            strongSelf.pusherChatUser = currentUser

            print(currentUser.rooms.flatMap { String($0.id) }.joined(separator: ", "))

            if currentUser.rooms.count != 0 {
                strongSelf.currentRoom = currentUser.rooms[0]
                currentUser.subscribeToRoom(room: strongSelf.currentRoom!, roomDelegate: strongSelf)
            }
        }
    }
}

extension ViewController: PCRoomDelegate {
    func newMessage(message: PCMessage) {
        print("Room sub received message: \(message.text)")
    }

    func usersUpdated() {
        print("Users updated " + self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: "; "))
    }

    public func userJoined(user: PCUser) {
        print("User \(user.name ?? user.id) joined room: \(self.currentRoom!.name)")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: ","))
    }

    public func userLeft(user: PCUser) {
        print("User \(user.name ?? user.id) left room: \(self.currentRoom!.name)")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: ","))
    }

    public func userStartedTyping(user: PCUser) {
        print("\(user.name ?? user.id) started typing in room \(self.currentRoom!.name)")
    }

    public func userStoppedTyping(user: PCUser) {
        print("\(user.name ?? user.id) stopped typing in room \(self.currentRoom!.name)")
    }

    func userCameOnlineInRoom(user: PCUser) {
        print("\(user.name ?? user.id) came online")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: "; "))
    }

    func userWentOfflineInRoom(user: PCUser) {
        print("\(user.name ?? user.id) went offline")
        print(self.currentRoom!.users.map { "\($0.id), \($0.name!), \($0.presenceState.rawValue)" }.joined(separator: "; "))
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

    public func userCameOnline(user: PCUser) {
        print("User \(user.name ?? user.id) came online")
    }

    public func userWentOffline(user: PCUser) {
        print("User \(user.name ?? user.id) went online")
    }

    public func userStartedTyping(room: PCRoom, user: PCUser) {
        print("\(user.name ?? user.id) started typing in room \(room.name)")
    }

    public func userStoppedTyping(room: PCRoom, user: PCUser) {
        print("\(user.name ?? user.id) stopped typing in room \(room.name)")
    }

    public func error(error: Error) {
        print("Error: \(error.localizedDescription)")
    }
}
