import Foundation
import PusherChatkit
import Mockingjay

enum TestHelperError: Error {
    case generic(String)
}

class TestingChatManagerDelegate: PCChatManagerDelegate {
    let handleUserStartedTyping: (PCRoom, PCUser) -> Void
    let handleUserStoppedTyping: (PCRoom, PCUser) -> Void
    let handleUserCameOnline: (PCUser) -> Void
    let handleUserWentOffline: (PCUser) -> Void

    init(
        userStartedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userStoppedTyping: @escaping (PCRoom, PCUser) -> Void = { _, _ in },
        userCameOnline: @escaping (PCUser) -> Void = { _ in },
        userWentOffline: @escaping (PCUser) -> Void = { _ in }
    ) {
        handleUserStartedTyping = userStartedTyping
        handleUserStoppedTyping = userStoppedTyping
        handleUserCameOnline = userCameOnline
        handleUserWentOffline = userWentOffline
    }

    func userStartedTyping(room: PCRoom, user: PCUser) -> Void {
        handleUserStartedTyping(room, user)
    }

    func userStoppedTyping(room: PCRoom, user: PCUser) -> Void {
        handleUserStoppedTyping(room, user)
    }

    func userCameOnline(user: PCUser) -> Void {
        handleUserCameOnline(user)
    }

    func userWentOffline(user: PCUser) -> Void {
        handleUserWentOffline(user)
    }
}

class TestingRoomDelegate: NSObject, PCRoomDelegate {
    let handleNewCursor: (PCCursor) -> Void
    let handleUserStartedTyping: (PCUser) -> Void
    let handleUserStoppedTyping: (PCUser) -> Void
    let handleUserCameOnline: (PCUser) -> Void
    let handleUserWentOffline: (PCUser) -> Void

    init(
        newCursor: @escaping (PCCursor) -> Void = { _ in },
        userStartedTyping: @escaping (PCUser) -> Void = { _ in },
        userStoppedTyping: @escaping (PCUser) -> Void = { _ in },
        userCameOnline: @escaping (PCUser) -> Void = { _ in },
        userWentOffline: @escaping (PCUser) -> Void = { _ in }
    ) {
        handleNewCursor = newCursor
        handleUserStartedTyping = userStartedTyping
        handleUserStoppedTyping = userStoppedTyping
        handleUserCameOnline = userCameOnline
        handleUserWentOffline = userWentOffline
    }

    func newCursor(cursor: PCCursor) -> Void {
        handleNewCursor(cursor)
    }

    func userStartedTyping(user: PCUser) -> Void {
        handleUserStartedTyping(user)
    }

    func userStoppedTyping(user: PCUser) -> Void {
        handleUserStoppedTyping(user)
    }

    func userCameOnline(user: PCUser) -> Void {
        handleUserCameOnline(user)
    }

    func userWentOffline(user: PCUser) -> Void {
        handleUserWentOffline(user)
    }
}

public struct TestLogger: PCLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PCLogLevel) {
        guard logLevel > .debug else { return }
        print("\(message())")
    }
}

func createUser(
    id: String,
    name: String? = nil,
    avatarURL: String? = nil,
    customData: [String: Any]? = nil,
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    var userObject: [String: Any] = [
        "id": id,
        "name": name ?? id
    ]

    if avatarURL != nil {
        userObject["avatar_url"] = avatarURL!
    }

    if customData != nil {
        userObject["custom_data"] = customData!
    }

    guard JSONSerialization.isValidJSONObject(userObject) else {
        completionHandler(.generic("Invalid userObject \(userObject.debugDescription)"))
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: userObject, options: []) else {
        completionHandler(.generic("Failed to JSON serialize userObject \(userObject.debugDescription)"))
        return
    }

    var request = URLRequest(url: testInstanceServiceURL(.server, "users"))
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error creating user: \(error!.localizedDescription)"))
            return
        }

        print("User \(id) created successfully!")
        completionHandler(nil)
    }.resume()
}

func deleteInstanceResources(completionHandler: @escaping (TestHelperError?) -> Void) {
    var request = URLRequest(url: testInstanceServiceURL(.server, "resources"))
    request.httpMethod = "DELETE"
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error deleting instance resources: \(error!.localizedDescription)"))
            return
        }

        print("Instance resources deleted successfully!")
        completionHandler(nil)
    }.resume()
}

let defaultRolePermissions = [
    "message:create",
    "room:join",
    "room:leave",
    "room:members:add",
    "room:members:remove",
    "room:get",
    "room:create",
    "room:messages:get",
    "room:typing_indicator:create",
    "presence:subscribe",
    "user:get",
    "user:rooms:get",
    "file:get",
    "file:create",
    "cursors:read:get",
    "cursors:read:set"
]

let adminRolePermissions = defaultRolePermissions + [
    "room:delete",
    "room:update"
]

func createStandardInstanceRoles(completionHandler: @escaping (TestHelperError?) -> Void) {
    createRole("default", permissions: defaultRolePermissions) { err in
        guard err == nil else {
            completionHandler(err)
            return
        }

        createRole("admin", permissions: adminRolePermissions, completionHandler: completionHandler)
    }
}

func createRole(
    _ name: String,
    permissions: [String],
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    let roleObject: [String: Any] = [
        "name": name,
        "scope": "global",
        "permissions": permissions
    ]

    guard JSONSerialization.isValidJSONObject(roleObject) else {
        completionHandler(.generic("Invalid roleObject \(roleObject.debugDescription)"))
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: roleObject, options: []) else {
        completionHandler(.generic("Failed to JSON serialize roleObject \(roleObject.debugDescription)"))
        return
    }

    var request = URLRequest(url: testInstanceServiceURL(.authorizer, "roles"))
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error creating role: \(error!.localizedDescription)"))
            return
        }

        print("Role \(name) created successfully!")
        completionHandler(nil)
    }.resume()
}

func generateSuperuserToken() -> String {
    var claims = ClaimSet()
    claims.issuer = "api_keys/\(testInstanceKeyID)"
    claims.issuedAt = Date()
    claims.expiration = Date().addingTimeInterval(TimeInterval(86400))
    claims["su"] = true
    claims["instance"] = testInstanceInstanceID

    return encode(claims: claims)
}

func testInstanceServiceURL(_ service: ChatkitService, _ path: String) -> URL {
    return serviceURL(instanceLocator: testInstanceLocator, service: service, path: path)
}

func serviceURL(instanceLocator: String, service: ChatkitService, path: String) -> URL {
    let splitInstanceLocator = instanceLocator.split(separator: ":")
    let instanceCluster = splitInstanceLocator[1]
    let instanceID = splitInstanceLocator.last!
    let pathlessURL = URL(string: "https://\(instanceCluster).pusherplatform.io/services/\(service.stringValue())/v1/\(instanceID)")!
    return pathlessURL.appendingPathComponent(path)
}

enum ChatkitService {
    case server
    case authorizer
    case presence
    case cursors

    func stringValue() -> String {
        switch self {
        case .server: return "chatkit"
        case .authorizer: return "chatkit_authorizer"
        case .presence: return "chatkit_presence"
        case .cursors: return "chatkit_cursors"
        }
    }
}

func newTestChatManager(
    userId: String,
    delegate: PCChatManagerDelegate = TestingChatManagerDelegate()
) -> ChatManager {
    return ChatManager(
        instanceLocator: testInstanceLocator,
        tokenProvider: PCTokenProvider(url: testInstanceTokenProviderURL),
        userId: userId,
        logger: TestLogger()
    )
}

func dataSubscriptionEventFor(_ eventJSON: String) -> Data {
    let noNewlineEventString = eventJSON.replacingOccurrences(of: "\n", with: "")
    let wrappedInitialStateEvent = "[1, \"\", {}, \(noNewlineEventString)]\n"
    return wrappedInitialStateEvent.data(using: .utf8)!
}

func successResponseForRequest(_ request: URLRequest, withEvents events: [SubscriptionEvent]) -> Response {
    let res = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
    return .success(res, .streamSubscription(events: events))
}
