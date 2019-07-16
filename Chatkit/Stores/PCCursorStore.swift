import Foundation
import PusherPlatform

final class PCCursorStore {
    unowned let instance: Instance
    let roomStore: PCRoomStore
    let userStore: PCGlobalUserStore
    let basicCursorEnricher: PCBasicCursorEnricher
    private var synchronizedCursors: PCSynchronizedDictionary<PCCursorKey, PCCursor> = [:]
    
    var cursors: [PCCursorKey : PCCursor] {
        return synchronizedCursors.dictionary()
    }

    init(instance: Instance, roomStore: PCRoomStore, userStore: PCGlobalUserStore) {
        self.instance = instance
        self.roomStore = roomStore
        self.userStore = userStore
        self.basicCursorEnricher = PCBasicCursorEnricher(
            userStore: userStore,
            roomStore: roomStore,
            logger: instance.logger
        )
    }

    func get(userID: String, roomID: String, completionHandler: @escaping (PCCursor?, Error?) -> Void) {
        self.findOrGetCursor(userID: userID, roomID: roomID, completionHandler: completionHandler)
    }

    func getSync(userID: String, roomID: String) -> PCCursor? {
        return self.synchronizedCursors.first(where: { $0.key == cursorKey(userID, roomID) })?.value
    }

    func set(_ basicCursor: PCBasicCursor, completionHandler: ((PCCursor?, Error?) -> Void)? = nil) {
        self.basicCursorEnricher.enrich(basicCursor) { cursor, err in
            guard let cursor = cursor, err == nil else {
                self.instance.logger.log(
                    "Error when enriching basic cursor: \(err!.localizedDescription)",
                    logLevel: .error
                )
                completionHandler?(nil, err!)
                return
            }
            self.set(userID: basicCursor.userID, roomID: basicCursor.roomID, cursor: cursor)
            completionHandler?(cursor, nil)
        }
    }

    fileprivate func set(userID: String, roomID: String, cursor: PCCursor) {
        self.synchronizedCursors[cursorKey(userID, roomID)] = cursor
    }

    func findOrGetCursor(userID: String, roomID: String, completionHandler: @escaping (PCCursor?, Error?) -> Void) {
        if let cursorObj = self.synchronizedCursors.first(where: { $0.key == cursorKey(userID, roomID) }) {
            completionHandler(cursorObj.value, nil)
        } else {
            self.getCursor(userID: userID, roomID: roomID) { cursor, err in
                guard err == nil else {
                    self.instance.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHandler(nil, err!)
                    return
                }

                completionHandler(cursor!, nil)
            }
        }
    }

    func getCursor(userID: String, roomID: String, completionHandler: @escaping (PCCursor?, Error?) -> Void) {
        let path = "/cursors/\(PCCursorType.read.rawValue)/rooms/\(roomID)/users/\(userID)"
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

    private func cursorKey(_ userID: String, _ roomID: String) -> PCCursorKey {
        return PCCursorKey(userID: userID, roomID: roomID)
    }
}

struct PCCursorKey: Hashable {
    let userID: String
    let roomID: String
}
