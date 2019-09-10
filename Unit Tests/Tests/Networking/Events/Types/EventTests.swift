import XCTest
@testable import PusherChatkit

class EventTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldCreateEventWithCorrectValues() {
        let payload: [String : String] = ["testKey" : "testValue"]
        let jsonObject: [String : Any] = ["event_name" : "initial_state",
                                          "data" : payload,
                                          "timestamp": "2017-03-23T11:36:42Z"]
        
        let event = Event(with: jsonObject)
        
        XCTAssertEqual(event?.name, Event.Name.initialState)
        XCTAssertEqual(event?.payload as? [String : String], payload)
    }
    
    func testShouldNotCreateEventWhenEventNameIsIncorrect() {
        let jsonObject: [String : Any] = ["event_name" : "testEventName",
                                          "data" : ["testKey" : "testValue"],
                                          "timestamp": "2017-03-23T11:36:42Z"]
        
        let event = Event(with: jsonObject)
        
        XCTAssertNil(event)
    }
    
    func testShouldNotCreateEventWhenEventNameIsMissing() {
        let jsonObject: [String : Any] = ["data" : ["testKey" : "testValue"],
                                          "timestamp": "2017-03-23T11:36:42Z"]
        
        let event = Event(with: jsonObject)
        
        XCTAssertNil(event)
    }
    
    func testShouldNotCreateEventWhenDataIsIncorrect() {
        let jsonObject: [String : Any] = ["event_name" : "initial_state",
                                          "data" : 1,
                                          "timestamp": "2017-03-23T11:36:42Z"]
        
        let event = Event(with: jsonObject)
        
        XCTAssertNil(event)
    }
    
    func testShouldNotCreateEventWhenDataIsMissing() {
        let jsonObject: [String : Any] = ["event_name" : "initial_state",
                                          "timestamp": "2017-03-23T11:36:42Z"]
        
        let event = Event(with: jsonObject)
        
        XCTAssertNil(event)
    }
    
}
