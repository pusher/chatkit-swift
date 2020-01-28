import XCTest
@testable import TestUtilities
@testable import PusherChatkit

protocol DictionaryOfAnyHashableEncodableTests {
    
    typealias Expression = (_ dict: [String: AnyHashable]) throws -> Data
    
    var expression: Expression { get }
    
    func test_encode_dictionaryOfAnyHashableWithAllSupportedValueTypes_noProblem()
    func test_encode_dictionaryOfAnyHashableWithUnsupportedValueType_throws()
}

protocol DictionaryOfAnyEncodableTests {
    
    typealias Expression = (_ dict: [String: Any]) throws -> Data
    
    var expression: Expression { get }
    
    func test_encode_dictionaryOfAnyWithAllSupportedValueTypes_noProblem()
    func test_encode_dictionaryOfAnyWithUnsupportedValueType_throws()
}

extension DictionaryOfAnyHashableEncodableTests {
    
    fileprivate func _test_encode_dictionaryOfAnyHashableWithAllSupportedValueTypes_noProblem(file: StaticString = #file, line: UInt = #line) {
        
        let dict = [
            "some-string": "value",
            "some-int": Int.min,
            "some-int8": Int8.min,
            "some-int16": Int16.min,
            "some-int32": Int32.min,
            "some-int64": Int64.min,
            "some-uint": UInt.max,
            "some-uint8": UInt8.max,
            "some-uint16": UInt16.max,
            "some-uint32": UInt32.max,
            "some-uint64": UInt64.max,
            "some-double": Double(0.123456789123456789123456789123456789),
            "some-float": Float(0.123456789123456789123456789123456789),
            "some-date": Date(fromISO8601String: "2017-03-23T11:36:42Z") as AnyHashable,
            "some-string-date": "2017-04-23T11:36:42Z" as AnyHashable,
            "some-bool": true,
            "nested-dict": ["another-string": "x"] as [String: AnyHashable],
            "nested-array": ["arr-string"] as [AnyHashable],
            "empty-dict": [:] as [String: AnyHashable],
            "empty-array": [] as [AnyHashable],
            ] as [String: AnyHashable]
        
        XCTAssertNoThrow(try expression(dict), file: file, line: line) { data in
            let dataAsString = String(bytes: data, encoding: .utf8)
            XCTAssertString(dataAsString, contains: "\"some-string\":\"value\"", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int\":-9223372036854775808", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int8\":-128", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int16\":-32768", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int32\":-2147483648", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int64\":-9223372036854775808", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint\":18446744073709551615", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint8\":255", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint16\":65535", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint32\":4294967295", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint64\":18446744073709551615", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-double\":0.12345678912345678", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-float\":0.12345679104328156", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-date\":\"2017-03-23T11:36:42Z\"", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-string-date\":\"2017-04-23T11:36:42Z\"", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-bool\":true", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"nested-dict\":{\"another-string\":\"x\"}", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"nested-array\":[\"arr-string\"]", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"empty-dict\":{}", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"empty-array\":[]", file: file, line: line)
        }
    }
    
    fileprivate func _test_encode_dictionaryOfAnyHashableWithUnsupportedValueType_throws(file: StaticString = #file, line: UInt = #line) {
        
        let dict = [
            "nonJsonHashable-unsupported": NonJSONHashable()
            ] as [String: AnyHashable]
        
        XCTAssertThrowsError(try expression(dict),
                             containing: ["invalidValue",
                                          "Expected to decode JSON value but found a AnyHashable for key \\\"nonJsonHashable-unsupported\\\" instead"],
                             file: file,
                             line: line)
    }
    
}

extension DictionaryOfAnyEncodableTests {
    
    fileprivate func _test_encode_dictionaryOfAnyWithAllSupportedValueTypes_noProblem(file: StaticString = #file, line: UInt = #line) {
        
        let dict = [
            "some-string": "value",
            "some-int": Int.min,
            "some-int8": Int8.min,
            "some-int16": Int16.min,
            "some-int32": Int32.min,
            "some-int64": Int64.min,
            "some-uint": UInt.max,
            "some-uint8": UInt8.max,
            "some-uint16": UInt16.max,
            "some-uint32": UInt32.max,
            "some-uint64": UInt64.max,
            "some-double": Double(0.123456789123456789123456789123456789),
            "some-float": Float(0.123456789123456789123456789123456789),
            "some-date": Date(fromISO8601String: "2017-03-23T11:36:42Z") as Any,
            "some-string-date": "2017-04-23T11:36:42Z" as Any,
            "some-bool": true,
            "some-optional": nil as Int? as Any,
            "nested-dict": ["another-string": "x"] as [String: Any],
            "nested-array": ["arr-string"] as [Any],
            "null-dict": ["null-key": nil as Int? as Any] as [String: Any],
            "null-array": [nil as Int? as Any] as [Any],
            "empty-dict": [:] as [String: Any],
            "empty-array": [] as [Any],
            ] as [String: Any]
        
        XCTAssertNoThrow(try expression(dict), file: file, line: line) { data in
            let dataAsString = String(bytes: data, encoding: .utf8)
            XCTAssertString(dataAsString, contains: "\"some-string\":\"value\"", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int\":-9223372036854775808", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int8\":-128", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int16\":-32768", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int32\":-2147483648", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-int64\":-9223372036854775808", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint\":18446744073709551615", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint8\":255", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint16\":65535", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint32\":4294967295", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-uint64\":18446744073709551615", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-double\":0.12345678912345678", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-float\":0.12345679104328156", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-date\":\"2017-03-23T11:36:42Z\"", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-string-date\":\"2017-04-23T11:36:42Z\"", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-bool\":true", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"some-optional\":null", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"nested-dict\":{\"another-string\":\"x\"}", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"nested-array\":[\"arr-string\"]", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"null-dict\":{\"null-key\":null}", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"null-array\":[null]", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"empty-dict\":{}", file: file, line: line)
            XCTAssertString(dataAsString, contains: "\"empty-array\":[]", file: file, line: line)
        }
    }
    
    fileprivate func _test_encode_dictionaryOfAnyWithUnsupportedValueType_throws(file: StaticString = #file, line: UInt = #line) {
        
        let dict = [
            "cgrect-unsupported": CGRect.zero
            ] as [String: Any]
        
        XCTAssertThrowsError(try expression(dict),
                             containing: ["invalidValue",
                                          "Expected to decode JSON value but found a CGRect for key \\\"cgrect-unsupported\\\" instead"],
                             file: file,
                             line: line)
    }
}




class DictionaryOfAnyHashable_EncodableTests: XCTestCase, DictionaryOfAnyHashableEncodableTests {
    
    // Tests the following method...
    //
    //  extension Dictionary where Key == String, Value == AnyHashable {
    //      func encode(to encoder: Encoder) throws {
    //
    
    let expression: Expression = { (dict: [String: AnyHashable]) in
        let encodable = EncodableWrapper(dict)
        return try JSONEncoder.default.encode(encodable)
    }
    
    func test_encode_dictionaryOfAnyHashableWithAllSupportedValueTypes_noProblem() {
        _test_encode_dictionaryOfAnyHashableWithAllSupportedValueTypes_noProblem()
    }
    
    func test_encode_dictionaryOfAnyHashableWithUnsupportedValueType_throws() {
        _test_encode_dictionaryOfAnyHashableWithUnsupportedValueType_throws()
    }
}

class DictionaryOfAny_EncodableTests: XCTestCase, DictionaryOfAnyEncodableTests {
    
    // Tests the following method...
    //
    //  extension Dictionary where Key == String, Value == Any {
    //      func encode(to encoder: Encoder) throws {
    //
    
    let expression: Expression = { (dict: [String: Any]) in
        let encodable = EncodableWrapper(dict)
        return try JSONEncoder.default.encode(encodable)
    }
    
    func test_encode_dictionaryOfAnyWithAllSupportedValueTypes_noProblem() {
        _test_encode_dictionaryOfAnyWithAllSupportedValueTypes_noProblem()
    }
    
    func test_encode_dictionaryOfAnyWithUnsupportedValueType_throws() {
        _test_encode_dictionaryOfAnyWithUnsupportedValueType_throws()
    }
}

class JSONEncoder_DictionaryOfAnyHashable_EncodableTests: XCTestCase, DictionaryOfAnyHashableEncodableTests {
    
    // Tests the following method...
    //
    //  extension JSONEncoder {
    //      func encode(_ value: [String: AnyHashable]) throws -> Data {
    //
    
    let expression: Expression = { (dict: [String: AnyHashable]) in
        return try JSONEncoder.default.encode(dict)
    }
    
    func test_encode_dictionaryOfAnyHashableWithAllSupportedValueTypes_noProblem() {
        _test_encode_dictionaryOfAnyHashableWithAllSupportedValueTypes_noProblem()
    }
    
    func test_encode_dictionaryOfAnyHashableWithUnsupportedValueType_throws() {
        _test_encode_dictionaryOfAnyHashableWithUnsupportedValueType_throws()
    }
}

class JSONEncoder_DictionaryOfAny_EncodableTests: XCTestCase, DictionaryOfAnyEncodableTests {
    
    // Tests the following method...
    //
    //  extension JSONEncoder {
    //      func encode(_ value: [String: Any]) throws -> Data {
    //
    
    let expression: Expression = { (dict: [String: Any]) in
        return try JSONEncoder.default.encode(dict)
    }
    
    func test_encode_dictionaryOfAnyWithAllSupportedValueTypes_noProblem() {
        _test_encode_dictionaryOfAnyWithAllSupportedValueTypes_noProblem()
    }
    
    func test_encode_dictionaryOfAnyWithUnsupportedValueType_throws() {
        _test_encode_dictionaryOfAnyWithUnsupportedValueType_throws()
    }
}
