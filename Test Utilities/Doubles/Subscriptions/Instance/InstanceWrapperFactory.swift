import XCTest
@testable import PusherChatkit

public class DummyInstanceWrapperFactory: DummyBase, InstanceWrapperFactory {
    
    public func makeInstanceWrapper(forType instanceType: InstanceType) -> InstanceWrapper {
        DummyFail(sender: self, function: #function)
        return DummyInstanceWrapper(file: file, line: line)
    }
}

public class StubInstanceWrapperFactory: DoubleBase, InstanceWrapperFactory {
    
    private var makeInstanceWrapper_expectedTypesAndInstanceWrappersToReturn: [(instanceType: InstanceType, instanceWrapper: InstanceWrapper)]
    public private(set) var makeInstanceWrapper_actualCallCount: UInt = 0
    
    public init(makeInstanceWrapper_expectedTypesAndInstanceWrappersToReturn: [(instanceType: InstanceType, instanceWrapper: InstanceWrapper)] = [],
         file: StaticString = #file, line: UInt = #line) {
        
        self.makeInstanceWrapper_expectedTypesAndInstanceWrappersToReturn = makeInstanceWrapper_expectedTypesAndInstanceWrappersToReturn
        
        super.init(file: file, line: line)
    }
    
    public func makeInstanceWrapper(forType instanceType: InstanceType) -> InstanceWrapper {
        makeInstanceWrapper_actualCallCount += 1
        
        guard let (expectedInstanceType, instanceWrapperToReturn) = self.makeInstanceWrapper_expectedTypesAndInstanceWrappersToReturn.removeOptionalFirst() else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return DummyInstanceWrapper(file: file, line: line)
        }
        guard expectedInstanceType == instanceType else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self)) with `instanceType` of `\(instanceType)`.  Was expecting a `instanceType` of `\(expectedInstanceType)`", file: file, line: line)
            return DummyInstanceWrapper(file: file, line: line)
        }
        
        return instanceWrapperToReturn
    }
}
