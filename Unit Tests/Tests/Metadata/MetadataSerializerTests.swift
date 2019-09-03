import XCTest
@testable import PusherChatkit

class MetadataSerializerTests: XCTestCase {
    
    // MARK: - Tests
    
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
    
}
