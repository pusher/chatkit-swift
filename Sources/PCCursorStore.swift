import Foundation
import PusherPlatform

public final class PCCursorStore {
    public let instance: Instance
    let roomStore: PCRoomStore
    let userStore: PCGlobalUserStore
    let basicCursorEnricher: PCBasicCursorEnricher

    public var cursors: [String: PCCursor] = [:]

    public init(instance: Instance, roomStore: PCRoomStore, userStore: PCGlobalUserStore) {
        self.instance = instance
        self.roomStore = roomStore
        self.userStore = userStore
        self.basicCursorEnricher = PCBasicCursorEnricher(
            userStore: userStore,
            roomStore: roomStore,
            logger: instance.logger
        )
    }

    public func get(userId: String, roomId: Int, completionHandler: @escaping (PCCursor?, Error?) -> Void) {
        self.findOrGetCursor(userId: userId, roomId: roomId, completionHandler: completionHandler)
    }

    public func getSync(userId: String, roomId: Int) -> PCCursor? {
        return self.cursors.first(where: { $0.key == key(userId, roomId) })?.value
    }

    public func set(_ basicCursor: PCBasicCursor, completionHandler: ((PCCursor?, Error?) -> Void)? = nil) {
        self.basicCursorEnricher.enrich(basicCursor) { cursor, err in
            guard let cursor = cursor, err == nil else {
                self.instance.logger.log(
                    "Error when enriching basic cursor: \(err!.localizedDescription)",
                    logLevel: .error
                )
                completionHandler?(nil, err!)
                return
            }
            self.set(userId: basicCursor.userId, roomId: basicCursor.roomId, cursor: cursor)
            completionHandler?(cursor, nil)
        }
    }

    fileprivate func set(userId: String, roomId: Int, cursor: PCCursor) {
        self.cursors[key(userId, roomId)] = cursor
    }

    func findOrGetCursor(userId: String, roomId: Int, completionHandler: @escaping (PCCursor?, Error?) -> Void) {
        if let cursorObj = self.cursors.first(where: { $0.key == key(userId, roomId) }) {
            completionHandler(cursorObj.value, nil)
        } else {
            self.getCursor(userId: userId, roomId: roomId) { cursor, err in
                guard err == nil else {
                    self.instance.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHandler(nil, err!)
                    return
                }

                completionHandler(cursor!, nil)
            }
        }
    }

    func getCursor(userId: String, roomId: Int, completionHandler: @escaping (PCCursor?, Error?) -> Void) {
        let path = "/cursors/\(PCCursorType.read.rawValue)/rooms/\(roomId)/users/\(userId)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let cursorPayload = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                do {
                    let basicCursor = try PCPayloadDeserializer.createBasicCursorFromPayload(cursorPayload)
                    self.basicCursorEnricher.enrich(basicCursor) { cursor, err in
                        guard let cursor = cursor, err == nil else {
                            self.instance.logger.log(
                                "Error when enriching basic cursor: \(err!.localizedDescription)",
                                logLevel: .error
                            )
                            completionHandler(nil, err!)
                            return
                        }
                        completionHandler(cursor, nil)
                    }
                } catch let err {
                    self.instance.logger.log(err.localizedDescription, logLevel: .error)
                    completionHandler(nil, err)
                    return
                }
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

    fileprivate func key(_ userId: String, _ roomId: Int) -> String {
        return "\(userId)/\(roomId)"
    }
}
