import XCTest
@testable import PusherChatkit

import class PusherPlatform.PPGeneralRequest
import class PusherPlatform.PPRequestOptions
import class PusherPlatform.Instance
import class PusherPlatform.PPResumableSubscription
import struct PusherPlatform.PPSDKInfo

private func makeDummyPPInstance() -> PusherPlatform.Instance {
    return PusherPlatform.Instance(locator: "bob:fred:viv",
                                   serviceName: ServiceName.chat.rawValue,
                                   serviceVersion: ServiceVersion.version7.rawValue,
                                   sdkInfo: PPSDKInfo.current)
}

private func makeDummyPPResumableSubscription(requestOptions: PPRequestOptions) -> PusherPlatform.PPResumableSubscription {
    let dummyPPInstance = makeDummyPPInstance()
    return PPResumableSubscription(instance: dummyPPInstance, requestOptions: requestOptions)
}

public class DummyInstance: DummyBase, PusherChatkit.Instance {
    
    public func request(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPGeneralRequest {
        DummyFail(sender: self, function: #function)
        return PPGeneralRequest()
    }
    
    public func subscribeWithResume(using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onResuming: (() -> Void)?, onEvent: ((String, [String: String], Any) -> Void)?, onEnd: ((Int?, [String: String]?, Any?) -> Void)?, onError: ((Error) -> Void)?) -> PPResumableSubscription {
        DummyFail(sender: self, function: #function)
        return makeDummyPPResumableSubscription(requestOptions: requestOptions)
    }
}

public class StubInstance: StubBase, PusherChatkit.Instance {
    
    struct Expectation {
        let url: String
        let jsonData: Data
        
        func matches(_ options: PPRequestOptions) -> Bool {
            switch options.destination {
            case let .relative(relativePath):
                return url.hasSuffix(relativePath)
            case let .absolute(absoluteURL):
                return url == absoluteURL
            }
        }
    }
    
    private var expectations: [Expectation] = []
    
    public override init(file: StaticString = #file, line: UInt = #line) {
        super.init(file: file, line: line)
    }
    
    public func stub(_ urlString: String, _ jsonData: Data) {}
    
    // Preparing for registration to a subscription
    private var subscribe_completionResult: VoidResult?
    public func stubSubscribe(result: VoidResult) {
        subscribe_completionResult = result
    }
    
    // Live firing of subscription events
    public func fireSubscriptionEvent(jsonData: Data) {
        guard let onEvent = self.onEvent else {
            XCTFail("`\(#function)` was called but `\(String(describing: self)).onEvent` was NOT defined", file: file, line: line)
            return
        }
        let eventId = ""
        let headers: [String: String] = [:]
        onEvent(eventId, headers, jsonData)
    }
    
    // MARK: Instance implementation
    
    public func request(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPGeneralRequest {
        
        let generalRequest = PPGeneralRequest()
        
        guard let index = expectations.firstIndex(where: { $0.matches(requestOptions) }) else {
            XCTFail()
            return generalRequest
        }
        
        let expectation = expectations[index]
        expectations.remove(at: index)
        
        onSuccess?(expectation.jsonData)
        
        return generalRequest
    }
    
    private var onOpening: Instance.OnOpening?
    private var onOpen: Instance.OnOpen?
    private var onResuming: Instance.OnResuming?
    private var onEvent: Instance.OnEvent?
    private var onEnd: Instance.OnEnd?
    private var onError: Instance.OnError?
    
    public func subscribeWithResume(using requestOptions: PPRequestOptions,
                             onOpening: Instance.OnOpening?,
                             onOpen: Instance.OnOpen?,
                             onResuming: Instance.OnResuming?,
                             onEvent: Instance.OnEvent?,
                             onEnd: Instance.OnEnd?,
                             onError: Instance.OnError?) -> PPResumableSubscription {
        
        guard let subscribe_completionResult = subscribe_completionResult else {
            XCTFail("Unexpected call to `\(#function)` on `\(String(describing: self))`", file: file, line: line)
            return makeDummyPPResumableSubscription(requestOptions: requestOptions)
        }
        
        self.onOpening = onOpening
        self.onOpen = onOpen
        self.onResuming = onResuming
        self.onEvent = onEvent
        self.onEnd = onEnd
        self.onError = onError
        
        switch subscribe_completionResult {
            // TODO: no idea if this is correct
        case .success:
            onOpen?()
        case let .failure(error):
            // TODO: no idea if this is correct
            let statusCode = 404
            let headers: [String: String]? = nil
            let info: Any? = error
            onEnd?(statusCode, headers, info)
        }
        
        return makeDummyPPResumableSubscription(requestOptions: requestOptions)
    }
    
}
