import Foundation
import CryptoSwift

func generateHMAC(message: Data) -> Data {
    let key = testInstanceKeySecret.data(using: .utf8)!
    let mac = HMAC(key: key.bytes, variant: .sha256)

    let result: [UInt8]
    do {
        result = try mac.authenticate(message.bytes)
    } catch {
        result = []
    }

    return Data(bytes: result)
}

/// URI Safe base64 encode
func base64encode(_ input: Data) -> String {
    let data = input.base64EncodedData()
    let string = String(data: data, encoding: .utf8)!
    return string
        .replacingOccurrences(of: "+", with: "-")
        .replacingOccurrences(of: "/", with: "_")
        .replacingOccurrences(of: "=", with: "")
}

/// URI Safe base64 decode
func base64decode(_ input: String) -> Data? {
    let rem = input.count % 4

    var ending = ""
    if rem > 0 {
        let amount = 4 - rem
        ending = String(repeating: "=", count: amount)
    }

    let base64 = input.replacingOccurrences(of: "-", with: "+")
        .replacingOccurrences(of: "_", with: "/") + ending

    return Data(base64Encoded: base64)
}

func parseTimeInterval(_ value: Any?) -> Date? {
    guard let value = value else { return nil }

    if let string = value as? String, let interval = TimeInterval(string) {
        return Date(timeIntervalSince1970: interval)
    }

    if let interval = value as? TimeInterval {
        return Date(timeIntervalSince1970: interval)
    }

    return nil
}

public struct ClaimSet {
    var claims: [String: Any]

    public init(claims: [String: Any]? = nil) {
        self.claims = claims ?? [:]
    }

    public subscript(key: String) -> Any? {
        get {
            return claims[key]
        }

        set {
            if let newValue = newValue, let date = newValue as? Date {
                claims[key] = date.timeIntervalSince1970.rounded(.down)
            } else {
                claims[key] = newValue
            }
        }
    }
}

// MARK: Accessors

extension ClaimSet {
    public var issuer: String? {
        get {
            return claims["iss"] as? String
        }

        set {
            claims["iss"] = newValue
        }
    }

    public var audience: String? {
        get {
            return claims["aud"] as? String
        }

        set {
            claims["aud"] = newValue
        }
    }

    public var expiration: Date? {
        get {
            return parseTimeInterval(claims["exp"])
        }

        set {
            self["exp"] = newValue
        }
    }

    public var notBefore: Date? {
        get {
            return parseTimeInterval(claims["nbf"])
        }

        set {
            self["nbf"] = newValue
        }
    }

    public var issuedAt: Date? {
        get {
            return parseTimeInterval(claims["iat"])
        }

        set {
            self["iat"] = newValue
        }
    }
}

// MARK: Validations

extension ClaimSet {
    public func validate(audience: String? = nil, issuer: String? = nil, leeway: TimeInterval = 0) throws {
        if let issuer = issuer {
            try validateIssuer(issuer)
        }

        if let audience = audience {
            try validateAudience(audience)
        }

        try validateExpiary(leeway: leeway)
        try validateNotBefore(leeway: leeway)
        try validateIssuedAt(leeway: leeway)
    }

    public func validateAudience(_ audience: String) throws {
        if let aud = self["aud"] as? [String] {
            if !aud.contains(audience) {
                throw InvalidToken.invalidAudience
            }
        } else if let aud = self["aud"] as? String {
            if aud != audience {
                throw InvalidToken.invalidAudience
            }
        } else {
            throw InvalidToken.decodeError("Invalid audience claim, must be a string or an array of strings")
        }
    }

    public func validateIssuer(_ issuer: String) throws {
        if let iss = self["iss"] as? String {
            if iss != issuer {
                throw InvalidToken.invalidIssuer
            }
        } else {
            throw InvalidToken.invalidIssuer
        }
    }

    public func validateExpiary(leeway: TimeInterval = 0) throws {
        try validateDate(claims, key: "exp", comparison: .orderedAscending, leeway: (-1 * leeway), failure: .expiredSignature, decodeError: "Expiration time claim (exp) must be an integer")
    }

    public func validateNotBefore(leeway: TimeInterval = 0) throws {
        try validateDate(claims, key: "nbf", comparison: .orderedDescending, leeway: leeway, failure: .immatureSignature, decodeError: "Not before claim (nbf) must be an integer")
    }

    public func validateIssuedAt(leeway: TimeInterval = 0) throws {
        try validateDate(claims, key: "iat", comparison: .orderedDescending, leeway: leeway, failure: .invalidIssuedAt, decodeError: "Issued at claim (iat) must be an integer")
    }
}

// MARK: Builder

public class ClaimSetBuilder {
    var claims = ClaimSet()

    public var issuer: String? {
        get {
            return claims.issuer
        }

        set {
            claims.issuer = newValue
        }
    }

    public var audience: String? {
        get {
            return claims.audience
        }

        set {
            claims.audience = newValue
        }
    }

    public var expiration: Date? {
        get {
            return claims.expiration
        }

        set {
            claims.expiration = newValue
        }
    }

    public var notBefore: Date? {
        get {
            return claims.notBefore
        }

        set {
            claims.notBefore = newValue
        }
    }

    public var issuedAt: Date? {
        get {
            return claims.issuedAt
        }

        set {
            claims.issuedAt = newValue
        }
    }

    public subscript(key: String) -> Any? {
        get {
            return claims[key]
        }

        set {
            claims[key] = newValue
        }
    }
}

typealias PayloadBuilder = ClaimSetBuilder

func validateDate(_ payload: Payload, key: String, comparison: ComparisonResult, leeway: TimeInterval = 0, failure: InvalidToken, decodeError: String) throws {
    if payload[key] == nil {
        return
    }

    guard let date = extractDate(payload: payload, key: key) else {
        throw InvalidToken.decodeError(decodeError)
    }

    if date.compare(Date().addingTimeInterval(leeway)) == comparison {
        throw failure
    }
}

fileprivate func extractDate(payload: Payload, key: String) -> Date? {
    if let timestamp = payload[key] as? TimeInterval {
        return Date(timeIntervalSince1970: timestamp)
    }

    if let timestamp = payload[key] as? Int {
        return Date(timeIntervalSince1970: Double(timestamp))
    }

    if let timestampString = payload[key] as? String, let timestamp = Double(timestampString) {
        return Date(timeIntervalSince1970: timestamp)
    }

    return nil
}

class CompactJSONDecoder: JSONDecoder {
    override func decode<T>(_ type: T.Type, from data: Data) throws -> T where T : Decodable {
        guard let string = String(data: data, encoding: .ascii) else {
            throw InvalidToken.decodeError("data should contain only ASCII characters")
        }

        return try decode(type, from: string)
    }

    func decode<T>(_ type: T.Type, from string: String) throws -> T where T : Decodable {
        guard let decoded = base64decode(string) else {
            throw InvalidToken.decodeError("data should be a valid base64 string")
        }

        return try super.decode(type, from: decoded)
    }

    func decode(from string: String) throws -> Payload {
        guard let decoded = base64decode(string) else {
            throw InvalidToken.decodeError("Payload is not correctly encoded as base64")
        }

        let object = try JSONSerialization.jsonObject(with: decoded)
        guard let payload = object as? Payload else {
            throw InvalidToken.decodeError("Invalid payload")
        }

        return payload
    }
}

class CompactJSONEncoder: JSONEncoder {
    override func encode<T : Encodable>(_ value: T) throws -> Data {
        return try encodeString(value).data(using: .ascii) ?? Data()
    }

    func encodeString<T: Encodable>(_ value: T) throws -> String {
        return base64encode(try super.encode(value))
    }

    func encodeString(_ value: [String: Any]) -> String? {
        if let data = try? JSONSerialization.data(withJSONObject: value) {
            return base64encode(data)
        }

        return nil
    }
}

/// Failure reasons from decoding a JWT
public enum InvalidToken: CustomStringConvertible, Error {
    /// Decoding the JWT itself failed
    case decodeError(String)

    /// The JWT uses an unsupported algorithm
    case invalidAlgorithm

    /// The issued claim has expired
    case expiredSignature

    /// The issued claim is for the future
    case immatureSignature

    /// The claim is for the future
    case invalidIssuedAt

    /// The audience of the claim doesn't match
    case invalidAudience

    /// The issuer claim failed to verify
    case invalidIssuer

    /// Returns a readable description of the error
    public var description: String {
        switch self {
        case .decodeError(let error):
            return "Decode Error: \(error)"
        case .invalidIssuer:
            return "Invalid Issuer"
        case .expiredSignature:
            return "Expired Signature"
        case .immatureSignature:
            return "The token is not yet valid (not before claim)"
        case .invalidIssuedAt:
            return "Issued at claim (iat) is in the future"
        case .invalidAudience:
            return "Invalid Audience"
        case .invalidAlgorithm:
            return "Unsupported algorithm or incorrect key"
        }
    }
}

public func encode(claims: ClaimSet, headers: [String: String]? = nil) -> String {
    let encoder = CompactJSONEncoder()

    var headers = headers ?? [:]
    if !headers.keys.contains("typ") {
        headers["typ"] = "JWT"
    }
    headers["alg"] = "HS256"

    let header = try! encoder.encodeString(headers)
    let payload = encoder.encodeString(claims.claims)!
    let signingInput = "\(header).\(payload)"
    let signature = base64encode(generateHMAC(message: signingInput.data(using: .utf8)!))
    return "\(signingInput).\(signature)"
}

struct JOSEHeader: Codable {
    /// The "alg" (algorithm) identifies the cryptographic algorithm used to secure the JWS
    var algorithm: String?

    /// The "kid" (key ID) is a hint indicating which key was used to secure the JWS
    var keyID: String?

    /// The "typ" (type) is used by JWS applications to declare the media type [IANA.MediaTypes] of this complete JWS
    var type: String?

    /// The "cty" (content type) is used by JWS application to declare the media type [IANA.MediaTypes] of the secured content (the payload).
    var contentType: String?

    init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        algorithm = try container.decodeIfPresent(String.self, forKey: .algorithm)
        keyID = try container.decodeIfPresent(String.self, forKey: .keyID)
        type = try container.decodeIfPresent(String.self, forKey: .type)
        contentType = try container.decodeIfPresent(String.self, forKey: .contentType)
    }

    func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encodeIfPresent(algorithm, forKey: .algorithm)
        try container.encodeIfPresent(keyID, forKey: .keyID)
        try container.encodeIfPresent(type, forKey: .type)
        try container.encodeIfPresent(contentType, forKey: .contentType)
    }

    enum CodingKeys: String, CodingKey {
        case algorithm = "alg"
        case keyID = "kid"
        case type = "typ"
        case contentType = "cty"
    }
}

public typealias Payload = [String: Any]
