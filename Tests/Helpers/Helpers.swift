import Foundation
import PusherChatkit
import Mockingjay

enum TestHelperError: Error {
    case generic(String)
}

public struct TestLogger: PCLogger {
    public func log(_ message: @autoclosure @escaping () -> String, logLevel: PCLogLevel) {
        guard logLevel >= .info else { return }
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

    var request = URLRequest(url: testInstanceServiceURL(.server, "v2", "users"))
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error creating user: \(error!.localizedDescription)"))
            return
        }

        TestLogger().log("User \(id) created successfully!", logLevel: .debug)
        completionHandler(nil)
    }.resume()
}

func createUsers(
    users: [[String: Any]],
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    let usersObject: [String: [[String: Any]]] = [
        "users": users
    ]

    guard JSONSerialization.isValidJSONObject(usersObject) else {
        completionHandler(.generic("Invalid usersObject \(usersObject.debugDescription)"))
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: usersObject, options: []) else {
        completionHandler(.generic("Failed to JSON serialize usersObject \(usersObject.debugDescription)"))
        return
    }

    var request = URLRequest(url: testInstanceServiceURL(.server, "v2", "batch_users"))
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error creating users: \(error!.localizedDescription)"))
            return
        }

        TestLogger().log("Users created successfully!", logLevel: .debug)
        completionHandler(nil)
    }.resume()
}

func updateUser(
    id: String,
    name: String? = nil,
    avatarURL: String? = nil,
    customData: [String: Any]? = nil,
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    var userObject = [String: Any]()

    if name != nil {
        userObject["name"] = name!
    }

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

    var request = URLRequest(url: testInstanceServiceURL(.server, "v2", "users/\(id)"))
    request.httpMethod = "PUT"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error updating user: \(error!.localizedDescription)"))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.generic("Error updating user"))
            return
        }

        if 200..<300 ~= httpResponse.statusCode {
            TestLogger().log("User \(id) updated successfully!", logLevel: .debug)
            completionHandler(nil)
        } else {
            let errorDesc = error?.localizedDescription ?? "no error"
            completionHandler(.generic("Error updating user: status \(httpResponse.statusCode), error: \(errorDesc)"))
        }
    }.resume()
}

func deleteInstanceResources(completionHandler: @escaping (TestHelperError?) -> Void) {
    var request = URLRequest(url: testInstanceServiceURL(.server, "v2", "resources"))
    request.httpMethod = "DELETE"
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error deleting instance resources: \(error!.localizedDescription)"))
            return
        }

        TestLogger().log("Instance resources deleted successfully!", logLevel: .debug)
        completionHandler(nil)
    }.resume()
}

func deleteMessage(roomID: String, messageID: Int, completionHandler: @escaping (TestHelperError?) -> Void) {
    var request = URLRequest(url: testInstanceServiceURL(.server, "v5", "rooms/\(roomID)/messages/\(messageID)"))
    request.httpMethod = "DELETE"
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error deleting message: \(error!.localizedDescription)"))
            return
        }

        TestLogger().log("Message deleted successfully!", logLevel: .debug)
        completionHandler(nil)
    }.resume()
}

func synchronousHTTPRequest(
    url: String,
    method: String,
    headers: [String: String]?
) -> (Data?, URLResponse?, Error?) {
    var request = URLRequest(url: URL(string: url)!)
    if headers != nil {
        for (headerKey, headerValue) in headers! {
            request.addValue(headerValue, forHTTPHeaderField: headerKey)
        }
    }

    var data: Data? = nil
    var response: URLResponse? = nil
    var error: Error? = nil

    let sem = DispatchSemaphore(value: 0)
    URLSession.shared.dataTask(with: request) { respData, resp, err in
        data = respData
        response = resp
        error = err
        sem.signal()
    }.resume()
    sem.wait()

    return (data, response, error)
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

    var request = URLRequest(url: testInstanceServiceURL(.authorizer, "v2", "roles"))
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error creating role: \(error!.localizedDescription)"))
            return
        }

        TestLogger().log("Role \(name) created successfully!", logLevel: .debug)
        completionHandler(nil)
    }.resume()
}

func assignGlobalRole(
    _ roleName: String,
    toUser userID: String,
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    let roleObject: [String: Any] = ["name": roleName]

    guard JSONSerialization.isValidJSONObject(roleObject) else {
        completionHandler(.generic("Invalid roleObject \(roleObject.debugDescription)"))
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: roleObject, options: []) else {
        completionHandler(.generic("Failed to JSON serialize roleObject \(roleObject.debugDescription)"))
        return
    }

    var request = URLRequest(url: testInstanceServiceURL(.authorizer, "v2", "users/\(userID)/roles"))
    request.httpMethod = "PUT"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error assigning role: \(error!.localizedDescription)"))
            return
        }

        TestLogger().log("Role \(roleName) assigned to \(userID) successfully!", logLevel: .debug)
        completionHandler(nil)
    }.resume()
}

func testInstanceServiceURL(_ service: ChatkitService, _ version: String = "v1", _ path: String) -> URL {
    return serviceURL(instanceLocator: testInstanceLocator, service: service, version: version, path: path)
}

func serviceURL(
    instanceLocator: String,
    service: ChatkitService,
    version: String,
    path: String,
    queryItems: [URLQueryItem]? = nil
) -> URL {
    let splitInstanceLocator = instanceLocator.split(separator: ":")
    let instanceCluster = splitInstanceLocator[1]
    let instanceID = splitInstanceLocator.last!

    var urlComponents = URLComponents(string: "https://\(instanceCluster).pusherplatform.io")!

    var sanitisedPath = path
    if sanitisedPath.hasPrefix("/") {
        sanitisedPath.remove(at: sanitisedPath.startIndex)
    }
    let fullPath = "/services/\(service.stringValue())/\(version)/\(instanceID)/\(sanitisedPath)"

    urlComponents.percentEncodedPath = fullPath
    urlComponents.queryItems = queryItems

    return urlComponents.url!
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
    userID: String,
    delegate: PCChatManagerDelegate = TestingChatManagerDelegate()
) -> ChatManager {
    return ChatManager(
        instanceLocator: testInstanceLocator,
        tokenProvider: PCTokenProvider(url: testInstanceTokenProviderURL),
        userID: userID,
        logger: TestLogger()
    )
}

func createRoom(
    creatorID: String,
    name: String,
    isPrivate: Bool? = nil,
    customData: [String: Any]? = nil,
    addUserIDs userIDs: [String]? = nil,
    completionHandler: @escaping (TestHelperError?, Data?) -> Void
) {
    var roomObject: [String: Any] = ["name": name]

    if isPrivate != nil {
        roomObject["private"] = isPrivate!
    }

    if customData != nil {
        roomObject["custom_data"] = customData!
    }

    if userIDs != nil && userIDs!.count > 0 {
        roomObject["user_ids"] = userIDs
    }

    guard JSONSerialization.isValidJSONObject(roomObject) else {
        completionHandler(.generic("Invalid roomObject \(roomObject.debugDescription)"), nil)
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: roomObject, options: []) else {
        completionHandler(.generic("Failed to JSON serialize roomObject \(roomObject.debugDescription)"), nil)
        return
    }

    var request = URLRequest(url: testInstanceServiceURL(.server, "v2", "rooms"))
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken(sub: creatorID))", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error creating room: \(error!.localizedDescription)"), nil)
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.generic("Error creating room"), nil)
            return
        }

        if 200..<300 ~= httpResponse.statusCode {
            TestLogger().log("Room created successfully!", logLevel: .debug)
            completionHandler(nil, data)
        } else {
            let errorDesc = error?.localizedDescription ?? "no error"
            completionHandler(.generic("Error creating room: status \(httpResponse.statusCode), error: \(errorDesc)"), nil)
        }
    }.resume()
}


func updateRoom(
    id: String,
    name: String? = nil,
    isPrivate: Bool? = nil,
    customData: [String: Any]? = nil,
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    var roomObject = [String: Any]()

    if name != nil {
        roomObject["name"] = name!
    }

    if isPrivate != nil {
        roomObject["private"] = isPrivate!
    }

    if customData != nil {
        roomObject["custom_data"] = customData!
    }

    guard JSONSerialization.isValidJSONObject(roomObject) else {
        completionHandler(.generic("Invalid roomObject \(roomObject.debugDescription)"))
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: roomObject, options: []) else {
        completionHandler(.generic("Failed to JSON serialize roomObject \(roomObject.debugDescription)"))
        return
    }

    var request = URLRequest(url: testInstanceServiceURL(.server, "v2", "rooms/\(id)"))
    request.httpMethod = "PUT"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error updating room: \(error!.localizedDescription)"))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.generic("Error updating room"))
            return
        }

        if 200..<300 ~= httpResponse.statusCode {
            TestLogger().log("Room \(id) updated successfully!", logLevel: .debug)
            completionHandler(nil)
        } else {
            let errorDesc = error?.localizedDescription ?? "no error"
            completionHandler(.generic("Error updating room: status \(httpResponse.statusCode), error: \(errorDesc)"))
        }
    }.resume()
}

func setReadCursor(
    userID: String,
    roomID: String,
    position: Int,
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    let cursorObject = ["position": position]

    guard JSONSerialization.isValidJSONObject(cursorObject) else {
        completionHandler(.generic("Invalid cursorObject \(cursorObject.debugDescription)"))
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: cursorObject, options: []) else {
        completionHandler(.generic("Failed to JSON serialize cursorObject \(cursorObject.debugDescription)"))
        return
    }

    let path = "/cursors/\(PCCursorType.read.rawValue)/rooms/\(roomID)/users/\(userID)"
    var request = URLRequest(url: testInstanceServiceURL(.cursors, "v2", path))
    request.httpMethod = "PUT"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error setting read cursor: \(error!.localizedDescription)"))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.generic("Error setting read cursor"))
            return
        }

        if 200..<300 ~= httpResponse.statusCode {
            TestLogger().log("Read cursor set successfully!", logLevel: .debug)
            completionHandler(nil)
        } else {
            let errorDesc = error?.localizedDescription ?? "no error"
            completionHandler(.generic("Error setting read cursor: status \(httpResponse.statusCode), error: \(errorDesc)"))
        }
    }.resume()
}

func addUserToRoom(
    roomID: String,
    userID: String,
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    addOrRemoveUsers(
        roomID: roomID,
        userIDs: [userID],
        membershipChange: .add,
        completionHandler: completionHandler
    )
}

func removeUserFromRoom(
    roomID: String,
    userID: String,
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    addOrRemoveUsers(
        roomID: roomID,
        userIDs: [userID],
        membershipChange: .remove,
        completionHandler: completionHandler
    )
}

func sendMessage(
    asUser senderID: String,
    toRoom roomID: String,
    text: String = "",
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    let messageObject: [String: Any] = ["text": text]

    guard JSONSerialization.isValidJSONObject(messageObject) else {
        completionHandler(.generic("Invalid messageObject \(messageObject.debugDescription)"))
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: messageObject, options: []) else {
        completionHandler(.generic("Failed to JSON serialize messageObject \(messageObject.debugDescription)"))
        return
    }

    var request = URLRequest(url: testInstanceServiceURL(.server, "v2", "rooms/\(roomID)/messages"))
    request.httpMethod = "POST"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken(sub: senderID))", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error sending message: \(error!.localizedDescription)"))
            return
        }

        TestLogger().log("Message sent successfully!", logLevel: .debug)
        completionHandler(nil)
    }.resume()
}

fileprivate enum PCUserMembershipChange: String {
    case add
    case remove
}

fileprivate func addOrRemoveUsers(
    roomID: String,
    userIDs: [String],
    membershipChange: PCUserMembershipChange,
    completionHandler: @escaping (TestHelperError?) -> Void
) {
    let userPayload = ["user_ids": userIDs]

    guard JSONSerialization.isValidJSONObject(userPayload) else {
        completionHandler(.generic("Invalid userPayload \(userPayload.debugDescription)"))
        return
    }

    guard let data = try? JSONSerialization.data(withJSONObject: userPayload, options: []) else {
        completionHandler(.generic("Failed to JSON serialize userPayload \(userPayload.debugDescription)"))
        return
    }

    let path = "/rooms/\(roomID)/users/\(membershipChange.rawValue)"
    var request = URLRequest(url: testInstanceServiceURL(.server, "v2", path))
    request.httpMethod = "PUT"
    request.httpBody = data
    request.addValue("Bearer \(generateSuperuserToken())", forHTTPHeaderField: "Authorization")
    request.addValue("application/json", forHTTPHeaderField: "Content-Type")

    URLSession.shared.dataTask(with: request) { data, response, error in
        guard error == nil else {
            completionHandler(.generic("Error making room membership change: \(error!.localizedDescription)"))
            return
        }

        guard let httpResponse = response as? HTTPURLResponse else {
            completionHandler(.generic("Error making room membership change"))
            return
        }

        if 200..<300 ~= httpResponse.statusCode {
            TestLogger().log("Room membership change completed successfully!", logLevel: .debug)
            completionHandler(nil)
        } else {
            let errorDesc = error?.localizedDescription ?? "no error"
            completionHandler(.generic("Error making room membership change: status \(httpResponse.statusCode), error: \(errorDesc)"))
        }
    }.resume()
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

extension Array {
    func all(fn: (Element) -> Bool) -> Bool {
        return self.reduce(true) { $0 && fn($1) }
    }

    func any(fn: (Element) -> Bool) -> Bool {
        return self.reduce(false) { $0 || fn($1) }
    }
}
