import Foundation
import CoreData
import PusherPlatform

class DataSimulator {
    
    // MARK: - Properties
    
    let persistenceController: PersistenceController
    
    private var referenceDate: Date?
    private var timer: Timer?
    private var entries: [(date: Date, event: Event)]
    
    private var nextMessageIdentifier: Int
    
    var currentUserID: NSManagedObjectID?
    var firstUserID: NSManagedObjectID?
    var secondUserID: NSManagedObjectID?
    var thirdUserID: NSManagedObjectID?
    var fourthUserID: NSManagedObjectID?
    var fifthUserID: NSManagedObjectID?
    var sixthUserID: NSManagedObjectID?
    var seventhUserID: NSManagedObjectID?
    var eighthUserID: NSManagedObjectID?
    var ninthUserID: NSManagedObjectID?
    var tenthUserID: NSManagedObjectID?
    var eleventhUserID: NSManagedObjectID?
    
    var firstRoomID: NSManagedObjectID?
    var secondRoomID: NSManagedObjectID?
    var thirdRoomID: NSManagedObjectID?
    var fourthRoomID: NSManagedObjectID?
    var fifthRoomID: NSManagedObjectID?
    var sixthRoomID: NSManagedObjectID?
    var seventhRoomID: NSManagedObjectID?
    var eighthRoomID: NSManagedObjectID?
    var ninthRoomID: NSManagedObjectID?
    var tenthRoomID: NSManagedObjectID?
    var eleventhRoomID: NSManagedObjectID?
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.nextMessageIdentifier = 0
        self.entries = []
    }
    
    // MARK: - Internal methods
    
    func start(completionHandler: @escaping (User) -> Void) {
        guard self.timer == nil, self.referenceDate == nil else {
            fatalError("Data simulator should be started only once.")
        }
        
        self.referenceDate = Date()
        
        self.loadInitialState { currentUser in
            self.scheduleAllEvents()
            
            self.timer = Timer.scheduledTimer(timeInterval: 1.0, target: self, selector: #selector(self.tick(_:)), userInfo: nil, repeats: true)
            
            completionHandler(currentUser)
        }
    }
    
    func schedule(_ event: Event, after timeInterval: TimeInterval) {
        guard let referenceDate = self.referenceDate else {
            return
        }
        
        let date = referenceDate + timeInterval
        let index = self.entries.firstIndex { $0.date > date } ?? self.entries.endIndex
        
        self.entries.insert((date: date, event: event), at: index)
    }
    
    func calculateMessageIdentifier() -> String {
        let identifier = String(self.nextMessageIdentifier)
        
        self.nextMessageIdentifier += 1
        
        return identifier
    }
    
    // MARK: - Timers
    
    @objc private func tick(_ sender: Timer) {
        let lastIndex = self.entries.lastIndex { $0.date <= sender.fireDate }
        
        guard let index = lastIndex else {
            return
        }
        
        let range = 0..<self.entries.index(after: index)
        let entries = self.entries[range]
        
        self.entries.removeSubrange(range)
        
        for entry in entries {
            entry.event.execute(persistenceController: self.persistenceController)
        }
    }
    
    // MARK: - Memory management
    
    deinit {
        self.timer?.invalidate()
    }
    
}

// MARK: - Event

extension DataSimulator {
    
    struct Event {
        
        // MARK: - Properties
        
        let content: (PersistenceController) -> Void
        
        // MARK: - Internal methods
        
        func execute(persistenceController: PersistenceController) {
            self.content(persistenceController)
        }
        
    }
    
}
