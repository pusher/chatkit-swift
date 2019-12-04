import Foundation

/// A view model which provides a list of objects which can be used to render a message feed which includes messages and separators or headers between days.
///
/// Construct an instance of this class using `Chatkit.createMessagesViewModel(...)`
///
/// This class is intended to be bound to a UICollectionView or UITableView.
///
/// The `MessagesViewModel.rows` are intended to represent rows in a UI view, and there are three different types of row, represented by members of the `MessagesViewModel.MessageRow` enum:
///
/// - `.message`: a row containing a message
/// - `.dateHeader`: a row inserted between messages sent on different days, to be rendered as a divider between days in the feed.
/// - `.loadingIndicator`: a row inserted in to the feed when more messages have been requested from the Chatkit service, but have not yet arrived. See `MessagesViewModel.fetchOlderMessages(...)`.
///
/// Additionally, messages from the same sender which are sent in a short space of time are "grouped", and each `.message` is assigned a `MessagesViewModel.MessageRow.GroupPosition` describing whether it is:
///
/// - `.single`: the only message in its group
/// - `.top`: the first (oldest) message in a group
/// - `.middle`: a message on the "inside" of a group
/// - `.bottom`: the last (newest) message in a group
///
/// This grouping can be used to alter the rendering of different messages, for example, to show the timestamp or sender details only on the first or last message in each group.
public class MessagesViewModel {
    
    // MARK: - Properties
    
    private let provider: MessagesProvider
    
    /// The array of entires representig different elements that might appear on a message feed.
    ///
    /// Plese see the documentation of `MessageRow` for the list of possible entries that might be held
    /// by the array.
    public private(set) var rows: [MessageRow]
    
    /// The current state of the provider used by the view model as the data source.
    ///
    /// - Parameters:
    ///     - realTime: The current state of the provider related to the real time web service.
    ///     - paged: The current state of the provider related to the non-real time web service.
    public var state: (realTime: RealTimeProviderState, paged: PagedProviderState) {
        return self.provider.state
    }
    
    /// The object that is notified when the content of the maintained collection of message rows changed.
    public weak var delegate: MessagesViewModelDelegate?
    
    // MARK: - Initializers
    
    init(provider: MessagesProvider) {
        self.rows = []
        
        self.provider = provider
        self.provider.delegate = self
        
        self.reload()
    }
    
    // MARK: - Methods
    
    /// Triggers an asynchronous call to the web service that retrieves a batch of historical messages
    /// currently not present in the maintained collection of messages.
    ///
    /// - Parameters:
    ///     - numberOfMessages: The maximum number of messages that should be retrieved from
    ///     the web service.
    ///     - completionHandler:An optional completion handler called when the call to the web
    ///     service finishes with either a successful result or an error.
    public func fetchOlderMessages(numberOfMessages: UInt, completionHandler: CompletionHandler? = nil) {
        guard self.provider.state.paged == .partiallyPopulated else {
            if let completionHandler = completionHandler {
                completionHandler(nil)
            }
            
            return
        }

        self.batchViewUpdate {
            self.addLoadingIndicator()
        }

        self.provider.fetchOlderMessages(numberOfMessages: numberOfMessages) { error in
            if error != nil {
                self.batchViewUpdate {
                    self.removeLoadingIndicator()
                }
            }
            
            if let completionHandler = completionHandler {
                completionHandler(error)
            }
        }
        
        self.provider.fetchOlderMessages(numberOfMessages: numberOfMessages, completionHandler: completionHandler)
    }
    
    /// Marks the `lastReadMessage` and all messages preceding that message as read.
    ///
    /// - Parameters:
    ///     - lastReadMessage: The last message read by the user.
    public func markMessagesAsRead(lastReadMessage: Message) {
        self.provider.markMessagesAsRead(lastReadMessage: lastReadMessage)
    }
    
    // MARK: - Private methods
    
    private func reload() {
        self.rows = self.rows(for: self.provider.messages)
    }
    
    private func rows(for messages: [Message]) -> [MessageRow] {
        var rows = [MessageRow]()
        rows.reserveCapacity(messages.count + 1)
        
        for (index, message) in messages.enumerated() {
            let precedingIndex = index - 1
            let precedingMessage = precedingIndex >= messages.startIndex ? messages[precedingIndex] : nil
            let precedingHeaderDate = self.headerDate(for: precedingMessage)
            
            let succeedingIndex = index + 1
            let succeedingMessage = succeedingIndex < messages.endIndex ? messages[succeedingIndex] : nil
            
            if let headerDate = self.headerDate(for: message), let dateHeader = self.dateHeader(for: headerDate, precedingDate: precedingHeaderDate) {
                rows.append(dateHeader)
            }
            
            let groupPosition = self.groupPosition(for: message, precededBy: precedingMessage, succeededBy: succeedingMessage)
            let row = MessageRow.message(message, groupPosition)
            
            rows.append(row)
        }
        
        return rows
    }
    
    private func index(of row: MessageRow) -> Int? {
        return self.rows.firstIndex { $0 == row }
    }
    
    private func index(of message: Message) -> Int? {
        return self.rows.firstIndex { row -> Bool in
            if case let MessageRow.message(storedMessage, _) = row {
                return message.identifier == storedMessage.identifier
            }
            else {
                return false
            }
        }
    }
    
    private func groupPosition(for message: Message, precededBy precedingMessage: Message?, succeededBy succeedingMessage: Message?) -> MessageRow.GroupPosition {
        switch (self.shouldGroup(precedingMessage, message), self.shouldGroup(message, succeedingMessage)) {
        case (true, true):
            return .middle
            
        case (true, false):
            return .bottom
            
        case (false, true):
            return .top
            
        case (false, false):
            return .single
        }
    }

    private func shouldGroup(_ first: Message?, _ second: Message?) -> Bool {
        guard let first = first, let second = second else {
            return false
        }

        let sameSender = first.sender.identifier == second.sender.identifier
        let timesClose = first.createdAt.addingTimeInterval(60).compare(second.createdAt) == .orderedDescending

        return sameSender && timesClose
    }
    
    private func groupPosition(for message: Message, at index: Int) -> MessageRow.GroupPosition {
        let precedingIndex = index - 1
        let precedingMessage = self.message(at: precedingIndex)
        
        let succeedingIndex = index + 1
        let succeedingMessage = self.message(at: succeedingIndex)
        
        return self.groupPosition(for: message, precededBy: precedingMessage, succeededBy: succeedingMessage)
    }
    
    private func updateGroupPositionIfNeeded(forMessageAt index: Int, changeReason: MessagesViewModel.ChangeReason) {
        guard let message = self.message(at: index),
            let currentGroupPosition = self.currentGroupPosition(forMessageAt: index) else {
                return
        }
        
        let updatedGroupPosition = self.groupPosition(for: message, at: index)
        
        guard updatedGroupPosition != currentGroupPosition else {
            return
        }
        
        self.rows[index] = MessageRow.message(message, updatedGroupPosition)
        
        self.delegate?.messagesViewModel(self, didUpdateRowAt: index, changeReason: changeReason)
    }
    
    private func row(at index: Int) -> MessageRow? {
        guard index >= self.rows.startIndex && index < self.rows.endIndex else {
            return nil
        }
        
        return self.rows[index]
    }
    
    private func message(at index: Int) -> Message? {
        guard let row = self.row(at: index), case let MessageRow.message(message, _) = row else {
            return nil
        }
        
        return message
    }
    
    private func currentGroupPosition(forMessageAt index: Int) -> MessageRow.GroupPosition? {
        guard let row = self.row(at: index), case let MessageRow.message(_, groupPosition) = row else {
            return nil
        }
        
        return groupPosition
    }
    
    private func addLoadingIndicator() {
        guard !self.rows.contains(where: { row -> Bool in
            if case MessageRow.loadingIndicator = row {
                return true
            }
            else {
                return false
            }
        }) else {
            return
        }
        
        let index = self.rows.startIndex
        self.rows.insert(.loadingIndicator, at: index)

        self.delegate?.messagesViewModel(self, didAddRowAt: index, changeReason: .messageHistoryFetch)
    }
    
    private func removeLoadingIndicator() {
        guard let index = self.rows.firstIndex(where: { row -> Bool in
            if case MessageRow.loadingIndicator = row {
                return true
            }
            else {
                return false
            }
        }) else {
            return
        }

        self.rows.remove(at: index)
        
        self.delegate?.messagesViewModel(self, didRemoveRowAt: index, changeReason: .messageHistoryFetch)
    }
    
    private func removeDateHeaderIfNeeded(at index: Int, changeReason: MessagesViewModel.ChangeReason) {
        let precedingIndex = index - 1
        let precedingMessage = self.message(at: precedingIndex)
        
        let succeedingIndex = index + 1
        let succeedingMessage = self.message(at: succeedingIndex)

        guard let row = self.row(at: index),
            case MessageRow.dateHeader(_) = row,
            let precedingHeaderDate = self.headerDate(for: precedingMessage),
            let succeedingHeaderDate = self.headerDate(for: succeedingMessage),
            precedingHeaderDate == succeedingHeaderDate else {
                return
        }

        self.rows.remove(at: index)
        
        self.delegate?.messagesViewModel(self, didRemoveRowAt: index, changeReason: changeReason)
    }
}

// MARK: - JoinedRoomsProviderDelegate

/// :nodoc:
extension MessagesViewModel: MessagesProviderDelegate {
    
    public func messagesProvider(_ messagesProvider: MessagesProvider, didReceiveOlderMessages messages: [Message]) {
        let rows = self.rows(for: messages)
        
        guard rows.count > 0 else {
            return
        }

        let succeedingIndex = rows.endIndex

        self.batchViewUpdate {
            self.removeLoadingIndicator()
        
            self.rows.insert(contentsOf: rows, at: self.rows.startIndex)

            for index in self.rows.startIndex..<succeedingIndex {
                self.delegate?.messagesViewModel(self, didAddRowAt: index, changeReason: .messageReceived)
            }
        }

        self.batchViewUpdate {
            self.removeDateHeaderIfNeeded(at: succeedingIndex, changeReason: .messageReceived)
        }

        self.batchViewUpdate {
            self.updateGroupPositionIfNeeded(forMessageAt: succeedingIndex-1, changeReason: .messageReceived)
            self.updateGroupPositionIfNeeded(forMessageAt: succeedingIndex, changeReason: .messageReceived)
        }
    }
    
    public func messagesProvider(_ messagesProvider: MessagesProvider, didReceiveNewMessage message: Message) {
        self.batchViewUpdate {
            let precedingIndex = self.rows.endIndex - 1
            var precedingMessage = self.message(at: precedingIndex)
            let precedingHeaderDate = self.headerDate(for: precedingMessage)

            if let headerDate = self.headerDate(for: message), let dateHeader = self.dateHeader(for: headerDate, precedingDate: precedingHeaderDate) {
                rows.append(dateHeader)
                precedingMessage = nil

                if let index = self.index(of: dateHeader) {
                    self.delegate?.messagesViewModel(self, didAddRowAt: index, changeReason: .messageReceived)
                }
            }

            let groupPosition = self.groupPosition(for: message, precededBy: precedingMessage, succeededBy: nil)
            let messageRow = MessageRow.message(message, groupPosition)

            self.rows.append(messageRow)

            if let index = self.index(of: message) {
                self.delegate?.messagesViewModel(self, didAddRowAt: index, changeReason: .messageReceived)
            }

            self.updateGroupPositionIfNeeded(forMessageAt: precedingIndex, changeReason: .messageReceived)
        }
    }
    
    public func messagesProvider(_ messagesProvider: MessagesProvider, didUpdateMessage message: Message, previousValue: Message) {
        guard let index = self.index(of: previousValue) else {
            return
        }
        
        self.batchViewUpdate {
            let groupPosition = self.groupPosition(for: message, at: index)
            self.rows[index] = .message(message, groupPosition)

            self.delegate?.messagesViewModel(self, didUpdateRowAt: index, changeReason: .dataUpdated)
        }
    }
    
    public func messagesProvider(_ messagesProvider: MessagesProvider, didRemoveMessage message: Message) {
        guard let index = self.index(of: message) else {
            return
        }
        let precedingIndex = index - 1

        self.batchViewUpdate {
            self.rows.remove(at: index)
            self.delegate?.messagesViewModel(self, didRemoveRowAt: index, changeReason: .messageRemoved)

            self.removeDateHeaderIfNeeded(at: precedingIndex, changeReason: .messageRemoved)
        }

        self.batchViewUpdate {
            self.updateGroupPositionIfNeeded(forMessageAt: precedingIndex, changeReason: .messageRemoved)
            self.updateGroupPositionIfNeeded(forMessageAt: index, changeReason: .messageRemoved)
        }
    }

    private func batchViewUpdate(_ runUpdates: () -> ()) {
        self.delegate?.messagesViewModelWillChangeContent(self)
        runUpdates()
        self.delegate?.messagesViewModelDidChangeContent(self)
    }

    private func headerDate(for message: Message?) -> Date? {
        guard let message = message else {
            return nil
        }
        
        let calendar = Calendar.current
        let dateComponents = calendar.dateComponents([.day, .month, .year, .era], from: message.createdAt)
        
        guard let headerDate = calendar.date(from: dateComponents) else {
            return nil
        }
        
        return headerDate
    }
    
    private func dateHeader(for date: Date, precedingDate: Date?) -> MessageRow? {
        guard let precedingDate = precedingDate else {
            return .dateHeader(date)
        }
        
        return date != precedingDate ? .dateHeader(date) : nil
    }
    
}

// MARK: - Delegate

/// A delegate protocol for being notified when the `rows` of a `MessagesViewModel` have changed.
public protocol MessagesViewModelDelegate: class {
    
    /// Called before a batch of changes are made to the `rows`.
    ///
    /// - Parameters:
    ///     - messagesViewModel: The `MessagesViewModel` that called the method.
    func messagesViewModelWillChangeContent(_ messagesViewModel: MessagesViewModel)
    
    /// Called when a new row was added to the collection.
    ///
    /// - Parameters:
    ///     - messagesViewModel: The `MessagesViewModel` that called the method.
    ///     - index: The index of the row added to the `rows` collection.
    ///     - changeReason: The reason for the addition.
    func messagesViewModel(_ messagesViewModel: MessagesViewModel, didAddRowAt index: Int, changeReason: MessagesViewModel.ChangeReason)
    
    /// Called when a row has been updated.
    ///
    /// - Parameters:
    ///     - messagesViewModel: The `MessagesViewModel` that called the method.
    ///     - index: The index of the row updated in the `rows` collection.
    ///     - changeReason: The reason for the update.
    func messagesViewModel(_ messagesViewModel: MessagesViewModel, didUpdateRowAt index: Int, changeReason: MessagesViewModel.ChangeReason)
    
    /// Called when a row has been removed.
    ///
    /// - Parameters:
    ///     - messagesViewModel: The `MessagesViewModel` that called the method.
    ///     - index: The index of the row removed from the `rows` collection (the index it held before it was removed).
    ///     - changeReason: The reason for the removal.
    func messagesViewModel(_ messagesViewModel: MessagesViewModel, didRemoveRowAt index: Int, changeReason: MessagesViewModel.ChangeReason)
    
    /// Called after a batch of changes are made to the `rows`.
    ///
    /// - Parameters:
    ///     - messagesViewModel: The `MessagesViewModel` that called the method.
    func messagesViewModelDidChangeContent(_ messagesViewModel: MessagesViewModel)
    
}

// MARK: - Row

public extension MessagesViewModel {
    
    /// An enumeration representing an entry is the list of rows of the message feed provided
    /// by the `MessagesViewModel` class.
    enum MessageRow: Equatable {
        
        /// An entry representing a loading indicator.
        ///
        /// The loading indicator is present of the message feed when a new batch of messages is being
        /// downloaded from the web service.
        case loadingIndicator
        
        /// An entry representing a date header.
        ///
        /// The date header is present of the message feed to indicatate a new batch of messages sent
        /// on a different day.
        ///
        /// - Parameters:
        ///     - date: The date of the header.
        case dateHeader(Date)
        
        /// An entry representing a message.
        ///
        /// - Parameters:
        ///     - message: The message.
        ///     - groupPosition: The position of the message in the group of messages sent
        ///     by the same user.
        case message(Message, GroupPosition)
        
    }
    
}

// MARK: - Grouping

public extension MessagesViewModel.MessageRow {
    
    /// An enumeration representing a position of a `MessageRow` in the group of messages sent
    /// by the same user.
    enum GroupPosition {
        
        /// The only message send by the user.
        ///
        /// No grouping provided.
        case single
        
        /// The top message in the group of messages sent by the user.
        case top
        
        /// One of the middle messages in the group of messages sent by the user.
        case middle
        
        /// The bottom message in the group of messages sent by the user.
        case bottom
        
    }
    
}

// MARK: - Change Reason

public extension MessagesViewModel {
    
    // TODO: Define change reasons.
    /// An enumeration representing semantic reasons that might trigger a change
    /// in the `MessagesViewModel` class.
    enum ChangeReason {
        
        /// A new message received by the room.
        case messageReceived
        
        /// A message removed in the room.
        case messageRemoved
        
        /// A message has updated its content.
        case dataUpdated
        
        /// A new fetch of historical messages has been triggered.
        case messageHistoryFetch
        
    }
    
}
