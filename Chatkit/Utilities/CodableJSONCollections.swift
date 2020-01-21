import Foundation

// MARK: - internal extensions

internal extension Dictionary where Key == String, Value == AnyHashable {
    
    init(from decoder: Decoder) throws {
        self.init()
        let keyedContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        self = try decodeDictionaryOfAnyHashable(in: keyedContainer)
    }
    
    func encode(to encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        try encodeDictionaryOfAny(self as [String: Any], in: &keyedContainer)
    }
}

internal extension Dictionary where Key == String, Value == Any {
    
    init(from decoder: Decoder) throws {
        self.init()
        let keyedContainer = try decoder.container(keyedBy: DynamicCodingKeys.self)
        self = try decodeDictionaryOfAny(in: keyedContainer)
    }
    
    func encode(to encoder: Encoder) throws {
        var keyedContainer = encoder.container(keyedBy: DynamicCodingKeys.self)
        try encodeDictionaryOfAny(self, in: &keyedContainer)
    }
}

internal extension Array where Element == AnyHashable {
    
    init(from decoder: Decoder) throws {
        self.init()
        var unkeyedContainer = try decoder.unkeyedContainer()
        self = try decodeArrayOfAnyHashable(in: &unkeyedContainer)
    }
    
    func encode(to encoder: Encoder) throws {
        var unkeyedContainer = encoder.unkeyedContainer()
        try encodeArrayOfAny(self as [Any], in: &unkeyedContainer)
    }
}

internal extension Array where Element == Any {
    
    init(from decoder: Decoder) throws {
        self.init()
        var unkeyedContainer = try decoder.unkeyedContainer()
        self = try decodeArrayOfAny(in: &unkeyedContainer)
    }
    
    func encode(to encoder: Encoder) throws {
        var unkeyedContainer = encoder.unkeyedContainer()
        try encodeArrayOfAny(self, in: &unkeyedContainer)
    }
}


internal extension JSONDecoder {
    
    func decode(_ type: [String: AnyHashable].Type, from data: Data) throws -> [String: AnyHashable] {
        let decoderWrapper = try self.decode(DecoderWrapper.self, from: data)
        let decoder = decoderWrapper.decoder
        return try [String: AnyHashable](from: decoder)
    }
    func decode(_ type: [String: Any].Type, from data: Data) throws -> [String: Any] {
        let decoderWrapper = try self.decode(DecoderWrapper.self, from: data)
        let decoder = decoderWrapper.decoder
        return try [String: Any](from: decoder)
    }
    
    func decode(_ type: [AnyHashable].Type, from data: Data) throws -> [AnyHashable] {
        let decoderWrapper = try self.decode(DecoderWrapper.self, from: data)
        let decoder = decoderWrapper.decoder
        return try [AnyHashable](from: decoder)
    }
    func decode(_ type: [Any].Type, from data: Data) throws -> [Any] {
        let decoderWrapper = try self.decode(DecoderWrapper.self, from: data)
        let decoder = decoderWrapper.decoder
        return try [Any](from: decoder)
    }
}

internal extension JSONEncoder {
    
    func encode(_ value: [AnyHashable]) throws -> Data {
        let encodableWrapper = EncodableWrapper(value)
        return try self.encode(encodableWrapper)
    }
    func encode(_ value: [Any]) throws -> Data {
        let encodableWrapper = EncodableWrapper(value)
        return try self.encode(encodableWrapper)
    }
    
    func encode(_ value: [String: AnyHashable]) throws -> Data {
        let encodableWrapper = EncodableWrapper(value)
        return try self.encode(encodableWrapper)
    }
    func encode(_ value: [String: Any]) throws -> Data {
        let encodableWrapper = EncodableWrapper(value)
        return try self.encode(encodableWrapper)
    }
}

internal extension KeyedDecodingContainer {
    
    func decode(_ type: [String: AnyHashable].Type, forKey key: K) throws -> [String: AnyHashable] {
        do {
            // Not sure why but the if the call to `self.nestedContainer` throws because the value is
            // `null` the codingPath is not set properly on the `DecodingError` thats thrown.
            // So this code catches that Error and sets the `codingPath` correctly.
            let keyedContainer = try self.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)
            return try decodeDictionaryOfAnyHashable(in: keyedContainer)
        } catch DecodingError.typeMismatch(let type, let context)  {
            let codingPath = context.codingPath.count == 0 ? [key] : context.codingPath
            let context = DecodingError.Context(codingPath: codingPath, debugDescription: context.debugDescription)
            throw DecodingError.typeMismatch(type, context)
        }
    }
    func decode(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any] {
        return try decode([String: AnyHashable].self, forKey: key)
    }
    
    func decodeIfPresent(_ type: [String: AnyHashable].Type, forKey key: K) throws -> [String: AnyHashable]? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    func decodeIfPresent(_ type: [String: Any].Type, forKey key: K) throws -> [String: Any]? {
        return try decodeIfPresent([String: AnyHashable].self, forKey: key)
    }
    
    func decode(_ type: [AnyHashable].Type, forKey key: K) throws -> [AnyHashable] {
        var unkeyedContainer = try self.nestedUnkeyedContainer(forKey: key)
        return try decodeArrayOfAnyHashable(in: &unkeyedContainer)
    }
    func decode(_ type: [Any].Type, forKey key: K) throws -> [Any] {
        return try decode([AnyHashable].self, forKey: key)
    }
    
    func decodeIfPresent(_ type: [AnyHashable].Type, forKey key: K) throws -> [AnyHashable]? {
        guard contains(key) else {
            return nil
        }
        guard try decodeNil(forKey: key) == false else {
            return nil
        }
        return try decode(type, forKey: key)
    }
    func decodeIfPresent(_ type: [Any].Type, forKey key: K) throws -> [Any]? {
        return try decodeIfPresent([AnyHashable].self, forKey: key)
    }
}

internal extension UnkeyedDecodingContainer {
    
    mutating func decode(_ type: [String: AnyHashable].Type) throws -> [String: AnyHashable] {
        let keyedContainer = try self.nestedContainer(keyedBy: DynamicCodingKeys.self)
        return try decodeDictionaryOfAnyHashable(in: keyedContainer)
    }
    mutating func decode(_ type: [String: Any].Type) throws -> [String: Any] {
        return try decode([String: AnyHashable].self)
    }
    
    mutating func decode(_ type: [AnyHashable].Type) throws -> [AnyHashable] {
        var unkeyedContainer = try self.nestedUnkeyedContainer()
        return try decodeArrayOfAnyHashable(in: &unkeyedContainer)
    }
    mutating func decode(_ type: [Any].Type) throws -> [Any] {
        return try decode([AnyHashable].self)
    }
}

internal extension KeyedEncodingContainer {
    
    mutating func encode(_ value: [String: Any], forKey key: Key) throws {
        var keyedContainer = self.nestedContainer(keyedBy: DynamicCodingKeys.self, forKey: key)
        try encodeDictionaryOfAny(value, in: &keyedContainer)
    }

    mutating func encodeIfPresent(_ value: [String: Any]?, forKey key: Key) throws {
        if let value = value {
            try encode(value, forKey: key)
        }
    }
    
    mutating func encode(_ value: [Any], forKey key: Key) throws {
        var unkeyedContainer = self.nestedUnkeyedContainer(forKey: key)
        try encodeArrayOfAny(value, in: &unkeyedContainer)
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
        try encodeDictionaryOfAny(value, in: &keyedContainer)
    }
    
    mutating func encode(_ value: [Any]) throws {
        var unkeyedContainer = self.nestedUnkeyedContainer()
        try encodeArrayOfAny(value, in: &unkeyedContainer)
    }
    
}

// MARK: - internal structs

internal struct DecoderWrapper: Decodable {
    
    let decoder: Decoder
    
    init(from decoder: Decoder) throws {
        self.decoder = decoder
    }
}

internal struct EncodableWrapper: Encodable {
    
    private let _encode: (Encoder) throws -> Void
    
    public init(_ wrapped: [String: AnyHashable]) {
        _encode = wrapped.encode
    }
    public init(_ wrapped: [String: Any]) {
        _encode = wrapped.encode
    }
    
    public init(_ wrapped: [AnyHashable]) {
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

fileprivate func decodeDictionaryOfAnyHashable(in keyedContainer: KeyedDecodingContainer<DynamicCodingKeys>) throws -> [String: AnyHashable] {
    var dict = [String: AnyHashable]()
    for key in keyedContainer.allKeys {
        let value = try decodeAnyHashable(forKey: key, in: keyedContainer)
        dict[key.stringValue] = value
    }
    return dict
}

fileprivate func decodeDictionaryOfAny(in keyedContainer: KeyedDecodingContainer<DynamicCodingKeys>) throws -> [String: Any] {
    var dict = [String: Any]()
    for key in keyedContainer.allKeys {
        let value = try decodeAny(forKey: key, in: keyedContainer)
        dict[key.stringValue] = value
    }
    return dict
}

fileprivate func decodeArrayOfAnyHashable(in unkeyedContainer: inout UnkeyedDecodingContainer) throws -> [AnyHashable] {
    var array: [AnyHashable] = []
    while !unkeyedContainer.isAtEnd {
        let value = try decodeAnyHashable(at: array.count, in: &unkeyedContainer)
        array.append(value)
    }
    return array
}

fileprivate func decodeArrayOfAny(in unkeyedContainer: inout UnkeyedDecodingContainer) throws -> [Any] {
    var array: [Any] = []
    while !unkeyedContainer.isAtEnd {
        let value = try decodeAny(at: array.count, in: &unkeyedContainer)
        array.append(value)
    }
    return array
}

fileprivate func decodeAny(forKey key: DynamicCodingKeys, in keyedContainer: KeyedDecodingContainer<DynamicCodingKeys>) throws -> Any {
    do {
        return try decodeAnyValue(forKey: key, in: keyedContainer)
    }
    catch let error as DecodingError {
        if case .dataCorrupted = error {
            
            if let value = try? keyedContainer.decode([String: Any].self, forKey: key) {
                return value
            }
            else if let value = try? keyedContainer.decode([Any].self, forKey: key) {
                return value
            }
        }
        throw error
    }
}

fileprivate func decodeAnyHashable(forKey key: DynamicCodingKeys, in keyedContainer: KeyedDecodingContainer<DynamicCodingKeys>) throws -> AnyHashable {
    do {
        return try decodeAnyValue(forKey: key, in: keyedContainer)
    }
    catch let error as DecodingError {
        if case .dataCorrupted = error {
            
            if let value = try? keyedContainer.decode([String: AnyHashable].self, forKey: key) {
                return value
            }
            else if let value = try? keyedContainer.decode([AnyHashable].self, forKey: key) {
                return value
            }
        }
        throw error
    }
}

fileprivate func decodeAnyValue(forKey key: DynamicCodingKeys, in keyedContainer: KeyedDecodingContainer<DynamicCodingKeys>) throws -> AnyHashable {
    
    // Null
    if try keyedContainer.decodeNil(forKey: key) {
        return NSNull()
    }
    
    // Single Value
    if let value = try? keyedContainer.decode(Bool.self, forKey: key) {
        return value
    }
    else if let value = try? keyedContainer.decode(Int.self, forKey: key) {
        return value
    }
    else if let value = try? keyedContainer.decode(Int64.self, forKey: key) {
        return value
    }
    else if let value = try? keyedContainer.decode(Double.self, forKey: key) {
        return value
    }
    else if let value = try? keyedContainer.decode(Date.self, forKey: key) {
        return value
    }
    else if let value = try? keyedContainer.decode(String.self, forKey: key) {
        return value
    }
    
    // Unexpected
    else {
        let desc = "Expected to decode JSON value but got something unexpected instead for key \(key)"
        throw DecodingError.dataCorruptedError(forKey: key,
                                               in: keyedContainer,
                                               debugDescription: desc)
    }
}

fileprivate func decodeAnyHashable(at index: Int, in unkeyedContainer: inout UnkeyedDecodingContainer) throws -> AnyHashable {
    do {
        return try decodeAnyValue(at: index, in: &unkeyedContainer)
    }
    catch let error as DecodingError {
        if case .dataCorrupted = error {
            
            if let value = try? unkeyedContainer.decode([String: AnyHashable].self) {
                return value
            }
            else if let value = try? unkeyedContainer.decode([AnyHashable].self) {
                return value
            }
        }
        throw error
    }
}

fileprivate func decodeAny(at index: Int, in unkeyedContainer: inout UnkeyedDecodingContainer) throws -> Any {
    do {
        return try decodeAnyValue(at: index, in: &unkeyedContainer)
    }
    catch let error as DecodingError {
        if case .dataCorrupted = error {
            
            if let value = try? unkeyedContainer.decode([String: Any].self) {
                return value
            }
            else if let value = try? unkeyedContainer.decode([Any].self) {
                return value
            }
        }
        throw error
    }
}

fileprivate func decodeAnyValue(at index: Int, in unkeyedContainer: inout UnkeyedDecodingContainer) throws -> AnyHashable {
    
    // Null
    if try unkeyedContainer.decodeNil() {
        return NSNull()
    }

    // Single Value
    else if let value = try? unkeyedContainer.decode(Bool.self) {
        return value
    }
    else if let value = try? unkeyedContainer.decode(Int.self) {
        return value
    }
    else if let value = try? unkeyedContainer.decode(Int64.self) {
        return value
    }
    else if let value = try? unkeyedContainer.decode(Double.self) {
        return value
    }
    else if let value = try? unkeyedContainer.decode(Date.self) {
        return value
    }
    else if let value = try? unkeyedContainer.decode(String.self) {
        return value
    }
        
    // Unexpected
    else {
        throw DecodingError.dataCorruptedError(in: unkeyedContainer,
                                               debugDescription: "Expected to decode JSON value but got something unexpected instead at index \(index)")
    }
}

fileprivate func encodeDictionaryOfAny(_ value: [String: Any],
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
            let desc = "Expected to decode JSON value but found a \(type(of: value)) for key \(key) instead"
            let context = EncodingError.Context(codingPath: [key], debugDescription: desc)
            throw EncodingError.invalidValue(value, context)
        }
    }
}

fileprivate func encodeArrayOfAny(_ value: [Any],
                                  in unkeyedContainer: inout UnkeyedEncodingContainer) throws {
    for (index, value) in value.enumerated() {
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
            let desc = "Expected to decode JSON value but found a \(type(of: value)) at index \(index) instead"
            let context = EncodingError.Context(codingPath: unkeyedContainer.codingPath,
                                                debugDescription: desc)
            throw EncodingError.invalidValue(value, context)
        }
    }
}
