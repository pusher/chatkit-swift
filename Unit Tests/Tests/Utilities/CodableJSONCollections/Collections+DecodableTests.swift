import XCTest
@testable import PusherChatkit


class DecodableTests: XCTestCase {

    // This XCTestCase exists to test the following methods...
    //
    //  extension Dictionary where Key == String, Value == Any {
    //      func decode(to encoder: Encoder) throws {
    //
    //  extension Array where Element == Any {
    //      func decode(to encoder: Encoder) throws {
    
    func test_decode_validJsonDictionary_noProblem() {

        let jsonData = """
        {
            "some-string": "value",
            "some-int": -9223372036854775808,
            "some-int8": -128,
            "some-int16": -32768,
            "some-int32": -2147483648,
            "some-int64": -9223372036854775808,
            "some-uint": 18446744073709551615,
            "some-uint8": 255,
            "some-uint16": 65535,
            "some-uint32": 4294967295,
            "some-uint64": 18446744073709551615,
            "some-double": 0.123456789123456789123456789123456789,
            "some-float": 0.123456789,
            "some-bool": true,
            "some-date": "2017-03-23T11:36:42Z",
            "some-optional": null,
            "nested-dict": { "another-string": "x" },
            "nested-array": [ "arr-string" ],
            "null-dict": { "null-key": null },
            "null-array": [ null ],
            "empty-dict": {},
            "empty-array": [],
        }
        """.toJsonData()

        let when = {
            return try [String: Any](from: try jsonData.jsonDecoder())
        }
        
        XCTAssertNoThrow(try when()) { dictionary in
            XCTAssertEqual(dictionary.count, 22)
            
            XCTAssertEqual(dictionary["some-string"] as? String, "value")
            
            XCTAssertEqual(dictionary["some-int"] as? NSNumber, NSNumber(value: Int.min))
            XCTAssertEqual(dictionary["some-int8"] as? NSNumber, NSNumber(value: Int8.min))
            XCTAssertEqual(dictionary["some-int16"] as? NSNumber, NSNumber(value: Int16.min))
            XCTAssertEqual(dictionary["some-int32"] as? NSNumber, NSNumber(value: Int32.min))
            XCTAssertEqual(dictionary["some-int64"] as? NSNumber, NSNumber(value: Int64.min))
            
            XCTAssertEqual(dictionary["some-uint"] as? NSNumber, NSNumber(value: UInt.max))
            XCTAssertEqual(dictionary["some-uint8"] as? NSNumber, NSNumber(value: UInt8.max))
            XCTAssertEqual(dictionary["some-uint16"] as? NSNumber, NSNumber(value: UInt16.max))
            XCTAssertEqual(dictionary["some-uint32"] as? NSNumber, NSNumber(value: UInt32.max))
            XCTAssertEqual(dictionary["some-uint64"] as? NSNumber, NSNumber(value: UInt64.max))
            
            XCTAssertEqual(dictionary["some-double"] as? Double, 0.12345678912345685 as Double)
            XCTAssertEqual(dictionary["some-float"] as? Double, 0.123456789 as Double)
            
            XCTAssertEqual(dictionary["some-date"] as? Date, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            
            XCTAssertEqual(dictionary["some-bool"] as? Bool, true)
            XCTAssertEqual(dictionary["some-optional"] as? NSNull, NSNull())
            
            XCTAssertNotNil(dictionary["nested-dict"] as? [String: Any]) { nestedDict in
                XCTAssertEqual(nestedDict.count, 1)
                XCTAssertEqual(nestedDict["another-string"] as? String, "x")
            }
            
            XCTAssertNotNil(dictionary["nested-array"] as? [Any]) { nestedArray in
                XCTAssertEqual(nestedArray.count, 1)
                XCTAssertEqual(nestedArray[0] as? String, "arr-string")
            }
            
            XCTAssertNotNil(dictionary["null-dict"] as? [String: Any]) { nestedDict in
                XCTAssertEqual(nestedDict.count, 1)
                XCTAssertEqual(nestedDict["null-key"] as? NSNull, NSNull())
            }
            
            XCTAssertNotNil(dictionary["null-array"] as? [Any]) { nestedArray in
                XCTAssertEqual(nestedArray.count, 1)
                XCTAssertEqual(nestedArray[0] as? NSNull, NSNull())
            }
            
            XCTAssertNotNil(dictionary["empty-dict"] as? [String: Any]) { nestedDict in
                XCTAssertEqual(nestedDict.count, 0)
            }
            
            XCTAssertNotNil(dictionary["empty-array"] as? [Any]) { nestedArray in
                XCTAssertEqual(nestedArray.count, 0)
            }
        }
    }
    
    func test_decode_invalidJsonDictionary_throws() {
        
        let jsonData = """
        {
            "invalid": ()
        }
        """.toJsonData(validate: false)
        
        let when = {
            return try [String: Any](from: try jsonData.jsonDecoder())
        }
        
        XCTAssertThrowsError(try when(),
                             containing: ["dataCorrupted",
                                          "The given data was not valid JSON",
                                          "Invalid value around character 17"])
    }
        
        
    func test_decode_validJsonArray_noProblem() {
        
        let jsonData = """
        [
            "someValue",
            -9223372036854775808,
            -128,
            -32768,
            -2147483648,
            -9223372036854775808,
            18446744073709551615,
            255,
            65535,
            4294967295,
            18446744073709551615,
            0.123456789,
            "2017-03-23T11:36:42Z",
            true,
            null,
            { "another-string": "x" },
            [ "arr-string" ],
            { "null-key": null },
            [ null ],
            {},
            [],
        ]
        """.toJsonData()
        
        let when = {
            return try [Any](from: try jsonData.jsonDecoder())
        }
        
        XCTAssertNoThrow(try when()) { array in
            XCTAssertEqual(array.count, 21)
            var i = 0
            
            XCTAssertEqual(array.next(&i) as? String, "someValue")
            
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int.min))
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int8.min))
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int16.min))
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int32.min))
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int64.min))
            
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt.max))
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt8.max))
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt16.max))
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt32.max))
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt64.max))
            
            XCTAssertEqual(array.next(&i) as? Double, Double(0.123456789))
            XCTAssertEqual(array.next(&i) as? Date, Date(fromISO8601String: "2017-03-23T11:36:42Z"))
            XCTAssertEqual(array.next(&i) as? Bool, true)
            XCTAssertEqual(array.next(&i) as? NSNull, NSNull())
            
            XCTAssertNotNil(array.next(&i) as? [String: Any]) { nestedDict in
                XCTAssertEqual(nestedDict.count, 1)
                XCTAssertEqual(nestedDict["another-string"] as? String, "x")
            }
            
            XCTAssertNotNil(array.next(&i) as? [Any]) { nestedArray in
                XCTAssertEqual(nestedArray.count, 1)
                XCTAssertEqual(nestedArray[0] as? String, "arr-string")
            }
            
            XCTAssertNotNil(array.next(&i) as? [String: Any]) { nestedDict in
                XCTAssertEqual(nestedDict.count, 1)
                XCTAssertEqual(nestedDict["null-key"] as? NSNull, NSNull())
            }
            
            XCTAssertNotNil(array.next(&i) as? [Any]) { nestedArray in
                XCTAssertEqual(nestedArray.count, 1)
                XCTAssertEqual(nestedArray[0] as? NSNull, NSNull())
            }
            
            XCTAssertNotNil(array.next(&i) as? [String: Any]) { nestedDict in
                XCTAssertEqual(nestedDict.count, 0)
            }
            
            XCTAssertNotNil(array.next(&i) as? [Any]) { nestedArray in
                XCTAssertEqual(nestedArray.count, 0)
            }
        }
    }
    
    func test_decode_invalidJsonArray_throws() {
        
        let jsonData = """
        [
            ()
        ]
        """.toJsonData(validate: false)
        
        let when = {
            return try [Any](from: try jsonData.jsonDecoder())
        }
        
        XCTAssertThrowsError(try when(),
                             containing: ["dataCorrupted",
                                          "The given data was not valid JSON",
                                          "Invalid value around character 6"])
    }
    
}
