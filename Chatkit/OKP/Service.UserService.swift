import enum PusherPlatform.HTTPMethod
import class PusherPlatform.PPRequestOptions


protocol HasUserService {
    var userService: UserService { get }
}

protocol UserService {
    func fetchUser(withIdentifier identifier: String, handler: @escaping (Result<Void, Error>) -> Void)
}

class ConcreteUserService: UserService {
    
    typealias Dependencies = HasInstanceFactory & HasStore
    
    private let dependencies: Dependencies
    
    private let instance: Instance
    private let jsonDecoder = JSONDecoder.default
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
        // TODO fix this call
        self.instance = self.dependencies.instanceFactory.makeInstance(forType: .service(.user))
    }
    
    func fetchUser(withIdentifier identifier: String, handler: @escaping (Result<Void, Error>) -> Void) {
        
        // TODO work out what this path is
        let requestPath = "/user/\(identifier)"
        let requestOptions = PPRequestOptions(method: HTTPMethod.SUBSCRIBE.rawValue, path: requestPath)
        
        let onSuccess = { (jsonData: Data) in
            
            do {
                // TODO move elsewhere `UserServiceResponder`?
                let user = try self.jsonDecoder.decode(Wire.User.self, from: jsonData)
                let action = Action.received(user: user)
                
                // TODO Is the order of these calls important?
                self.dependencies.store.action(action)
                handler(.success(()))
            }
            catch {
                print(error)
                handler(.failure(error))
            }
        }
        
        let onError = { (error: Error) in
            handler(.failure(error))
        }
        
        let _ = instance.request(using: requestOptions,
                                 onSuccess: onSuccess,
                                 onError: onError)
    }
    
}
