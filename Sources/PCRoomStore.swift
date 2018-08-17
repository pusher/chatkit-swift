import Foundation
import PusherPlatform

public final class PCRoomStore {

    public var rooms: PCSynchronizedArray<PCRoom>
    public let instance: Instance
    var preCompletionHooks: [(PCRoom, @escaping () -> Void) -> Void]

    public init(rooms: PCSynchronizedArray<PCRoom>, instance: Instance) {
        self.rooms = rooms
        self.instance = instance
        self.preCompletionHooks = []
    }

    public func room(id: Int, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        self.findOrGetRoom(id: id, completionHandler: completionHandler)
    }

    func addOrMerge(_ room: PCRoom, completionHandler: @escaping (PCRoom) -> Void) {
        // TODO: Maybe we need to create a synchronisation point here? Or maybe changing the
        // rooms to be an ordered set would make it easier?
        if let existingRoom = self.rooms.first(where: { $0.id == room.id }) {
            existingRoom.updateWithPropertiesOfRoom(room)
            let handler = steppedCompletionHandler(
                steps: preCompletionHooks.count,
                inner: { completionHandler(existingRoom) },
                dispatchQueue: DispatchQueue(label: "com.pusher.chatkit.subscribe-to-new-room")
            )
            preCompletionHooks.forEach { $0(existingRoom, handler) }
        } else {
            self.rooms.appendAndComplete(room) { addedRoom in
                let handler = steppedCompletionHandler(
                    steps: self.preCompletionHooks.count,
                    inner: { completionHandler(addedRoom) },
                    dispatchQueue: DispatchQueue(label: "com.pusher.chatkit.subscribe-to-new-room")
                )
                self.preCompletionHooks.forEach { $0(addedRoom, handler) }
            }
        }
    }

    @discardableResult
    func addOrMergeSync(_ room: PCRoom) -> PCRoom {
        if let existingRoom = self.rooms.first(where: { $0.id == room.id }) {
            existingRoom.updateWithPropertiesOfRoom(room)
            return existingRoom
        } else {
            return self.rooms.appendSync(room)
        }
    }

    func remove(id: Int, completionHandler: ((PCRoom?) -> Void)? = nil) {
        return self.rooms.remove(where: { $0.id == id }, completionHandler: completionHandler)
    }

    func findOrGetRoom(id: Int, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        if let room = self.rooms.first(where: { $0.id == id }) {
            completionHandler(room, nil)
        } else {
            self.getRoom(id: id) { room, err in
                guard err == nil else {
                    self.instance.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHandler(nil, err!)
                    return
                }

                completionHandler(room!, nil)
            }
        }
    }

    func getRoom(id: Int, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        let path = "/rooms/\(id)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        self.instance.requestWithRetry(
            using: generalRequest,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    completionHandler(nil, PCError.failedToDeserializeJSON(data))
                    return
                }

                guard let roomPayload = jsonObject as? [String: Any] else {
                    completionHandler(nil, PCError.failedToCastJSONObjectToDictionary(jsonObject))
                    return
                }

                do {
                    let room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
                    completionHandler(room, nil)
                } catch let err {
                    self.instance.logger.log(err.localizedDescription, logLevel: .debug)
                    completionHandler(nil, err)
                    return
                }
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }
}
