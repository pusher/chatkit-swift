import XCTest
@testable import TestUtilities
@testable import PusherChatkit

protocol DictionaryDecodableTests {

    associatedtype Element
    typealias Expression<Element> = (_ jsonData: Data) throws -> [String: Element]
    
    var expression: Expression<Element> { get }

    func test_decode_validJson_noProblem()
    func test_decode_invalidJson_throws()
}
    
extension DictionaryDecodableTests {
    
    fileprivate func _test_decode_validJson_noProblem(file: StaticString = #file, line: UInt = #line) {

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
        
        XCTAssertNoThrow(try expression(jsonData), file: file, line: line) { dictionary in
            XCTAssertEqual(dictionary.count, 22)
            
            XCTAssertEqual(dictionary["some-string"] as? String, "value", file: file, line: line)
            
            XCTAssertEqual(dictionary["some-int"] as? NSNumber, NSNumber(value: Int.min), file: file, line: line)
            XCTAssertEqual(dictionary["some-int8"] as? NSNumber, NSNumber(value: Int8.min), file: file, line: line)
            XCTAssertEqual(dictionary["some-int16"] as? NSNumber, NSNumber(value: Int16.min), file: file, line: line)
            XCTAssertEqual(dictionary["some-int32"] as? NSNumber, NSNumber(value: Int32.min), file: file, line: line)
            XCTAssertEqual(dictionary["some-int64"] as? NSNumber, NSNumber(value: Int64.min), file: file, line: line)
            
            XCTAssertEqual(dictionary["some-uint"] as? NSNumber, NSNumber(value: UInt.max), file: file, line: line)
            XCTAssertEqual(dictionary["some-uint8"] as? NSNumber, NSNumber(value: UInt8.max), file: file, line: line)
            XCTAssertEqual(dictionary["some-uint16"] as? NSNumber, NSNumber(value: UInt16.max), file: file, line: line)
            XCTAssertEqual(dictionary["some-uint32"] as? NSNumber, NSNumber(value: UInt32.max), file: file, line: line)
            XCTAssertEqual(dictionary["some-uint64"] as? NSNumber, NSNumber(value: UInt64.max), file: file, line: line)
            
            XCTAssertEqual(dictionary["some-double"] as? Double, 0.12345678912345685 as Double, file: file, line: line)
            XCTAssertEqual(dictionary["some-float"] as? Double, 0.123456789 as Double, file: file, line: line)
            
            XCTAssertEqual(dictionary["some-date"] as? Date, Date(fromISO8601String: "2017-03-23T11:36:42Z"), file: file, line: line)
            
            XCTAssertEqual(dictionary["some-bool"] as? Bool, true, file: file, line: line)
            XCTAssertEqual(dictionary["some-optional"] as? NSNull, NSNull(), file: file, line: line)
            
            XCTAssertNotNil(dictionary["nested-dict"] as? [String: Any], file: file, line: line) { nestedDict in
                XCTAssertEqual(nestedDict.count, 1, file: file, line: line)
                XCTAssertEqual(nestedDict["another-string"] as? String, "x", file: file, line: line)
            }
            
            XCTAssertNotNil(dictionary["nested-array"] as? [Any], file: file, line: line) { nestedArray in
                XCTAssertEqual(nestedArray.count, 1, file: file, line: line)
                XCTAssertEqual(nestedArray[0] as? String, "arr-string", file: file, line: line)
            }
            
            XCTAssertNotNil(dictionary["null-dict"] as? [String: Any]) { nestedDict in
                XCTAssertEqual(nestedDict.count, 1, file: file, line: line)
                XCTAssertEqual(nestedDict["null-key"] as? NSNull, NSNull(), file: file, line: line)
            }
            
            XCTAssertNotNil(dictionary["null-array"] as? [Any], file: file, line: line) { nestedArray in
                XCTAssertEqual(nestedArray.count, 1, file: file, line: line)
                XCTAssertEqual(nestedArray[0] as? NSNull, NSNull(), file: file, line: line)
            }
            
            XCTAssertNotNil(dictionary["empty-dict"] as? [String: Any], file: file, line: line) { nestedDict in
                XCTAssertEqual(nestedDict.count, 0, file: file, line: line)
            }
            
            XCTAssertNotNil(dictionary["empty-array"] as? [Any], file: file, line: line) { nestedArray in
                XCTAssertEqual(nestedArray.count, 0, file: file, line: line)
            }
        }
    }
    
    fileprivate func _test_decode_invalidJson_throws(file: StaticString = #file, line: UInt = #line) {
        
        let jsonData = """
        {
            "invalid": ()
        }
        """.toJsonData(validate: false)
    
        XCTAssertThrowsError(try expression(jsonData),
                             containing: ["dataCorrupted",
                                          "The given data was not valid JSON",
                                          "Invalid value around character 17"],
                             file: file,
                             line: line)
    }
}


class DictionaryOfAnyHashable_DecodableTests: XCTestCase, DictionaryDecodableTests {

    // Tests the following method...
    //
    //  extension Dictionary where Key == String, Value == AnyHashable {
    //      func decode(to encoder: Encoder) throws {
    //
    
    let expression: Expression<AnyHashable> = { jsonData in
        return try [String: AnyHashable](from: try jsonData.jsonDecoder())
    }
    
    func test_decode_validJson_noProblem() {
        _test_decode_validJson_noProblem()
    }

    func test_decode_invalidJson_throws() {
        _test_decode_invalidJson_throws()
    }
}

class DictionaryOfAny_DecodableTests: XCTestCase, DictionaryDecodableTests {
    
    // Tests the following method...
    //
    //  extension Dictionary where Key == String, Value == Any {
    //      func decode(to encoder: Encoder) throws {
    //
    
    let expression: Expression<Any> = { jsonData in
        return try [String: Any](from: try jsonData.jsonDecoder())
    }
    
    func test_decode_validJson_noProblem() {
        _test_decode_validJson_noProblem()
    }
    
    func test_decode_invalidJson_throws() {
        _test_decode_invalidJson_throws()
    }
}

class JSONDecoder_DictionaryOfAnyHashable_DecodableTests: XCTestCase, DictionaryDecodableTests {
    
    // Tests the following method...
    //
    //  extension JSONDecoder {
    //      func decode(_ type: [String: AnyHashable].Type, from data: Data) throws -> [String: AnyHashable] {
    //
    
    let expression: Expression<AnyHashable> = { jsonData in
        return try JSONDecoder.default.decode([String: AnyHashable].self, from: jsonData)
    }
    
    func test_decode_validJson_noProblem() {
        _test_decode_validJson_noProblem()
    }
    
    func test_decode_invalidJson_throws() {
        _test_decode_invalidJson_throws()
    }
}

class JSONDecoder_DictionaryOfAny_DecodableTests: XCTestCase, DictionaryDecodableTests {
    
    // Tests the following method...
    //
    //  extension JSONDecoder {
    //      func decode(_ type: [String: Any].Type, from data: Data) throws -> [String: Any] {
    //
    
    let expression: Expression<Any> = { jsonData in
        return try JSONDecoder.default.decode([String: Any].self, from: jsonData)
    }
    
    func test_decode_validJson_noProblem() {
        _test_decode_validJson_noProblem()
    }
    
    func test_decode_invalidJson_throws() {
        _test_decode_invalidJson_throws()
    }
}
