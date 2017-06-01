import Foundation
import PusherPlatform

public class PCRoomStore {

    public var rooms: PCSynchronizedArray<PCRoom>
    public let app: App

    public init(rooms: PCSynchronizedArray<PCRoom>, app: App) {
        self.rooms = rooms
        self.app = app
    }

    public func room(id: Int, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        self.findOrGetRoom(id: id, completionHander: completionHandler)
    }

    func add(_ room: PCRoom) {
        self.rooms.append(room)
    }

    func remove(id: Int) -> PCRoom? {
        return self.rooms.remove(where: { $0.id == id })
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

                // TODO: Should the room be added to the currentUser?

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

                let room: PCRoom

                do {
                    room = try PCPayloadDeserializer.createRoomFromPayload(roomPayload)
                } catch let err {
                    self.app.logger.log(err.localizedDescription, logLevel: .debug)
                    completionHandler(nil, err)
                    return
                }

                completionHandler(room, nil)
            },
            onError: { error in
                completionHandler(nil, error)
            }
        )
    }

}
