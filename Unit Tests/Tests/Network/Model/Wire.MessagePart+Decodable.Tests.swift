import XCTest
@testable import PusherChatkit


class WireMessagePartDecodableTests: XCTestCase {
    
    func test_init_typeAndContentValid_noProblem() {
        
        let jsonData = """
        {
            "type": "text/plain",
            "content": "Hello",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.MessagePart(from: jsonData.jsonDecoder())) { messagePart in
            XCTAssertEqual(messagePart.mimeType, "text/plain")
            
            guard case let Wire.MessageType.content(content) = messagePart.type else {
                XCTFail("Expected `messagePart` value of .content but got a different value instead: \(messagePart.type)")
                return
            }
            XCTAssertEqual(content, "Hello")
        }
    }
    
    func test_init_typeAndAttachmentValid_noProblem() {
        
        let jsonData = """
        {
            "type": "application/pdf",
            "attachment": {
                "id": "793c8a94-1702-4b7b-92aa-62f3be1a8efb",
            },
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.MessagePart(from: jsonData.jsonDecoder())) { messagePart in
            XCTAssertEqual(messagePart.mimeType, "application/pdf")
            
            guard case let Wire.MessageType.attachment(attachment) = messagePart.type else {
                XCTFail("Expected `messagePart` value of .attachment but got a different value instead: \(messagePart.type)")
                return
            }
            XCTAssertEqual(attachment, "793c8a94-1702-4b7b-92aa-62f3be1a8efb")
        }
    }
    
    func test_init_typeAndUrlValid_noProblem() {
        
        let jsonData = """
        {
            "type": "image/png",
            "url": "https://example.com/figure01.png",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.MessagePart(from: jsonData.jsonDecoder())) { messagePart in
            XCTAssertEqual(messagePart.mimeType, "image/png")
            
            guard case let Wire.MessageType.url(url) = messagePart.type else {
                XCTFail("Expected `messagePart` value of .url but got a different value instead: \(messagePart.type)")
                return
            }
            XCTAssertEqual(url, URL(string: "https://example.com/figure01.png"))
        }
    }
    
    func test_init_typeAndContentValidAlternativesNull_noProblem() {
        
        let jsonData = """
        {
            "type": "text/plain",
            "content": "Hello",
            "attachment": null,
            "url": null,
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.MessagePart(from: jsonData.jsonDecoder())) { messagePart in
            XCTAssertEqual(messagePart.mimeType, "text/plain")
            
            guard case let Wire.MessageType.content(content) = messagePart.type else {
                XCTFail("Expected `messagePart` value of .content but got a different value instead: \(messagePart.type)")
                return
            }
            XCTAssertEqual(content, "Hello")
        }
    }
    
    func test_init_typeAndAttachmentValidAlternativesNull_noProblem() {
        
        let jsonData = """
        {
            "type": "application/pdf",
            "content": null,
            "attachment": {
                "id": "793c8a94-1702-4b7b-92aa-62f3be1a8efb",
            },
            "url": null,
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.MessagePart(from: jsonData.jsonDecoder())) { messagePart in
            XCTAssertEqual(messagePart.mimeType, "application/pdf")
            
            guard case let Wire.MessageType.attachment(attachment) = messagePart.type else {
                XCTFail("Expected `messagePart` value of .attachment but got a different value instead: \(messagePart.type)")
                return
            }
            XCTAssertEqual(attachment, "793c8a94-1702-4b7b-92aa-62f3be1a8efb")
        }
    }
    
    func test_init_typeAndUrlValidAlternativesNull_noProblem() {
        
        let jsonData = """
        {
            "type": "image/png",
            "content": null,
            "attachment": null,
            "url": "https://example.com/figure01.png",
        }
        """.toJsonData()
        
        XCTAssertNoThrow(try Wire.MessagePart(from: jsonData.jsonDecoder())) { messagePart in
            XCTAssertEqual(messagePart.mimeType, "image/png")
            
            guard case let Wire.MessageType.url(url) = messagePart.type else {
                XCTFail("Expected `messagePart` value of .url but got a different value instead: \(messagePart.type)")
                return
            }
            XCTAssertEqual(url, URL(string: "https://example.com/figure01.png"))
        }
    }
    
    func test_init_contentAndAttachmentPresent_throws() {
        
        let jsonData = """
        {
            "type": "text/plain",
            "content": "Hello",
            "attachment": {
                "id": "793c8a94-1702-4b7b-92aa-62f3be1a8efb",
            },
            "url": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."])
    }
    
    func test_init_contentAndUrlPresent_throws() {
        
        let jsonData = """
        {
            "type": "text/plain",
            "content": "Hello",
            "attachment": null,
            "url": "https://example.com/figure01.png",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."])
        
    }
    
    func test_init_attachmentAndUrlPresent_throws() {
        
        let jsonData = """
        {
            "type": "application/pdf",
            "content": null,
            "attachment": {
                "id": "793c8a94-1702-4b7b-92aa-62f3be1a8efb",
            },
            "url": "https://example.com/figure01.png",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."])
    }
    
    func test_init_urlAndContentAndAttachmentPresent_throws() {
        
        let jsonData = """
        {
            "type": "text/plain",
            "content": "Hello",
            "url": "https://example.com/figure01.png",
            "attachment": {
                "id": "793c8a94-1702-4b7b-92aa-62f3be1a8efb",
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."])
    }
    
    func test_init_contentUrlAndAttachmentMissing_throws() {
        
        let jsonData = """
        {
            "type": "text/plain",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."])
    }
    
    func test_init_typeMissing_throws() {
        
        let jsonData = """
        {
            "content": "Hello",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"type\""])
    }
    
    func test_init_typeNull_throws() {
        
        let jsonData = """
        {
            "type": null,
            "content": "Hello",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["valueNotFound",
                                          "\"type\"",
                                          "Expected String value but found null instead."])
    }
    
    func test_init_contentNull_throws() {
        
        let jsonData = """
        {
            "type": "text/plain",
            "content": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."])
    }
    
    func test_init_contentInvalidType_throws() {
        
        let jsonData = """
        {
            "type": "text/plain",
            "content": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"content\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_attachmentNull_throws() {
        
        let jsonData = """
        {
            "type": "application/pdf",
            "attachment": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."])
    }
    
    func test_init_attachmentInvalidType_throws() {
        
        let jsonData = """
        {
            "type": "application/pdf",
            "attachment": "not a dictionary",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"attachment\"",
                                          "Expected to decode Dictionary<String, Any> but found a string/data instead."])
    }
    
    func test_init_attachmentInvalidFormat_throws() {
        
        let jsonData = """
        {
            "type": "application/pdf",
            "attachment": {
                "not_id": "irrelevant",
            },
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["keyNotFound",
                                          "\"id\"",
                                          "No value associated with key "])
    }
    
    func test_init_urlNull_throws() {
        
        let jsonData = """
        {
            "type": "image/png",
            "url": null,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "Expected exactly one of `content`, `attachment` or `url` to be returned but got something different."])
    }
    
    func test_init_urlInvalidType_throws() {
        
        let jsonData = """
        {
            "type": "image/png",
            "url": 123,
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["typeMismatch",
                                          "\"url\"",
                                          "Expected to decode String but found a number instead."])
    }
    
    func test_init_urlInvalidFormat_throws() {
        
        let jsonData = """
        {
            "type": "image/png",
            "url": "not a url",
        }
        """.toJsonData()
        
        XCTAssertThrowsError(try Wire.MessagePart(from: jsonData.jsonDecoder()),
                             containing: ["dataCorrupted",
                                          "\"url\"",
                                          "Invalid URL string."])
    }
    
}



