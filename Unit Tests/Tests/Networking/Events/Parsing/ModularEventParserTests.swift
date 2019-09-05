import XCTest
@testable import PusherChatkit

class ModularEventParserTests: XCTestCase {
    
    // MARK: - Properties
    
    var firstTestEventParser: EventParser!
    var secondTestEventParser: EventParser!
    var thirdTestEventParser: EventParser!
    
    var payload: [String : String]!
    var event: Event!
    
    // MARK: - Tests lifecycle
    
    override func setUp() {
        super.setUp()
        
        self.firstTestEventParser = TestEventParser(name: "first")
        self.secondTestEventParser = TestEventParser(name: "second")
        self.thirdTestEventParser = TestEventParser(name: "third")
        
        self.payload = ["testKey" : "testValue"]
        self.event = Event(with: ["event_name" : "initial_state",
                                  "data" : self.payload,
                                  "timestamp": "2017-03-23T11:36:42Z"])
    }
    
    // MARK: - Tests
    
    func testShouldNotHaveAnyLoggerByDefault() {
        let eventParser = ModularEventParser()
        
        XCTAssertNil(eventParser.logger)
    }
    
    func testShouldSetLogger() {
        let eventParser = ModularEventParser(logger: TestLogger())
        
        XCTAssertTrue(eventParser.logger is TestLogger)
    }
    
    func testShouldRegisterCorrectNumberOfParsers() {
        let eventParser = ModularEventParser()
        eventParser.register(parser: self.firstTestEventParser, for: .chat, with: .version1)
        eventParser.register(parser: self.secondTestEventParser, for: .chat, with: .version2)
        eventParser.register(parser: self.thirdTestEventParser, for: .cursors, with: .version1)
        
        XCTAssertEqual(eventParser.numberOfRegistrations, 3)
    }
    
    func testShouldHaveCorrectParsersForServices() {
        let eventParser = ModularEventParser()
        eventParser.register(parser: self.firstTestEventParser, for: .chat, with: .version1)
        eventParser.register(parser: self.secondTestEventParser, for: .chat, with: .version2)
        eventParser.register(parser: self.thirdTestEventParser, for: .cursors, with: .version1)
        
        XCTAssertEqual((eventParser.parser(for: .chat, with: .version1) as? TestEventParser)?.name, "first")
        XCTAssertEqual((eventParser.parser(for: .chat, with: .version2) as? TestEventParser)?.name, "second")
        XCTAssertEqual((eventParser.parser(for: .cursors, with: .version1) as? TestEventParser)?.name, "third")
    }
    
    func testShouldOverwriteExistingRegistration() {
        let eventParser = ModularEventParser()
        eventParser.register(parser: self.firstTestEventParser, for: .chat, with: .version1)
        eventParser.register(parser: self.secondTestEventParser, for: .chat, with: .version2)
        eventParser.register(parser: self.thirdTestEventParser, for: .chat, with: .version1)
        
        XCTAssertEqual((eventParser.parser(for: .chat, with: .version1) as? TestEventParser)?.name, "third")
        XCTAssertEqual((eventParser.parser(for: .chat, with: .version2) as? TestEventParser)?.name, "second")
    }
    
    func testShouldRegisterParserOnlyForProvidedVersionOfService() {
        let eventParser = ModularEventParser()
        eventParser.register(parser: self.firstTestEventParser, for: .cursors, with: .version2)
        
        XCTAssertNil(eventParser.parser(for: .cursors, with: .version1))
        XCTAssertEqual((eventParser.parser(for: .cursors, with: .version2) as? TestEventParser)?.name, "first")
        XCTAssertNil(eventParser.parser(for: .cursors, with: .version6))
    }
    
    func testShouldRegisterParserOnlyForProvidedServiceName() {
        let eventParser = ModularEventParser()
        eventParser.register(parser: self.firstTestEventParser, for: .cursors, with: .version2)
        
        XCTAssertNil(eventParser.parser(for: .chat, with: .version2))
        XCTAssertEqual((eventParser.parser(for: .cursors, with: .version2) as? TestEventParser)?.name, "first")
        XCTAssertNil(eventParser.parser(for: .presence, with: .version2))
        XCTAssertNil(eventParser.parser(for: .pushNotification, with: .version2))
    }
    
    func testShouldCorrectlyUnregisterSelectedParser() {
        let eventParser = ModularEventParser()
        eventParser.register(parser: self.firstTestEventParser, for: .chat, with: .version1)
        eventParser.register(parser: self.secondTestEventParser, for: .chat, with: .version2)
        eventParser.register(parser: self.thirdTestEventParser, for: .cursors, with: .version1)
        
        eventParser.unregisterParser(for: .chat, with: .version2)
        
        XCTAssertEqual(eventParser.numberOfRegistrations, 2)
        XCTAssertEqual((eventParser.parser(for: .chat, with: .version1) as? TestEventParser)?.name, "first")
        XCTAssertNil(eventParser.parser(for: .chat, with: .version2))
        XCTAssertEqual((eventParser.parser(for: .cursors, with: .version1) as? TestEventParser)?.name, "third")
    }
    
    func testShouldNotUnregisterAnyParserWhenTryingToUnregisterNotRegisteredParser() {
        let eventParser = ModularEventParser()
        eventParser.register(parser: self.firstTestEventParser, for: .chat, with: .version1)
        eventParser.register(parser: self.secondTestEventParser, for: .chat, with: .version2)
        eventParser.register(parser: self.thirdTestEventParser, for: .cursors, with: .version1)
        
        eventParser.unregisterParser(for: .chat, with: .version6)
        
        XCTAssertEqual(eventParser.numberOfRegistrations, 3)
        XCTAssertEqual((eventParser.parser(for: .chat, with: .version1) as? TestEventParser)?.name, "first")
        XCTAssertEqual((eventParser.parser(for: .chat, with: .version2) as? TestEventParser)?.name, "second")
        XCTAssertEqual((eventParser.parser(for: .cursors, with: .version1) as? TestEventParser)?.name, "third")
    }
    
    func testShouldInvokeParseMethodOnCorrectParser() {
        let eventParser = ModularEventParser()
        
        let firstTestEventParser = TestEventParser(name: "firstTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: firstTestEventParser, for: .chat, with: .version1)
        
        let secondTestEventParser = TestEventParser(name: "secondTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTAssertEqual(event.payload as? [String : String], self.payload)
            XCTAssertEqual(serviceName, ServiceName.chat)
            XCTAssertEqual(serviceVersion, ServiceVersion.version2)
        }
        eventParser.register(parser: secondTestEventParser, for: .chat, with: .version2)
        
        let thirdTestEventParser = TestEventParser(name: "thirdTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: thirdTestEventParser, for: .cursors, with: .version1)
        
        XCTAssertNoThrow(try eventParser.parse(event: self.event, from: .chat, version: .version2))
    }
    
    func testShouldNotInvokeParseMethodOnAnyParserWhenEventArrivedFromUnregisteredServiceName() {
        let eventParser = ModularEventParser()
        
        let firstTestEventParser = TestEventParser(name: "firstTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: firstTestEventParser, for: .chat, with: .version1)
        
        let secondTestEventParser = TestEventParser(name: "secondTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: secondTestEventParser, for: .chat, with: .version2)
        
        let thirdTestEventParser = TestEventParser(name: "thirdTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: thirdTestEventParser, for: .cursors, with: .version1)
        
        XCTAssertNoThrow(try eventParser.parse(event: self.event, from: .presence, version: .version2))
    }
    
    func testShouldNotInvokeParseMethodOnAnyParserWhenEventArrivedFromUnregisteredServiceVersion() {
        let eventParser = ModularEventParser()
        
        let firstTestEventParser = TestEventParser(name: "firstTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: firstTestEventParser, for: .chat, with: .version1)
        
        let secondTestEventParser = TestEventParser(name: "secondTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: secondTestEventParser, for: .chat, with: .version2)
        
        let thirdTestEventParser = TestEventParser(name: "thirdTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: thirdTestEventParser, for: .cursors, with: .version1)
        
        XCTAssertNoThrow(try eventParser.parse(event: self.event, from: .chat, version: .version6))
    }
    
    func testShouldThrowErrorWhenParserWasNotAbleToParseEvent() {
        let eventParser = ModularEventParser()
        
        let firstTestEventParser = TestEventParser(name: "firstTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: firstTestEventParser, for: .chat, with: .version1)
        
        let secondTestEventParser = TestEventParser(name: "secondTestEventParser", shouldThrowError: true) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: secondTestEventParser, for: .chat, with: .version2)
        
        let thirdTestEventParser = TestEventParser(name: "thirdTestEventParser", shouldThrowError: false) { event, serviceName, serviceVersion in
            XCTFail("Parse method on this parser should not be invoked by ModularEventParser.")
        }
        eventParser.register(parser: thirdTestEventParser, for: .cursors, with: .version1)
        
        XCTAssertThrowsError(try eventParser.parse(event: self.event, from: .chat, version: .version2), "Failed to catch an error for invalid event.") { error in
            guard let error = error as? NetworkingError else {
                return
            }
            
            XCTAssertEqual(error, NetworkingError.invalidEvent)
        }
    }
    
}
