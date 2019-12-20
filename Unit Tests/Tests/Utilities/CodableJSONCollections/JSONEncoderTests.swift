import XCTest
@testable import PusherChatkit

class JSONEncoderTests: XCTestCase {
    
    // This XCTestCase exists to test the following methods...
    //
    //  extension JSONEncoder {
    //      func encode(_ value: [String: Any]) throws -> Data {
    //
    //  extension JSONEncoder {
    //      func encode(_ value: [Any]) throws -> Data {
    
    func test_encode_dictionaryAllSupportedValueTypes_noProblem() {

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
            "some-bool": true,
            "some-optional": nil as Int? as Any,
            "some-date": Date(fromISO8601String: "2017-03-23T11:36:42Z") as Any,
            "nested-dict": [
                "another-string": "x"
                ] as [String: Any],
            "nested-array": [
                "arr-string",
                ] as [Any],
        ] as [String: Any]
        
        let when = {
            try JSONEncoder.default.encode(dict)
        }
        
        XCTAssertNoThrow(try when()) { data in
            let dataAsString = String(bytes: data, encoding: .utf8)
            XCTAssertString(dataAsString, contains: "\"some-string\":\"value\"")
            XCTAssertString(dataAsString, contains: "\"some-int\":-9223372036854775808")
            XCTAssertString(dataAsString, contains: "\"some-int8\":-128")
            XCTAssertString(dataAsString, contains: "\"some-int16\":-32768")
            XCTAssertString(dataAsString, contains: "\"some-int32\":-2147483648")
            XCTAssertString(dataAsString, contains: "\"some-int64\":-9223372036854775808")
            XCTAssertString(dataAsString, contains: "\"some-uint\":18446744073709551615")
            XCTAssertString(dataAsString, contains: "\"some-uint8\":255")
            XCTAssertString(dataAsString, contains: "\"some-uint16\":65535")
            XCTAssertString(dataAsString, contains: "\"some-uint32\":4294967295")
            XCTAssertString(dataAsString, contains: "\"some-uint64\":18446744073709551615")
            XCTAssertString(dataAsString, contains: "\"some-double\":0.12345678912345678")
            XCTAssertString(dataAsString, contains: "\"some-float\":0.12345679104328156")
            XCTAssertString(dataAsString, contains: "\"some-date\":\"2017-03-23T11:36:42Z\"")
            XCTAssertString(dataAsString, contains: "\"some-bool\":true")
            XCTAssertString(dataAsString, contains: "\"some-optional\":null")
            XCTAssertString(dataAsString, contains: "\"nested-dict\":{\"another-string\":\"x\"}")
            XCTAssertString(dataAsString, contains: "\"nested-array\":[\"arr-string\"]")
        }
    }
    
    func test_encode_dictionaryWithUnsupportedValueType_throws() {

        let dict = [
            "cgrect-unsupported": CGRect.zero
        ] as [String: Any]
        
        let when = {
            try JSONEncoder.default.encode(dict)
        }

        XCTAssertThrowsError(try when(),
                             containing: ["invalidValue",
                                          "\"cgrect-unsupported\"",
                                          "Expected to decode JSON value but found a CGRect instead"])
    }
    
    func test_encode_arrayAllSupportedValueTypes_noProblem() {

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
            "2017-03-23T11:36:42Z",
            true,
            nil as Int? as Any,
            ["another-string": "x"] as [String: Any],
            ["arr-string"] as [Any],
            ["null-key": nil as Int? as Any] as [String: Any],
            [nil as Int? as Any] as [Any],
            [:] as [String: Any],
            [] as [Any],
        ] as [Any]
        
        let when = {
            try JSONEncoder.default.encode(array)
        }
        
        XCTAssertNoThrow(try when()) { data in
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
            expectedString.append("true,")
            expectedString.append("null,")
            expectedString.append("{\"another-string\":\"x\"},")
            expectedString.append("[\"arr-string\"],")
            expectedString.append("{\"null-key\":null},")
            expectedString.append("[null],")
            expectedString.append("{},")
            expectedString.append("[]")
            expectedString.append("]")
            XCTAssertEqual(dataAsString, expectedString)
        }
    }
    
    func test_encode_arrayWithUnsupportedValueType_throws() {

        let array = [
            CGRect.zero
        ] as [Any]
        
        let when = {
            try JSONEncoder.default.encode(array)
        }

        XCTAssertThrowsError(try when(),
                             containing: ["invalidValue",
                                          "Expected to decode JSON value but found a CGRect instead"])
    }
}
