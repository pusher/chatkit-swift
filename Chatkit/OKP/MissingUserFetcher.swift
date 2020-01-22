import enum PusherPlatform.HTTPMethod
import class PusherPlatform.PPRequestOptions



protocol HasMissingUserFetcher {
    var missingUserFetcher: MissingUserFetcher { get }
}

protocol MissingUserFetcher: StoreListener {
    
}

class ConcreteMissingUserFetcher: MissingUserFetcher {
    
    typealias Dependencies = HasUserService & HasStore
    
    private let dependencies: Dependencies
    
    init(dependencies: Dependencies) {
        self.dependencies = dependencies
    }
    
    // MARK: StoreListener
    
    func store(_ store: Store, didUpdateState state: State) {
    
        // Check if there's a user missing AND its not already in process of being fetched!
        let missingUserIdentifier = "blah"
        
        // Notify store that we are fetching the user
        let action = Action.fetching(userWithIdentifier: missingUserIdentifier)
        self.dependencies.store.action(action)
        
        self.dependencies.userService.fetchUser(withIdentifier: missingUserIdentifier) { result in
            
            switch result {
            case .success:
                print("unimplemented")
                fatalError()
                
            case  let .failure(error):
                // TODO FAILURE needs some thought
                print("unimplemented: \(error)")
                fatalError()
            }
        }
        
    }
    
}
