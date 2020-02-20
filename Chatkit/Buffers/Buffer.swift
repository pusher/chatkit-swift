
protocol Buffer: StoreListener {
    
    var delegate: BufferDelegate? { get set }
    
}

// MARK: - Concrete implementation

class ConcreteBuffer: Buffer {
    
    // MARK: - Types
    
    typealias Dependencies = HasStateFilter & HasStoreBroadcaster
    
    // MARK: - Properties
    
    private(set) var currentState: VersionedState?
    private var queue: [VersionedState]
    
    private let dependencies: Dependencies
    
    weak var delegate: BufferDelegate?
    
    // MARK: - Initializers
    
    init(dependencies: Dependencies, delegate: BufferDelegate?) {
        self.currentState = nil
        self.queue = []
        self.delegate = delegate
        self.dependencies = dependencies
        
        self.registerListener()
    }
    
    // MARK: - Store listener
    
    func store(_ store: Store, didUpdateState state: VersionedState) {
        self.apply(state: state)
    }
    
    // MARK: - Private methods
    
    private func registerListener() {
        let state = self.dependencies.storeBroadcaster.register(self)
        
        if self.dependencies.stateFilter.hasCompleteSubstate(state) {
            self.currentState = state
        }
        else {
            // The current state of the store cannot be reported until it gets supplemented by one of the subsequent states.
            self.enqueue(state: state)
        }
    }
    
    private func apply(state: VersionedState) {
        self.enqueueIfNeeded(state: state)
        self.flush(withSupplementalState: state)
    }
    
    private func enqueueIfNeeded(state: VersionedState) {
        if let currentState = self.currentState {
            let lastState = self.queue.last ?? currentState
            
            if self.dependencies.stateFilter.hasSupportedSignature(state.signature)
                && self.dependencies.stateFilter.hasModifiedSubstate(oldState: lastState, newState: state) {
                self.enqueue(state: state)
            }
        }
        else if self.dependencies.stateFilter.hasSupportedSignature(state.signature) {
            self.enqueue(state: state)
        }
    }
    
    private func enqueue(state: VersionedState) {
        self.queue.append(state)
    }
    
    private func flush(withSupplementalState supplementalState: VersionedState) {
        var flushedQueue = self.queue
        
        for (index, state) in flushedQueue.enumerated() {
            if self.dependencies.stateFilter.hasCompleteSubstate(state) {
                self.delegate?.buffer(self, didUpdateState: state)
                flushedQueue.remove(at: index)
            }
            else {
                let supplementedState = state.supplement(withState: supplementalState)
                
                if self.dependencies.stateFilter.hasCompleteSubstate(supplementedState) {
                    self.delegate?.buffer(self, didUpdateState: supplementedState)
                    flushedQueue.remove(at: index)
                }
                else {
                    break
                }
            }
        }
        
        self.queue = flushedQueue
    }
    
    // MARK: - Memory management
    
    deinit {
        self.dependencies.storeBroadcaster.unregister(self)
    }
    
}

// MARK: - Delegate

protocol BufferDelegate: AnyObject {
    
    func buffer(_ buffer: Buffer, didUpdateState state: VersionedState)
    
}

// MARK: - Dependencies

protocol HasBuffer {
    
    var buffer: Buffer { get }
    
}
