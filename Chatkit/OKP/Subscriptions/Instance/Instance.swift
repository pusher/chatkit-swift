import Foundation
import class PusherPlatform.Instance
import class PusherPlatform.PPGeneralRequest
import class PusherPlatform.PPRequestOptions

// Its nots possible to stub a PusherPlatform.Instance because it has no protocol so this
// protocol exists to resolve that problem.
protocol Instance {
    
    typealias OnOpening = () -> Void
    typealias OnOpen = () -> Void
    typealias OnResuming = () -> Void
    typealias OnEvent = (_ eventId: String, _ headers: [String: String], _ data: Any) -> Void
    typealias OnEnd = (_ statusCode: Int?, _ headers: [String: String]?, _ info: Any?) -> Void
    typealias OnSuccess = (_ data: Data) -> Void
    typealias OnError = (_ error: Error) -> Void
    
    func request(using requestOptions: PPRequestOptions,
                 onSuccess: OnSuccess?,
                 onError: OnError?) -> PPGeneralRequest

    func subscribeWithResume(using requestOptions: PPRequestOptions,
                             onOpening: OnOpening?,
                             onOpen: OnOpen?,
                             onResuming: OnResuming?,
                             onEvent: OnEvent?,
                             onEnd: OnEnd?,
                             onError: OnError?) -> ResumableSubscription
}

// This class simply proxies an internal PusherPlatform.Instance.
class ConcreteInstance: Instance {
    
    typealias Dependencies = HasInstanceLocator & HasSDKInfoProvider & HasTokenProvider
    
    let internalPPInstance: PusherPlatform.Instance
    
    init(dependencies: Dependencies) {
        internalPPInstance = PusherPlatform.Instance(
            instanceLocator: dependencies.instanceLocator,
            serviceName: dependencies.sdkInfoProvider.serviceName,
            serviceVersion: dependencies.sdkInfoProvider.serviceVersion,
            sdkInfo: dependencies.sdkInfoProvider.sdkInfo,
            tokenProvider: dependencies.tokenProvider
        )
    }
    
    func request(using requestOptions: PPRequestOptions,
                 onSuccess: OnSuccess?,
                 onError: OnError?) -> PPGeneralRequest {
        return internalPPInstance.request(using: requestOptions, onSuccess: onSuccess, onError: onError)
    }
    
    func subscribeWithResume(using requestOptions: PPRequestOptions,
                             onOpening: OnOpening?,
                             onOpen: OnOpen?,
                             onResuming: OnResuming?,
                             onEvent: OnEvent?,
                             onEnd: OnEnd?,
                             onError: OnError?) -> ResumableSubscription {
        
        return internalPPInstance.subscribeWithResume(using: requestOptions,
                                                      onOpening: onOpening,
                                                      onOpen: onOpen,
                                                      onResuming: onResuming,
                                                      onEvent: onEvent,
                                                      onEnd: onEnd,
                                                      onError: onError)
    }
    
}

