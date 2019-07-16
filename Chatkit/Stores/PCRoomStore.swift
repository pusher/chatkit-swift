import Foundation
import PusherPlatform

final class PCRoomStore {

    var rooms: [PCRoom] {
        return synchronizedRooms.clone()
    }
    
    private var synchronizedRooms: PCSynchronizedArray<PCRoom>
    private unowned let instance: Instance

    init(rooms: [PCRoom], instance: Instance) {
        self.instance = instance
        
        self.synchronizedRooms = PCSynchronizedArray(rooms)
    }

    func room(id: String, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        self.findOrGetRoom(id: id, completionHandler: completionHandler)
    }

    func addOrMerge(_ room: PCRoom) -> PCRoom {
        return self.synchronizedRooms.appendOrUpdate(
            room,
            predicate: { $0.id == room.id }
        )
    }

    @discardableResult
    func addOrMergeSync(_ room: PCRoom) -> PCRoom {
        return self.synchronizedRooms.appendOrUpdate(room, predicate: { $0.id == room.id })
    }

    func removeSync(id: String) -> PCRoom? {
        return self.synchronizedRooms.remove(where: { $0.id == id })
    }

    func findOrGetRoom(id: String, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
        if let room = self.synchronizedRooms.first(where: { $0.id == id }) {
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

    func getRoom(id: String, completionHandler: @escaping (PCRoom?, Error?) -> Void) {
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
