
protocol Buffer: StoreListener {
    
    var currentState: VersionedState? { get }
    var delegate: BufferDelegate? { get set }
    
}

// MARK: - Concrete implementation

class ConcreteBuffer: Buffer {
    
    // MARK: - Types
    
    typealias Dependencies = HasStore
    
    // MARK: - Properties
    
    private(set) var currentState: VersionedState?
    private var queue: [VersionedState]
    private let filter: StateFilter
    private let dependencies: Dependencies
    
    weak var delegate: BufferDelegate?
    
    // MARK: - Initializers
    
    init(filter: StateFilter, dependencies: Dependencies) {
        self.currentState = nil
        self.queue = []
        self.filter = filter
        self.dependencies = dependencies
        
        self.registerListener()
    }
    
    // MARK: - Store listener
    
    func store(_ store: Store, didUpdateState state: VersionedState) {
        self.apply(state: state)
    }
    
    // MARK: - Private methods
    
    private func registerListener() {
        let state = self.dependencies.store.register(self)
        
        if self.filter.hasCompleteSubstate(state) {
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
            
            if self.filter.hasRelevantSignature(state.signature)
                && self.filter.hasModifiedSubstate(oldState: lastState, newState: state) {
                self.enqueue(state: state)
            }
        }
        else if self.filter.hasRelevantSignature(state.signature) {
            self.enqueue(state: state)
        }
    }
    
    private func enqueue(state: VersionedState) {
        self.queue.append(state)
    }
    
    private func flush(withSupplementalState supplementalState: VersionedState) {
        var removedIndexes: [Int] = []
        
        for (index, state) in self.queue.enumerated() {
            if self.filter.hasCompleteSubstate(state) {
                self.currentState = state
                self.delegate?.buffer(self, didUpdateState: state)
                removedIndexes.append(index)
            }
            else {
                let supplementedState = state.supplement(withState: supplementalState)
                
                if self.filter.hasCompleteSubstate(supplementedState) {
                    self.currentState = supplementedState
                    self.delegate?.buffer(self, didUpdateState: supplementedState)
                    removedIndexes.append(index)
                }
                else {
                    break
                }
            }
        }
        
        var flushedQueue = self.queue
        
        for index in removedIndexes.reversed() {
            flushedQueue.remove(at: index)
        }
        
        self.queue = flushedQueue
    }
    
    // MARK: - Memory management
    
    deinit {
        self.dependencies.store.unregister(self)
    }
    
}

// MARK: - Delegate

protocol BufferDelegate: AnyObject {
    
    func buffer(_ buffer: Buffer, didUpdateState state: VersionedState)
    
}
