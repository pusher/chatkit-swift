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
    
    var serversideMessages: [NSManagedObjectID : [ServersideMessage]]
    
    let data = [
        DummyRoom(planName: "Nutrition", otherUser: DummyUser(identifier: "oliver", name: "Oliver"), messages: [
            .initial(seconds: 1000, sentByCurrentUser: false, content: "Hello")
        ]),
        DummyRoom(planName: "Exercise", otherUser: DummyUser(identifier: "george", name: "George"), messages: [
            .serverside(days: 2, seconds: 50, sentByCurrentUser: false, content: "Hi!"),
            .serverside(days: 2, seconds: 45, sentByCurrentUser: true, content: "Hi George!"),
            .serverside(days: 2, seconds: 40, sentByCurrentUser: true, content: "How can I help you?"),
            .serverside(days: 2, seconds: 35, sentByCurrentUser: false, content: "I am interested in your offer 🏋️‍♂️"),
            .serverside(days: 2, seconds: 30, sentByCurrentUser: true, content: "Should I send you our brochure?"),
            .serverside(days: 2, seconds: 25, sentByCurrentUser: false, content: "Yes, please"),
            .serverside(days: 2, seconds: 20, sentByCurrentUser: true, content: "Done 👍"),
            .serverside(days: 2, seconds: 15, sentByCurrentUser: false, content: "Thank you!"),
            .serverside(days: 2, seconds: 10, sentByCurrentUser: false, content: "Bye bye"),
            .serverside(days: 2, seconds: 59, sentByCurrentUser: true, content: "Bye"),
            .initial(days: 1, seconds: 50, sentByCurrentUser: false, content: "Hello"),
            .initial(days: 1, seconds: 45, sentByCurrentUser: false, content: "It's me again"),
            .initial(days: 1, seconds: 40, sentByCurrentUser: false, content: "I am interested in subscribing to one of your exercise plans 💰"),
            .initial(days: 1, seconds: 35, sentByCurrentUser: true, content: "Hi George!"),
            .initial(days: 1, seconds: 30, sentByCurrentUser: true, content: "That is great to hear"),
            .initial(days: 1, seconds: 25, sentByCurrentUser: true, content: "Which plan would you like to pick?"),
            .initial(days: 1, seconds: 20, sentByCurrentUser: false, content: "The basic one 💪"),
            .initial(days: 1, seconds: 15, sentByCurrentUser: true, content: "I will send a subscription link to your email address"),
            .initial(days: 1, seconds: 10, sentByCurrentUser: false, content: "Thank you! Bye bye"),
            .initial(days: 1, seconds: 5, sentByCurrentUser: true, content: "Bye"),
            .initial(seconds: 40, sentByCurrentUser: false, content: "Hi Olivia"),
            .initial(seconds: 20, sentByCurrentUser: false, content: "I finished my first daily routine"),
            .initial(seconds: 10, sentByCurrentUser: false, content: "Unfortunately, I feel completely exhausted now 😰"),
            .scheduled(after: 4, sentByCurrentUser: true, content: "Hi George"),
            .scheduled(after: 6, sentByCurrentUser: true, content: "Did you manage do complete the whole routine?"),
            .scheduled(after: 11, sentByCurrentUser: false, content: "Yes, I did 😎"),
            .scheduled(after: 15, sentByCurrentUser: true, content: "Where there any elements of the routine that were especially hard for you?"),
            .scheduled(after: 17, sentByCurrentUser: false, content: "I struggled with push-ups 😐"),
            .scheduled(after: 21, sentByCurrentUser: true, content: "Perhaps we could reduce the number of push-ups for you and see if that helps tomorrow?"),
            .scheduled(after: 23, sentByCurrentUser: false, content: "That sound great! 👍"),
            .scheduled(after: 25, sentByCurrentUser: true, content: "I will amend your daily routine to include that change"),
            .scheduled(after: 27, sentByCurrentUser: false, content: "Thank you! Bye bye"),
            .scheduled(after: 29, sentByCurrentUser: true, content: "Bye")
        ]),
        DummyRoom(planName: "Latin", otherUser: DummyUser(identifier: "noah", name: "Noah"), messages: [
            .serverside(days: 2, seconds: 320, sentByCurrentUser: false, content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
            .serverside(days: 2, seconds: 310, sentByCurrentUser: true, content: "Duis tempus ante non nisi feugiat commodo."),
            .serverside(days: 2, seconds: 280, sentByCurrentUser: false, content: "Lorem ipsum dolor sit amet, consectetur adipiscing elit."),
            .serverside(days: 2, seconds: 270, sentByCurrentUser: false, content: "Praesent mattis ligula id ligula porta efficitur."),
            .serverside(days: 2, seconds: 260, sentByCurrentUser: true, content: "Fusce non felis ut quam egestas accumsan."),
            .serverside(days: 2, seconds: 230, sentByCurrentUser: true, content: "Nam ornare volutpat sem non auctor."),
            .serverside(days: 2, seconds: 210, sentByCurrentUser: false, content: "Phasellus ac elementum enim."),
            .serverside(days: 2, seconds: 120, sentByCurrentUser: true, content: "Proin finibus leo vel turpis consectetur lobortis."),
            .serverside(days: 2, seconds: 110, sentByCurrentUser: false, content: "Nullam quis consectetur leo."),
            .serverside(days: 2, seconds: 100, sentByCurrentUser: false, content: "Nulla eleifend semper massa vitae pharetra."),
            .serverside(days: 2, seconds: 90, sentByCurrentUser: true, content: "Nulla pulvinar, lectus a ultrices molestie, eros velit porta justo, vel tincidunt velit odio ac eros."),
            .serverside(days: 2, seconds: 80, sentByCurrentUser: false, content: "Nunc ac faucibus neque."),
            .serverside(days: 2, seconds: 60, sentByCurrentUser: true, content: "Nam tempus eleifend nibh, ut aliquet risus consectetur eu."),
            .serverside(days: 2, seconds: 30, sentByCurrentUser: false, content: "Duis mauris elit, blandit ac nisl vel, dignissim venenatis nulla."),
            .initial(days: 2, seconds: 20, sentByCurrentUser: false, content: "Vestibulum ante ipsum primis in faucibus orci luctus et ultrices posuere cubilia Curae;"),
            .initial(days: 1, seconds: 820, sentByCurrentUser: true, content: "Mauris tincidunt fermentum sapien eu pellentesque."),
            .initial(days: 1, seconds: 720, sentByCurrentUser: true, content: "Nunc quis rutrum felis, ut interdum ligula."),
            .initial(days: 1, seconds: 620, sentByCurrentUser: false, content: "Nulla faucibus varius erat vel facilisis."),
            .initial(days: 1, seconds: 520, sentByCurrentUser: false, content: "Aenean tempus leo in eleifend posuere."),
            .initial(days: 1, seconds: 420, sentByCurrentUser: false, content: "Aliquam ornare magna diam, a consequat neque sodales sit amet."),
            .initial(days: 0, seconds: 90, sentByCurrentUser: true, content: "Aliquam a orci in elit dictum semper in ut dui."),
            .initial(days: 0, seconds: 50, sentByCurrentUser: false, content: "Vestibulum feugiat consequat lacinia."),
            .initial(days: 0, seconds: 20, sentByCurrentUser: true, content: "Maecenas dapibus sapien nisl, sed interdum nibh suscipit eu.")
        ]),
        DummyRoom(planName: "Film Quote", otherUser: DummyUser(identifier: "alan", name: "Alan"), messages: [
            .serverside(seconds: 320, sentByCurrentUser: true, content: "What are you doing here?"),
            .serverside(seconds: 325, sentByCurrentUser: false, content: "Uh, the lady told me to wait."),
            .serverside(seconds: 310, sentByCurrentUser: true, content: "In my office?"),
            .serverside(seconds: 315, sentByCurrentUser: true, content: "Did she tell you to help yourself to tea while you were here?"),
            .serverside(seconds: 300, sentByCurrentUser: false, content: "Uh... No, she didn't"),
            .serverside(seconds: 305, sentByCurrentUser: true, content: "She obviously didn't tell you what a joke was then, either, I gather?"),
            .serverside(seconds: 290, sentByCurrentUser: false, content: "Was she supposed to?"),
            .serverside(seconds: 295, sentByCurrentUser: true, content: "Who are you?"),
            .serverside(seconds: 280, sentByCurrentUser: false, content: "Alan Turing."),
            .serverside(seconds: 285, sentByCurrentUser: true, content: "Ah, Turing. The mathematician."),
            .serverside(seconds: 270, sentByCurrentUser: false, content: "Correct."),
            .serverside(seconds: 275, sentByCurrentUser: true, content: "However could I have guessed?"),
            .serverside(seconds: 260, sentByCurrentUser: false, content: "You didn't."),
            .serverside(seconds: 265, sentByCurrentUser: false, content: "You just read it on that piece of paper."),
            .serverside(seconds: 250, sentByCurrentUser: false, content: "King's College, Cambridge."),
            .serverside(seconds: 255, sentByCurrentUser: true, content: "Now it says here you were a bit of a prodigy in the Maths Department."),
            .serverside(seconds: 240, sentByCurrentUser: false, content: "I'm not sure I can evaluate that, Mr..."),
            .serverside(seconds: 245, sentByCurrentUser: true, content: "How old are you, Mr Turing?"),
            .serverside(seconds: 230, sentByCurrentUser: false, content: "Uh, 27."),
            .serverside(seconds: 235, sentByCurrentUser: true, content: "And how old were you when you became a fellow at Cambridge?"),
            .serverside(seconds: 220, sentByCurrentUser: false, content: "Twenty-four."),
            .serverside(seconds: 225, sentByCurrentUser: true, content: "And how old were you when you published this paper that has a title I can barely understand?"),
            .serverside(seconds: 210, sentByCurrentUser: false, content: "Uh, 23."),
            .serverside(seconds: 215, sentByCurrentUser: true, content: "And you don't think that qualifies you as a certified prodigy?"),
            .serverside(seconds: 200, sentByCurrentUser: false, content: "Well, Newton discovered Binomial Theorem aged 22."),
            .serverside(seconds: 205, sentByCurrentUser: false, content: "Einstein wrote four papers that changed the world by the age of 26."),
            .serverside(seconds: 190, sentByCurrentUser: false, content: "As far as I can tell, I've...  I've barely made par."),
            .serverside(seconds: 195, sentByCurrentUser: true, content: "My God, you're serious."),
            .serverside(seconds: 180, sentByCurrentUser: false, content: "Would you prefer I made a joke?"),
            .serverside(seconds: 185, sentByCurrentUser: true, content: "Oh, I don't think you know what those are."),
            .serverside(seconds: 170, sentByCurrentUser: false, content: "Hardly seems fair that that's a requirement for employment here, Mr..."),
            .serverside(seconds: 175, sentByCurrentUser: true, content: "Commander Denniston, Royal Navy."),
            .serverside(seconds: 160, sentByCurrentUser: true, content: "All right, Mr Turing, I'll bite."),
            .serverside(seconds: 165, sentByCurrentUser: true, content: "Why do you wish to work for His Majesty's Government?"),
            .serverside(seconds: 150, sentByCurrentUser: false, content: "Oh, I don't, really."),
            .serverside(seconds: 155, sentByCurrentUser: true, content: "Are you a bleeding pacifist?"),
            .serverside(seconds: 140, sentByCurrentUser: false, content: "I'm agnostic about violence."),
            .serverside(seconds: 145, sentByCurrentUser: true, content: "But you do realise that 600 miles away from London there's this nasty little chap called Hitler who wants to engulf Europe in tyranny?"),
            .serverside(seconds: 130, sentByCurrentUser: false, content: "Politics isn't really my area of expertise."),
            .serverside(seconds: 135, sentByCurrentUser: true, content: "Really?"),
            .serverside(seconds: 120, sentByCurrentUser: true, content: "Well, I believe you've just set the record for the shortest job interview in British military history."),
            .serverside(seconds: 125, sentByCurrentUser: false, content: "Mother says I can be off-putting sometimes on account of being one of the best mathematicians in the world."),
            .serverside(seconds: 110, sentByCurrentUser: true, content: "In the world?"),
            .serverside(seconds: 115, sentByCurrentUser: false, content: "Oh, yes."),
            .initial(seconds: 110, sentByCurrentUser: true, content: "Do you know how many people I've rejected for this programme?"),
            .initial(seconds: 105, sentByCurrentUser: false, content: "No."),
            .initial(seconds: 100, sentByCurrentUser: true, content: "That's right."),
            .initial(seconds: 95, sentByCurrentUser: true, content: "Because we're a top secret programme."),
            .initial(seconds: 80, sentByCurrentUser: true, content: "But I'll tell you, just because we're friends, that only last week I rejected one of our great nation's top linguists."),
            .initial(seconds: 75, sentByCurrentUser: true, content: "Knows German better than Bertolt Brecht."),
            .initial(seconds: 70, sentByCurrentUser: false, content: "I don't speak German."),
            .initial(seconds: 65, sentByCurrentUser: true, content: "What?"),
            .initial(seconds: 60, sentByCurrentUser: false, content: "I don't speak German."),
            .initial(seconds: 55, sentByCurrentUser: true, content: "Well, how the hell are you supposed to decrypt German communications if you don't..."),
            .initial(seconds: 50, sentByCurrentUser: false, content: "I don't know, speak German?"),
            .initial(seconds: 45, sentByCurrentUser: false, content: "Well, I'm really quite excellent at crossword puzzles."),
            .initial(seconds: 40, sentByCurrentUser: false, content: "German codes are a puzzle."),
            .initial(seconds: 35, sentByCurrentUser: false, content: "A game just like any other game."),
            .initial(seconds: 30, sentByCurrentUser: false, content: "I'm really very good at games, uh, puzzles."),
            .initial(seconds: 25, sentByCurrentUser: false, content: "And this is the most difficult puzzle in the world."),
            .initial(seconds: 20, sentByCurrentUser: true, content: "For the love of God."),
            .initial(seconds: 15, sentByCurrentUser: true, content: "This is a joke, obviously."),
            .initial(seconds: 10, sentByCurrentUser: false, content: "I'm afraid I don't know what those are, Commander Denniston"),
            .initial(seconds: 5, sentByCurrentUser: true, content: "Have a pleasant trip back to Cambridge, Professor."),
            .scheduled(after: 005, sentByCurrentUser: false, content: "Enigma."),
            .scheduled(after: 008, sentByCurrentUser: false, content: "That's what you're doing here."),
            .scheduled(after: 010, sentByCurrentUser: false, content: "The top secret programme at Bletchley."),
            .scheduled(after: 012, sentByCurrentUser: false, content: "You're trying to break the German Enigma machine."),
            .scheduled(after: 016, sentByCurrentUser: true, content: "What makes you think that?"),
            .scheduled(after: 022, sentByCurrentUser: false, content: "It's the greatest encryption device in history and the Germans use it for all major communications."),
            .scheduled(after: 027, sentByCurrentUser: false, content: "If the Allies broke Enigma, well, this would turn into a very short war indeed."),
            .scheduled(after: 030, sentByCurrentUser: false, content: "Of course that's what you're working on."),
            .scheduled(after: 040, sentByCurrentUser: false, content: "You also haven't got anywhere with it."),
            .scheduled(after: 045, sentByCurrentUser: false, content: "If you had, you wouldn't be hiring cryptographers out of university."),
            .scheduled(after: 048, sentByCurrentUser: false, content: "You need me a lot more than I need you."),
            .scheduled(after: 051, sentByCurrentUser: false, content: "I... I like solving problems, Commander."),
            .scheduled(after: 053, sentByCurrentUser: false, content: "And Enigma is the most difficult problem in the world."),
            .scheduled(after: 060, sentByCurrentUser: true, content: "Oh, Enigma isn't difficult..."),
            .scheduled(after: 062, sentByCurrentUser: true, content: "It's impossible."),
            .scheduled(after: 064, sentByCurrentUser: true, content: "It's *impossible*!"),
            .scheduled(after: 068, sentByCurrentUser: true, content: "The Americans, the Russians, the French, the Germans."),
            .scheduled(after: 072, sentByCurrentUser: true, content: "Everyone thinks Enigma is unbreakable."),
            .scheduled(after: 083, sentByCurrentUser: false, content: "Good. Let me try."),
            .scheduled(after: 085, sentByCurrentUser: false, content: "Then we'll know for sure, won't we?")
        ]),
        DummyRoom(planName: "Filler A", otherUser: DummyUser(identifier: "callum", name: "Callum"), messages: [
            .initial(days: 1, seconds: 10, sentByCurrentUser: false, content: "Hi")
        ]),
        DummyRoom(planName: "Filler B", otherUser: DummyUser(identifier: "mina", name: "Mina"), messages: [
            .initial(days: 1, seconds: 1, sentByCurrentUser: false, content: "👋🏿")
        ]),
        DummyRoom(planName: "Filler C", otherUser: DummyUser(identifier: "jonathan", name: "Jonathan"), messages: [
            .initial(seconds: 500, sentByCurrentUser: false, content: "Hi. I'd like some more information please"),
            .initial(seconds: 499, sentByCurrentUser: false, content: "What's the intended outcome for the \"filler c\" plan?"),
            .scheduled(after: 28, sentByCurrentUser: true, content: "Hi Jonathan"),
            .scheduled(after: 38, sentByCurrentUser: true, content: "The Filler C plan is a pointless plan which we added to give some more test data. "
                + "When it's finished, you will absolutely feel no different to when it started."),
            .scheduled(after: 52, sentByCurrentUser: false, content: "That sounds great"),
            .scheduled(after: 55, sentByCurrentUser: false, content: "Sign me up!")
        ]),
        DummyRoom(planName: "Simple counter", otherUser: DummyUser(identifier: "mike", name: "Mike"), messages: [
            .serverside(seconds: 15, sentByCurrentUser: false, content: "1"),
            .serverside(seconds: 14, sentByCurrentUser: false, content: "2"),
            .serverside(seconds: 13, sentByCurrentUser: false, content: "3"),
            .serverside(seconds: 12, sentByCurrentUser: false, content: "4"),
            .serverside(seconds: 11, sentByCurrentUser: false, content: "5"),
            .serverside(seconds: 10, sentByCurrentUser: false, content: "6"),
            .serverside(seconds: 09, sentByCurrentUser: false, content: "7"),
            .serverside(seconds: 08, sentByCurrentUser: false, content: "8"),
            .serverside(seconds: 07, sentByCurrentUser: false, content: "9"),
            .serverside(seconds: 06, sentByCurrentUser: false, content: "10"),
            .serverside(seconds: 05, sentByCurrentUser: false, content: "11"),
            .serverside(seconds: 04, sentByCurrentUser: false, content: "12"),
            .serverside(seconds: 03, sentByCurrentUser: false, content: "13"),
            .serverside(seconds: 02, sentByCurrentUser: false, content: "14"),
            .serverside(seconds: 01, sentByCurrentUser: false, content: "15"),
            .initial(seconds: 00, sentByCurrentUser: false, content: "16")
        ])]
    
    // MARK: - Initializers
    
    init(persistenceController: PersistenceController) {
        self.persistenceController = persistenceController
        self.nextMessageIdentifier = 1000
        self.entries = []
        self.serversideMessages = [NSManagedObjectID : [ServersideMessage]]()
    }
    
    // MARK: - Internal methods
    
    func start(completionHandler: @escaping (User) -> Void) {
        guard self.timer == nil, self.referenceDate == nil else {
            fatalError("Data simulator should be started only once.")
        }
        
        self.referenceDate = Date()
        
        self.loadInitialState { currentUser in
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
    
    func calculateMessageIdentifier(isHistoric: Bool) -> String {
        let identifier = self.nextMessageIdentifier
        
        self.nextMessageIdentifier += 1
        
        return String(isHistoric ? identifier : identifier + 1000)
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
