import XCTest
@testable import PusherChatkit

protocol ArrayOfAnyHashableEncodableTests {
    
    typealias Expression = (_ array: [AnyHashable]) throws -> Data
    
    var expression: Expression { get }
    
    func test_encode_arrayOfAnyHashableWithAllSupportedValueTypes_noProblem()
    func test_encode_arrayOfAnyHashableWithUnsupportedValueType_throws()
}

protocol ArrayOfAnyEncodableTests {
    
    typealias Expression = (_ array: [Any]) throws -> Data
    
    var expression: Expression { get }
    
    func test_encode_arrayOfAnyWithAllSupportedValueTypes_noProblem()
    func test_encode_arrayOfAnyWithUnsupportedValueType_throws()
}

extension ArrayOfAnyHashableEncodableTests {
    
    fileprivate func _test_encode_arrayOfAnyHashableWithAllSupportedValueTypes_noProblem(file: StaticString = #file, line: UInt = #line) {
        
        let array = [
            "value",
            Int.min,
            Int8.min,
            Int16.min,
            Int32.min,
            Int64.min,
            UInt.max,
            UInt8.max,
            UInt16.max,
            UInt32.max,
            UInt64.max,
            Double(0.123456789123456789123456789123456789),
            Float(0.123456789123456789123456789123456789),
            Date(fromISO8601String: "2017-03-23T11:36:42Z") as AnyHashable,
            "2017-04-23T11:36:42Z",
            true,
            ["another-string": "x"] as [String: AnyHashable],
            ["arr-string"] as [AnyHashable],
            [:] as [String: AnyHashable],
            [] as [AnyHashable],
        ] as [AnyHashable]
        
        XCTAssertNoThrow(try expression(array), file: file, line: line) { data in
            let dataAsString = String(bytes: data, encoding: .utf8)
            var expectedString = "["
            expectedString.append("\"value\",")
            expectedString.append("-9223372036854775808,")
            expectedString.append("-128,")
            expectedString.append("-32768,")
            expectedString.append("-2147483648,")
            expectedString.append("-9223372036854775808,")
            expectedString.append("18446744073709551615,")
            expectedString.append("255,")
            expectedString.append("65535,")
            expectedString.append("4294967295,")
            expectedString.append("18446744073709551615,")
            expectedString.append("0.12345678912345678,")
            expectedString.append("0.12345679104328156,")
            expectedString.append("\"2017-03-23T11:36:42Z\",")
            expectedString.append("\"2017-04-23T11:36:42Z\",")
            expectedString.append("true,")
            expectedString.append("{\"another-string\":\"x\"},")
            expectedString.append("[\"arr-string\"],")
            expectedString.append("{},")
            expectedString.append("[]")
            expectedString.append("]")
            XCTAssertEqual(dataAsString, expectedString, file: file, line: line)
        }
    }
    
    fileprivate func _test_encode_arrayOfAnyHashableWithUnsupportedValueType_throws(file: StaticString = #file, line: UInt = #line) {
        
        let array = [ NonJSONHashable() ] as [AnyHashable]
        
        XCTAssertThrowsError(try expression(array),
                             containing: ["invalidValue",
                                          "Expected to decode JSON value but found a AnyHashable at index 0 instead"],
                             file: file,
                             line: line)
    }
    
}

extension ArrayOfAnyEncodableTests {
    
    fileprivate func _test_encode_arrayOfAnyWithAllSupportedValueTypes_noProblem(file: StaticString = #file, line: UInt = #line) {
        
        let array = [
            "value",
            Int.min,
            Int8.min,
            Int16.min,
            Int32.min,
            Int64.min,
            UInt.max,
            UInt8.max,
            UInt16.max,
            UInt32.max,
            UInt64.max,
            Double(0.123456789123456789123456789123456789),
            Float(0.123456789123456789123456789123456789),
            Date(fromISO8601String: "2017-03-23T11:36:42Z") as Any,
            "2017-04-23T11:36:42Z",
            true,
            nil as Int? as Any,
            ["another-string": "x"] as [String: Any],
            ["arr-string"] as [Any],
            ["null-key": nil as Int? as Any] as [String: Any],
            [nil as Int? as Any] as [Any],
            [:] as [String: Any],
            [] as [Any],
        ] as [Any]
        
        XCTAssertNoThrow(try expression(array), file: file, line: line) { data in
            let dataAsString = String(bytes: data, encoding: .utf8)
            var expectedString = "["
            expectedString.append("\"value\",")
            expectedString.append("-9223372036854775808,")
            expectedString.append("-128,")
            expectedString.append("-32768,")
            expectedString.append("-2147483648,")
            expectedString.append("-9223372036854775808,")
            expectedString.append("18446744073709551615,")
            expectedString.append("255,")
            expectedString.append("65535,")
            expectedString.append("4294967295,")
            expectedString.append("18446744073709551615,")
            expectedString.append("0.12345678912345678,")
            expectedString.append("0.12345679104328156,")
            expectedString.append("\"2017-03-23T11:36:42Z\",")
            expectedString.append("\"2017-04-23T11:36:42Z\",")
            expectedString.append("true,")
            expectedString.append("null,")
            expectedString.append("{\"another-string\":\"x\"},")
            expectedString.append("[\"arr-string\"],")
            expectedString.append("{\"null-key\":null},")
            expectedString.append("[null],")
            expectedString.append("{},")
            expectedString.append("[]")
            expectedString.append("]")
            XCTAssertEqual(dataAsString, expectedString, file: file, line: line)
        }

    }
    
    fileprivate func _test_encode_arrayOfAnyWithUnsupportedValueType_throws(file: StaticString = #file, line: UInt = #line) {
        
        let array = [ CGRect.zero ] as [Any]
        
        XCTAssertThrowsError(try expression(array),
                             containing: ["invalidValue",
                                          "Expected to decode JSON value but found a CGRect at index 0 instead"],
                             file: file,
                             line: line)
    }
}




class ArrayOfAnyHashable_EncodableTests: XCTestCase, ArrayOfAnyHashableEncodableTests {
    
    // Tests the following method...
    //
    //  extension Array where Element == AnyHashable {
    //      func encode(to encoder: Encoder) throws {
    //
    
    let expression: Expression = { (array: [AnyHashable]) in
        let encodable = EncodableWrapper(array)
        return try JSONEncoder.default.encode(encodable)
    }
    
    func test_encode_arrayOfAnyHashableWithAllSupportedValueTypes_noProblem() {
        _test_encode_arrayOfAnyHashableWithAllSupportedValueTypes_noProblem()
    }
    
    func test_encode_arrayOfAnyHashableWithUnsupportedValueType_throws() {
        _test_encode_arrayOfAnyHashableWithUnsupportedValueType_throws()
    }
}

class ArrayOfAny_EncodableTests: XCTestCase, ArrayOfAnyEncodableTests {
    
    // Tests the following method...
    //
    //  extension Array where Element == Any {
    //      func encode(to encoder: Encoder) throws {
    //
    
    let expression: Expression = { (array: [Any]) in
        let encodable = EncodableWrapper(array)
        return try JSONEncoder.default.encode(encodable)
    }
    
    func test_encode_arrayOfAnyWithAllSupportedValueTypes_noProblem() {
        _test_encode_arrayOfAnyWithAllSupportedValueTypes_noProblem()
    }
    
    func test_encode_arrayOfAnyWithUnsupportedValueType_throws() {
        _test_encode_arrayOfAnyWithUnsupportedValueType_throws()
    }
}

class JSONEncoder_ArrayOfAnyHashable_EncodableTests: XCTestCase, ArrayOfAnyHashableEncodableTests {
    
    // Tests the following method...
    //
    //  extension JSONEncoder {
    //      func encode(_ value: [AnyHashable]) throws -> Data {
    //
    
    let expression: Expression = { (array: [AnyHashable]) in
        return try JSONEncoder.default.encode(array)
    }
    
    func test_encode_arrayOfAnyHashableWithAllSupportedValueTypes_noProblem() {
        _test_encode_arrayOfAnyHashableWithAllSupportedValueTypes_noProblem()
    }
    
    func test_encode_arrayOfAnyHashableWithUnsupportedValueType_throws() {
        _test_encode_arrayOfAnyHashableWithUnsupportedValueType_throws()
    }
}

class JSONEncoder_ArrayOfAny_EncodableTests: XCTestCase, ArrayOfAnyEncodableTests {
    
    // Tests the following method...
    //
    //  extension JSONEncoder {
    //      func encode(_ value: [Any]) throws -> Data {
    //
    
    let expression: Expression = { (array: [Any]) in
        return try JSONEncoder.default.encode(array)
    }
    
    func test_encode_arrayOfAnyWithAllSupportedValueTypes_noProblem() {
        _test_encode_arrayOfAnyWithAllSupportedValueTypes_noProblem()
    }
    
    func test_encode_arrayOfAnyWithUnsupportedValueType_throws() {
        _test_encode_arrayOfAnyWithUnsupportedValueType_throws()
    }
}
