import Foundation
import PusherPlatform

final public class PCRoomStore {

    public var rooms: PCSynchronizedArray<PCRoom>
    public let app: App

    public init(rooms: PCSynchronizedArray<PCRoom>, app: App) {
        self.rooms = rooms
        self.app = app
    }

    public func room(id: Int, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        self.findOrGetRoom(id: id, completionHander: completionHandler)
    }

    func addOrMerge(_ room: PCRoom, completionHandler: @escaping (PCRoom) -> Void) {

        // TODO: Maybe we need to create a synchronisation point here? Or maybe changing the
        // rooms to be an ordered set would make it easier?

        if let existingRoom = self.rooms.first(where: { $0.id == room.id }) {
            existingRoom.updateWithPropertiesOfRoom(room)
            completionHandler(existingRoom)
        } else {
            self.rooms.appendAndComplete(room, completionHandler: completionHandler)
        }
    }

    func remove(id: Int, completionHandler: ((PCRoom?) -> Void)? = nil) {
        return self.rooms.remove(where: { $0.id == id }, completionHandler: completionHandler)
    }

    func findOrGetRoom(id: Int, completionHander: @escaping (PCRoom?, Error?) -> Void) {
        if let room = self.rooms.first(where: { $0.id == id }) {
            completionHander(room, nil)
        } else {
            self.getRoom(id: id) { room, err in
                guard err == nil else {
                    self.app.logger.log(err!.localizedDescription, logLevel: .error)
                    completionHander(nil, err!)
                    return
                }

                completionHander(room!, nil)
            }
        }
    }

    func getRoom(id: Int, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        let path = "/\(ChatManager.namespace)/rooms/\(id)"
        let generalRequest = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: path)

        self.app.requestWithRetry(
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
                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
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
