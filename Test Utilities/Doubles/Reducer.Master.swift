import XCTest
@testable import PusherChatkit

//public class DummyReductionManager: DummyBase, ReductionManager {
//    
//    public func reduce(action: Action, state: ChatState) -> ChatState {
//        DummyFail(sender: self, function: #function)
//        return .empty
//    }
//    
//}
//
//public class StubReductionManager: StubBase, ReductionManager {
//    
//    private var reduce_expectedCallCount: UInt
//    private var reduce_expectedState: ChatState
//    public private(set) var reduce_actionLastReceived: Action?
//    public private(set) var reduce_stateLastReceived: ChatState?
//    public private(set) var reduce_actualCallCount: UInt = 0
//    
//    public init(reduce_expectedState: ChatState,
//                reduce_expectedCallCount: UInt = 0,
//                
//                file: StaticString = #file, line: UInt = #line) {
//        
//        self.reduce_expectedState = reduce_expectedState
//        self.reduce_expectedCallCount = reduce_expectedCallCount
//        
//        super.init(file: file, line: line)
//    }
//    
//    public func reduce(action: Action, state: ChatState) -> ChatState {
//        reduce_actionLastReceived = action
//        reduce_stateLastReceived = state
//        reduce_actualCallCount += 1
//
//        guard reduce_expectedCallCount > 0 else {
//            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
//            return reduce_expectedState
//        }
//        reduce_expectedCallCount -= 1
//        
//        return reduce_expectedState
//    }
//    
//}
