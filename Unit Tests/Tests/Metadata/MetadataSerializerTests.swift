import XCTest
@testable import PusherChatkit

class MetadataSerializerTests: XCTestCase {
    
    // MARK: - Tests
    
    func testShouldSerializeMetadataWithCorrectValues() {
        let metadata = ["first" : "abc",
                        "second" : "def",
                        "third" : "ghi",
                        "fourth" : "jkl"]
        
        let data = MetadataSerializer.serialize(metadata: metadata)
        
        XCTAssertNotNil(data)
    }
    
    func testShouldNotSerializeMetadataWithIncorrectValues() {
        let metadata: Metadata = ["first" : "abc",
                                  "second" : "def",
                                  "third" : Date.distantPast,
                                  "fourth" : "jkl"]
        
        let data = MetadataSerializer.serialize(metadata: metadata)
        
        XCTAssertNil(data)
    }
    
    func testShouldDeserializeMetadataWithCorrectValues() {
        let sourceMetadata = ["first" : "abc",
                              "second" : "def",
                              "third" : "ghi",
                              "fourth" : "jkl"]
        
        guard let data = try? JSONSerialization.data(withJSONObject: sourceMetadata) else {
            assertionFailure("Failed to serialize JSON object.")
            return
        }
        
        let deserializedMetadata = MetadataSerializer.deserialize(data: data)
        
        XCTAssertEqual(deserializedMetadata as? [String : String], sourceMetadata)
    }
    
    func testShouldNotDeserializeMetadataThatIsNotInDictionaryFormat() {
        let sourceMetadata = ["first", "second", "third", "fourth"]
        
        guard let data = try? JSONSerialization.data(withJSONObject: sourceMetadata) else {
            assertionFailure("Failed to serialize JSON object.")
            return
        }
        
        let deserializedMetadata = MetadataSerializer.deserialize(data: data)
        
        XCTAssertNil(deserializedMetadata)
    }
    
    func testShouldNotDeserializeMetadataFromDataThatIsNotInJSONFormat() {
        let data = Data(capacity: 1234)
        
        let deserializedMetadata = MetadataSerializer.deserialize(data: data)
        
        XCTAssertNil(deserializedMetadata)
    }
    
    func testShouldReturnNilWhenTryingToDeserializeNil() {
        let deserializedMetadata = MetadataSerializer.deserialize(data: nil)
        
        XCTAssertNil(deserializedMetadata)
    }
    
    func testShouldSerializeAndDeserializeTheSameMetadata() {
        let sourceMetadata = ["first" : "abc",
                              "second" : "def",
                              "third" : "ghi",
                              "fourth" : "jkl"]
        
        let data = MetadataSerializer.serialize(metadata: sourceMetadata)
        let deserializedMetadata = MetadataSerializer.deserialize(data: data) as? [String : String]
        
        XCTAssertEqual(deserializedMetadata, sourceMetadata)
    }
    
}
