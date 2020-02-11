import Foundation
import PusherPlatform

extension Instance {
    typealias OnOpening = () -> Void
    typealias OnOpen = () -> Void
    typealias OnResuming = () -> Void
    typealias OnEvent = (_ eventId: String, _ headers: [String: String], _ data: Any) -> Void
    typealias OnEnd = (_ statusCode: Int?, _ headers: [String: String]?, _ info: Any?) -> Void
    typealias OnError = (_ error: Error) -> Void
}

protocol Instance {
    
    func request(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPGeneralRequest

    /*
    func requestWithRetry(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPRetryableGeneralRequest

    func subscribe(with subscription: inout PPSubscription, using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onEvent: ((String, [String : String], Any) -> Void)?, onEnd: ((Int?, [String : String]?, Any?) -> Void)?, onError: ((Error) -> Void)?)

    func subscribeWithResume(with resumableSubscription: inout PPResumableSubscription, using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onResuming: (() -> Void)?, onEvent: ((String, [String : String], Any) -> Void)?, onEnd: ((Int?, [String : String]?, Any?) -> Void)?, onError: ((Error) -> Void)?)

    func subscribe(using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onEvent: ((String, [String : String], Any) -> Void)?, onEnd: ((Int?, [String : String]?, Any?) -> Void)?, onError: ((Error) -> Void)?) -> PPSubscription

    */
    func subscribeWithResume(using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onResuming: (() -> Void)?, onEvent: ((String, [String: String], Any) -> Void)?, onEnd: ((Int?, [String: String]?, Any?) -> Void)?, onError: ((Error) -> Void)?) -> ResumableSubscription

     /*
    func download(using requestOptions: PPRequestOptions, to destination: PPDownloadFileDestination?, onSuccess: ((URL) -> Void)?, onError: ((Error) -> Void)?, progressHandler: ((Int64, Int64) -> Void)?) -> PPDownload

    func upload(using requestOptions: PPRequestOptions, multipartFormData: @escaping (PPMultipartFormData) -> Void, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?, progressHandler: ((Int64, Int64) -> Void)?)

    func unsubscribe(taskIdentifier: Int, completionHandler: ((Error?) -> Void)?)
      */
}

//extension PusherPlatform.Instance: Instance {}

protocol ResumableSubscription: AnyObject {
    var onOpen: (() -> Void)? { get set }
    var onError: ((Error) -> Void)? { get set }
    func end()
}

extension PusherPlatform.PPResumableSubscription: ResumableSubscription {}


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
                 onSuccess: ((Data) -> Void)?,
                 onError: ((Error) -> Void)?) -> PPGeneralRequest {
        return internalPPInstance.request(using: requestOptions, onSuccess: onSuccess, onError: onError)
    }
    
    func subscribeWithResume(using requestOptions: PPRequestOptions,
                             onOpening: (() -> Void)?,
                             onOpen: (() -> Void)?,
                             onResuming: (() -> Void)?,
                             onEvent: ((String, [String : String], Any) -> Void)?,
                             onEnd: ((Int?, [String : String]?, Any?) -> Void)?,
                             onError: ((Error) -> Void)?) -> ResumableSubscription {
        
        return internalPPInstance.subscribeWithResume(using: requestOptions,
                                                      onOpening: onOpening,
                                                      onOpen: onOpen,
                                                      onResuming: onResuming,
                                                      onEvent: onEvent,
                                                      onEnd: onEnd,
                                                      onError: onError)
    }
    
}

