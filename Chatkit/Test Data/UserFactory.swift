import Foundation

class UserFactory {
    
    func receiveMoreUsers(numberOfUsers: Int, lastUserIdentifier: String, delay: TimeInterval, completionHandler: @escaping ([User]) -> Void) {
        guard let lastUserIdentifier = Int(lastUserIdentifier) else {
            completionHandler([])
            return
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay) {
            let now = Date()
            let firstUserIdentifier = lastUserIdentifier + 1
            
            let users = (firstUserIdentifier..<(firstUserIdentifier + numberOfUsers)).map {
                User(identifier: "\($0)",
                    name: "User \($0)",
                    avatar: nil,
                    presenceState: .unknown,
                    metadata: nil,
                    createdAt: now,
                    updatedAt: now,
                    objectID: UserEntityFactory.currentUserID)
            }
            
            completionHandler(users)
        }
    }
    
}
