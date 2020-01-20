import Foundation

// MARK: - internal extensions

internal extension Dictionary where Key == String, Value == Any {
    
    init(from decoder: Decoder) throws {
        self.init()
        let keyedContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        self = try decodeDict(in: keyedContainer)
    }
    
    func encode(to encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        try encodeDict(self, in: &keyedContainer)
    }
}

internal extension Array where Element == Any {
    
    init(from decoder: Decoder) throws {
        self.init()
        var unkeyedContainer = try decoder.unkeyedContainer()
        self = try decodeArray(in: &unkeyedContainer)
    }
    
    func encode(to encoder: Encoder) throws {
        var unkeyedContainer = encoder.unkeyedContainer()
        try encodeArray(self, in: &unkeyedContainer)
    }
}

internal extension JSONDecoder {
    
    func decode(_ type: [String: Any].Type, from data: Data) throws -> [String: Any] {
        let decoderWrapper = try self.decode(DecoderWrapper.self, from: data)
        let decoder = decoderWrapper.decoder
        return try [String: Any](from: decoder)
    }
    
    func decode(_ type: [Any].Type, from data: Data) throws -> [Any] {
        let decoderWrapper = try self.decode(DecoderWrapper.self, from: data)
        let decoder = decoderWrapper.decoder
        return try [Any](from: decoder)
    }
}

internal extension JSONEncoder {
    
    func encode(_ value: [Any]) throws -> Data {
        let encodableWrapper = EncodableWrapper(value)
        return try self.encode(encodableWrapper)
    }
    
    func encode(_ value: [String: Any]) throws -> Data {
        let encodableWrapper = EncodableWrapper(value)
        return try self.encode(encodableWrapper)
    }
}

internal extension KeyedDecodingContainer {
    
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        do {
            // Not sure why but the if the call to `self.nestedContainer` throws because the value is
            // `null` the codingPath is not set properly on the `DecodingError` thats thrown.
            // So this code catches that Error and sets the `codingPath` correctly.
            let keyedContainer = try self.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)
            return try decodeDict(in: keyedContainer)
        } catch DecodingError.typeMismatch(let type, let context)  {
            let codingPath = context.codingPath.count == 0 ? [key] : context.codingPath
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: context.debugDescription)
            throw DecodingError.typeMismatch(type, context)
        }
    }
    
    func decodeIfPresent(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any]? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    
    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        var unkeyedContainer = try self.nestedUnkeyedContainer(forKey: key)
        return try decodeArray(in: &unkeyedContainer)
    }
    
    func decodeIfPresent(_ type: [Any].Type, forKey key: K) throws -> [Any]? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
}

internal extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        let keyedContainer = try self.nestedContainer(keyedBy: DynamicCodingKeys.self)
        return try decodeDict(in: keyedContainer)
    }

    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        var unkeyedContainer = try self.nestedUnkeyedContainer()
        return try decodeArray(in: &unkeyedContainer)
    }
}

internal extension KeyedEncodingContainer {
    
    mutating func encode(_ value: [String: Any], forKey key: Key) throws {
        var keyedContainer = self.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)
        try encodeDict(value, in: &keyedContainer)
    }

    mutating func encodeIfPresent(_ value: [String: Any]?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
    
    mutating func encode(_ value: [Any], forKey key: Key) throws {
        var unkeyedContainer = self.nestedUnkeyedContainer(forKey: key)
        try encodeArray(value, in: &unkeyedContainer)
    }

    mutating func encodeIfPresent(_ value: [Any]?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
    
}

internal extension UnkeyedEncodingContainer {

    mutating func encode(_ value: [String: Any]) throws {
        var keyedContainer = self.nestedContainer(keyedBy: DynamicCodingKeys.self)
        try encodeDict(value, in: &keyedContainer)
    }
    
    mutating func encode(_ value: [Any]) throws {
        var unkeyedContainer = self.nestedUnkeyedContainer()
        try encodeArray(value, in: &unkeyedContainer)
    }
    
}

// MARK: - internal structs

internal struct DecoderWrapper: Decodable {
    
    // MARK: - Properties
    
    let decoder: Decoder
    
    // MARK: - Initializers
    
    init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
}

internal struct EncodableWrapper: Encodable {
    
    private let _encode: (Encoder) throws -> Void
    
    public init(_ wrapped: [String: Any]) {
        _encode = wrapped.encode
    }
    
    public init(_ wrapped: [Any]) {
        _encode = wrapped.encode
    }
    
    func encode(to encoder: Encoder) throws {
        try _encode(encoder)
    }
}

// MARK: - fileprivate helpers

fileprivate struct DynamicCodingKeys: CodingKey {
    
    var stringValue: String
    var intValue: Int?
    
    init?(stringValue: String) {
        self.stringValue = stringValue
    }
    
    init?(intValue: Int) {
        self.init(stringValue: "\(intValue)")
        self.intValue = intValue
    }
    
    var description: String {
        return "\"\(stringValue)\""
    }
}

fileprivate func decodeDict(in keyedContainer: KeyedDecodingContainer<DynamicCodingKeys>) throws -> [String: Any] {
    
    var dict = [String: Any]()
    for key in keyedContainer.allKeys {
        // Single Value
        if let value = try? keyedContainer.decode(Bool.self, forKey: key) {
            dict[key.stringValue] = value
        }
        else if let value = try? keyedContainer.decode(Int.self, forKey: key) {
            dict[key.stringValue] = value
        }
        else if let value = try? keyedContainer.decode(Int64.self, forKey: key) {
            dict[key.stringValue] = value
        }
        else if let value = try? keyedContainer.decode(Double.self, forKey: key) {
            dict[key.stringValue] = value
        }
        else if let value = try? keyedContainer.decode(Date.self, forKey: key) {
            dict[key.stringValue] = value
        }
        else if let value = try? keyedContainer.decode(String.self, forKey: key) {
            dict[key.stringValue] = value
        }
            
        // Collection
        else if let value = try? keyedContainer.decode([String: Any].self, forKey: key) {
            dict[key.stringValue] = value
        }
        else if let value = try? keyedContainer.decode([Any].self, forKey: key) {
            dict[key.stringValue] = value
        }
            
        // Null
        else if try keyedContainer.decodeNil(forKey: key) {
            dict[key.stringValue] = NSNull()
        }
            
        // Unexpected
        else {
            let desc = "Unexpected format/type for key: '\(key)'"
            throw DecodingError.dataCorruptedError(forKey: key,
                                                   in: keyedContainer,
                                                   debugDescription: desc)
        }
    }
    return dict
}

fileprivate func decodeArray(in unkeyedContainer: inout UnkeyedDecodingContainer) throws -> [Any] {
    var array: [Any] = []
    while !unkeyedContainer.isAtEnd {
        
        // Null
        if try unkeyedContainer.decodeNil() {
            array.append(NSNull())
        }
        
        // Single Value
        else if let value = try? unkeyedContainer.decode(Bool.self) {
            array.append(value)
        }
        else if let value = try? unkeyedContainer.decode(Int.self) {
            array.append(value)
        }
        else if let value = try? unkeyedContainer.decode(Int64.self) {
            array.append(value)
        }
        else if let value = try? unkeyedContainer.decode(Double.self) {
            array.append(value)
        }
        else if let value = try? unkeyedContainer.decode(Date.self) {
            array.append(value)
        }
        else if let value = try? unkeyedContainer.decode(String.self) {
            array.append(value)
        }
            
        // Collection
        else if let value = try? unkeyedContainer.decode([String: Any].self) {
            array.append(value)
        }
        else if let value = try? unkeyedContainer.decode([Any].self) {
            array.append(value)
        }
        
        // Unexpected
        else {
            throw DecodingError.dataCorruptedError(in: unkeyedContainer,
                                                   debugDescription: "Unexpected format/type in array.")
        }
    }
    return array
}

fileprivate func encodeDict(_ value: [String: Any],
                            in keyedContainer: inout KeyedEncodingContainer<DynamicCodingKeys>) throws {

    for (key, value) in value {
        let key = DynamicCodingKeys(stringValue: key)!

        switch value {
            
        // Single value
        case let value as Bool:
            try keyedContainer.encode(value, forKey: key)
        case let value as Int:
            try keyedContainer.encode(value, forKey: key)
        case let value as Int8:
            try keyedContainer.encode(value, forKey: key)
        case let value as Int16:
            try keyedContainer.encode(value, forKey: key)
        case let value as Int32:
            try keyedContainer.encode(value, forKey: key)
        case let value as Int64:
            try keyedContainer.encode(value, forKey: key)
        case let value as UInt:
            try keyedContainer.encode(value, forKey: key)
        case let value as UInt8:
            try keyedContainer.encode(value, forKey: key)
        case let value as UInt16:
            try keyedContainer.encode(value, forKey: key)
        case let value as UInt32:
            try keyedContainer.encode(value, forKey: key)
        case let value as UInt64:
            try keyedContainer.encode(value, forKey: key)
        case let value as Float:
            try keyedContainer.encode(value, forKey: key)
        case let value as Double:
            try keyedContainer.encode(value, forKey: key)
        case let value as Date:
            try keyedContainer.encode(value, forKey: key)
        case let value as URL:
            try keyedContainer.encode(value, forKey: key)
        case let value as String:
            try keyedContainer.encode(value, forKey: key)
            
        // Collection
        case let value as [String: Any]:
            try keyedContainer.encode(value, forKey: key)
        case let value as [Any]:
            try keyedContainer.encode(value, forKey: key)
            
        // Null
        case Optional<Any>.none:
            try keyedContainer.encodeNil(forKey: key)
            
        default:
            let desc = "Expected to decode JSON value but found a \(type(of: value)) instead"
            let context = EncodingError.Context(codingPath: [key], debugDescription: desc)
            throw EncodingError.invalidValue(value, context)
        }
    }
}

fileprivate func encodeArray(_ value: [Any],
                             in unkeyedContainer: inout UnkeyedEncodingContainer) throws {
    for value in value {
        switch value {
            
        // Single value
        case let value as Bool:
            try unkeyedContainer.encode(value)
        case let value as Int:
            try unkeyedContainer.encode(value)
        case let value as Int8:
            try unkeyedContainer.encode(value)
        case let value as Int16:
            try unkeyedContainer.encode(value)
        case let value as Int32:
            try unkeyedContainer.encode(value)
        case let value as Int64:
            try unkeyedContainer.encode(value)
        case let value as UInt:
            try unkeyedContainer.encode(value)
        case let value as UInt8:
            try unkeyedContainer.encode(value)
        case let value as UInt16:
            try unkeyedContainer.encode(value)
        case let value as UInt32:
            try unkeyedContainer.encode(value)
        case let value as UInt64:
            try unkeyedContainer.encode(value)
        case let value as Float:
            try unkeyedContainer.encode(value)
        case let value as Double:
            try unkeyedContainer.encode(value)
        case let value as Date:
            try unkeyedContainer.encode(value)
        case let value as URL:
            try unkeyedContainer.encode(value)
        case let value as String:
            try unkeyedContainer.encode(value)
            
        // Collection
        case let value as [String: Any]:
            try unkeyedContainer.encode(value)
        case let value as [Any]:
            try unkeyedContainer.encode(value)
            
        // Null
        case Optional<Any>.none:
            try unkeyedContainer.encodeNil()
            
        default:
            let desc = "Expected to decode JSON value but found a \(type(of: value)) instead"
            let context = EncodingError.Context(codingPath: unkeyedContainer.codingPath,
                                                debugDescription: desc)
            throw EncodingError.invalidValue(value, context)
        }
    }
}
