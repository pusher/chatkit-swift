import Foundation
import PusherPlatform
import PushNotifications

private struct ChatkitBeamsToken: Decodable {
    let token: String
}

@objc final class ChatkitBeamsTokenProvider: NSObject, TokenProvider {

    private let instance: Instance

    init(instance: Instance) {
        self.instance = instance
    }

    func fetchToken(userId: String, completionHandler completion: @escaping (String, Error?) -> Void) {
        let request = PPRequestOptions(method: HTTPMethod.GET.rawValue, path: "/beams-tokens")
        request.addQueryItems([URLQueryItem(name: "user_id", value: userId)])
        self.instance.request(using: request, onSuccess: { (data) in
            guard let token = try? JSONDecoder().decode(ChatkitBeamsToken.self, from: data).token else {
                return completion("", PCTokenProviderError.failedToDeserializeJSON(data))
            }

            completion(token, nil)
        }) { (error) in
            completion("", error)
        }
    }
}
