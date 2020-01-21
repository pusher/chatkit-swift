import XCTest
@testable import PusherChatkit

protocol ArrayDecodableTests {

    associatedtype Element
    typealias Expression<Element> = (_ jsonData: Data) throws -> [Element]
    
    var expression: Expression<Element> { get }

    func test_decode_validJson_noProblem()
    func test_decode_invalidJson_throws()
}
    
extension ArrayDecodableTests {
        
    fileprivate func _test_decode_validJson_noProblem(file: StaticString = #file, line: UInt = #line) {

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
        
        XCTAssertNoThrow(try expression(jsonData), file: file, line: line) { array in
            XCTAssertEqual(array.count, 21)
            var i = 0
            
            XCTAssertEqual(array.next(&i) as? String, "someValue", file: file, line: line)
            
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int.min), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int8.min), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int16.min), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int32.min), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: Int64.min), file: file, line: line)
            
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt.max), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt8.max), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt16.max), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt32.max), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNumber, NSNumber(value: UInt64.max), file: file, line: line)
            
            XCTAssertEqual(array.next(&i) as? Double, Double(0.123456789), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? Date, Date(fromISO8601String: "2017-03-23T11:36:42Z"), file: file, line: line)
            XCTAssertEqual(array.next(&i) as? Bool, true, file: file, line: line)
            XCTAssertEqual(array.next(&i) as? NSNull, NSNull(), file: file, line: line)
            
            XCTAssertNotNil(array.next(&i) as? [String: Element], file: file, line: line) { nestedDict in
                XCTAssertEqual(nestedDict.count, 1, file: file, line: line)
                XCTAssertEqual(nestedDict["another-string"] as? String, "x", file: file, line: line)
            }
            
            XCTAssertNotNil(array.next(&i) as? [Element], file: file, line: line) { nestedArray in
                XCTAssertEqual(nestedArray.count, 1, file: file, line: line)
                XCTAssertEqual(nestedArray[0] as? String, "arr-string", file: file, line: line)
            }
            
            XCTAssertNotNil(array.next(&i) as? [String: Element], file: file, line: line) { nestedDict in
                XCTAssertEqual(nestedDict.count, 1, file: file, line: line)
                XCTAssertEqual(nestedDict["null-key"] as? NSNull, NSNull(), file: file, line: line)
            }
            
            XCTAssertNotNil(array.next(&i) as? [Element], file: file, line: line) { nestedArray in
                XCTAssertEqual(nestedArray.count, 1, file: file, line: line)
                XCTAssertEqual(nestedArray[0] as? NSNull, NSNull(), file: file, line: line)
            }
            
            XCTAssertNotNil(array.next(&i) as? [String: Element], file: file, line: line) { nestedDict in
                XCTAssertEqual(nestedDict.count, 0, file: file, line: line)
            }
            
            XCTAssertNotNil(array.next(&i) as? [Element], file: file, line: line) { nestedArray in
                XCTAssertEqual(nestedArray.count, 0, file: file, line: line)
            }
        }
    }
    
    fileprivate func _test_decode_invalidJson_throws(file: StaticString = #file, line: UInt = #line) {
        
        let jsonData = """
        [
            ()
        ]
        """.toJsonData(validate: false)
    
        XCTAssertThrowsError(try expression(jsonData),
                             containing: ["dataCorrupted",
                                          "The given data was not valid JSON",
                                          "Invalid value around character 6"],
                             file: file,
                             line: line)
    }
}


class ArrayOfAnyHashable_DecodableTests: XCTestCase, ArrayDecodableTests {

    // Tests the following method...
    //
    //  extension Array where Element == AnyHashable {
    //      func decode(to encoder: Encoder) throws {
    //
    
    let expression: Expression<AnyHashable> = { jsonData in
        return try [AnyHashable](from: try jsonData.jsonDecoder())
    }
        
    func test_decode_validJson_noProblem() {
        _test_decode_validJson_noProblem()
    }

    func test_decode_invalidJson_throws() {
        _test_decode_invalidJson_throws()
    }
}

class ArrayOfAny_DecodableTests: XCTestCase, ArrayDecodableTests {

    // Tests the following method...
    //
    //  extension Array where Element == Any {
    //      func decode(to encoder: Encoder) throws {
    //
    
    let expression: Expression<Any> = { jsonData in
        return try [Any](from: try jsonData.jsonDecoder())
    }
    
    func test_decode_validJson_noProblem() {
        _test_decode_validJson_noProblem()
    }
    
    func test_decode_invalidJson_throws() {
        _test_decode_invalidJson_throws()
    }
}

class JSONDecoder_ArrayOfAnyHashable_DecodableTests: XCTestCase, ArrayDecodableTests {
    
    // Tests the following method...
    //
    //  extension JSONDecoder {
    //      func decode(_ type: [AnyHashable].Type, from data: Data) throws -> [AnyHashable] {
    //
    
    let expression: Expression<Any> = { jsonData in
        return try JSONDecoder.default.decode([AnyHashable].self, from: jsonData)
    }
    
    func test_decode_validJson_noProblem() {
        _test_decode_validJson_noProblem()
    }
    
    func test_decode_invalidJson_throws() {
        _test_decode_invalidJson_throws()
    }
}

class JSONDecoder_ArrayOfAny_DecodableTests: XCTestCase, ArrayDecodableTests {
    
    // Tests the following method...
    //
    //  extension JSONDecoder {
    //      func decode(_ type: [Any].Type, from data: Data) throws -> [Any] {
    //
    
    let expression: Expression<Any> = { jsonData in
    return try JSONDecoder.default.decode([Any].self, from: jsonData)
    }
    
    func test_decode_validJson_noProblem() {
        _test_decode_validJson_noProblem()
    }
    
    func test_decode_invalidJson_throws() {
        _test_decode_invalidJson_throws()
    }
}
