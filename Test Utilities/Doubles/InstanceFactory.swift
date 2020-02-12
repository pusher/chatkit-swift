import XCTest
@testable import PusherChatkit

public class DummyInstanceFactory: DummyBase, InstanceFactory {
    
    public func makeInstance(forType instanceType: InstanceType) -> Instance {
        DummyFail(sender: self, function: #function)
        return DummyInstance(file: file, line: line)
    }
}

public class StubInstanceFactory: DoubleBase, InstanceFactory {
    
    private var makeInstance_expectedTypesAndInstancesToReturn: [(instanceType: InstanceType, instance: Instance)]
    public private(set) var makeInstance_actualCallCount: UInt = 0
    
    public init(makeInstance_expectedTypesAndInstancesToReturn: [(instanceType: InstanceType, instance: Instance)] = [],
         file: StaticString = #file, line: UInt = #line) {
        
        self.makeInstance_expectedTypesAndInstancesToReturn = makeInstance_expectedTypesAndInstancesToReturn
        
        super.init(file: file, line: line)
    }
    
    public func makeInstance(forType instanceType: InstanceType) -> Instance {
        makeInstance_actualCallCount += 1
        
        guard let (expectedInstanceType, instanceToReturn) = self.makeInstance_expectedTypesAndInstancesToReturn.removeOptionalFirst() else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self))", file: file, line: line)
            return DummyInstance(file: file, line: line)
        }
        guard expectedInstanceType == instanceType else {
            XCTFail("Unexpected call of `\(#function)` made to \(String(describing: self)) with `instanceType` of `\(instanceType)`.  Was expecting a `instanceType` of `\(expectedInstanceType)`", file: file, line: line)
            return DummyInstance(file: file, line: line)
        }
        
        return instanceToReturn
    }
}
