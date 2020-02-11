import XCTest
@testable import PusherChatkit

public class DummyInstanceFactory: DummyBase, InstanceFactory {
    
    public func makeInstance(forType instanceType: InstanceType) -> Instance {
        return DummyInstance(file: file, line: line)
    }
}

public class StubInstanceFactory: DoubleBase, InstanceFactory {
    
    public typealias MakeInstanceHandler = (InstanceType) -> Instance
    
    private enum MakeInstanceType {
        case single(Instance)
        case handler(MakeInstanceHandler)
    }

    private let makeInstance_Type: MakeInstanceType
    
    public init(makeInstance_instanceToReturn: Instance,
         file: StaticString = #file, line: UInt = #line) {
        
        makeInstance_Type = .single(makeInstance_instanceToReturn)
        
        super.init(file: file, line: line)
    }
    
    public init(makeInstance_handler: @escaping MakeInstanceHandler,
         file: StaticString = #file, line: UInt = #line) {
        
        makeInstance_Type = .handler(makeInstance_handler)
        
        super.init(file: file, line: line)
    }
    
    // MARK: InstanceFactory
    
    public func makeInstance(forType instanceType: InstanceType) -> Instance {
        switch makeInstance_Type {
        
        case let .single(instanceToReturn):
            return instanceToReturn
            
        case let .handler(handler):
            return handler(instanceType)
        }
    }
}
