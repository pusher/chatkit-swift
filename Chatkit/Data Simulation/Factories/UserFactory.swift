import Foundation

class UserFactory {
    
    func receiveUsers(numberOfUsers: Int, lastUserIdentifier: String, delay: TimeInterval, completionHandler: @escaping ([User]) -> Void) {
        guard let lastUserIdentifier = Int(lastUserIdentifier) else {
            completionHandler([])
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let now = Date()
            let firstUserIdentifier = lastUserIdentifier + 1
            
            let users = (firstUserIdentifier..<(firstUserIdentifier + numberOfUsers)).map {
                User(identifier: "user\($0)@pusher.com",
                    name: "User \($0)",
                    avatar: nil,
                    presenceState: .unknown,
                    customData: nil,
                    createdAt: now,
                    updatedAt: now,
                    objectID: nil!) // FIXME: Make this optional for data that is not supposed to be persisted.
            }
            
            completionHandler(users)
        }
    }
    
}
