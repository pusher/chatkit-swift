@testable import PusherChatkit

public struct TestState {
    
    // MARK: - Properties
    
    public static let userIdentifier = "alice"
    
    public static let user = UserState.populated(
        identifier: userIdentifier,
        name: "Alice A"
    )
    
    public static let userList = UserListState(
        users: [
            userIdentifier : UserState.populated(
                identifier: userIdentifier,
                name: "Alice A"
            )
        ]
    )
    
}
