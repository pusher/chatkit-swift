import Foundation
import PusherPlatform




extension Instance {
    typealias OnOpening = () -> Void
    typealias OnOpen = () -> Void
    typealias OnResuming = () -> Void
    typealias OnEvent = (String, [String : String], Any) -> Void
    typealias OnEnd = (Int?, [String : String]?, Any?) -> Void
    typealias OnError = (Error) -> Void
}



protocol Instance {
    
    
//    func makeResumableSubscription() -> PPResumableSubscription
    
    func request(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPGeneralRequest

    /*
    func requestWithRetry(using requestOptions: PPRequestOptions, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?) -> PPRetryableGeneralRequest

    func subscribe(with subscription: inout PPSubscription, using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onEvent: ((String, [String : String], Any) -> Void)?, onEnd: ((Int?, [String : String]?, Any?) -> Void)?, onError: ((Error) -> Void)?)

    func subscribeWithResume(with resumableSubscription: inout PPResumableSubscription, using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onResuming: (() -> Void)?, onEvent: ((String, [String : String], Any) -> Void)?, onEnd: ((Int?, [String : String]?, Any?) -> Void)?, onError: ((Error) -> Void)?)

    func subscribe(using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onEvent: ((String, [String : String], Any) -> Void)?, onEnd: ((Int?, [String : String]?, Any?) -> Void)?, onError: ((Error) -> Void)?) -> PPSubscription

    */
    func subscribeWithResume(using requestOptions: PPRequestOptions, onOpening: (() -> Void)?, onOpen: (() -> Void)?, onResuming: (() -> Void)?, onEvent: ((String, [String : String], Any) -> Void)?, onEnd: ((Int?, [String : String]?, Any?) -> Void)?, onError: ((Error) -> Void)?) -> PPResumableSubscription

     /*
    func download(using requestOptions: PPRequestOptions, to destination: PPDownloadFileDestination?, onSuccess: ((URL) -> Void)?, onError: ((Error) -> Void)?, progressHandler: ((Int64, Int64) -> Void)?) -> PPDownload

    func upload(using requestOptions: PPRequestOptions, multipartFormData: @escaping (PPMultipartFormData) -> Void, onSuccess: ((Data) -> Void)?, onError: ((Error) -> Void)?, progressHandler: ((Int64, Int64) -> Void)?)

    func unsubscribe(taskIdentifier: Int, completionHandler: ((Error?) -> Void)?)
 */
}

/*
protocol ResumableSubscription {
    
}

extension ResumableSubscription
*/

extension PusherPlatform.Instance: Instance {
    
    /*
    func makeResumableSubscription(requestOption: PPRequestOptions) -> PPResumableSubscription {
        return PPResumableSubscription(instance: self, requestOptions: requestOption)
    }
    

    func subscribeWithResume(with resumableSubscription: inout ResumableSubscription,
                             using requestOptions: PPRequestOptions,
                             onOpening: (() -> Void)?,
                             onOpen: (() -> Void)?,
                             onResuming: (() -> Void)?,
                             onEvent: ((String, [String : String], Any) -> Void)?,
                             onEnd: ((Int?, [String : String]?, Any?) -> Void)?,
                             onError: ((Error) -> Void)?) {
        subscribe(with: &<#T##PPSubscription#>, using: <#T##PPRequestOptions#>, onOpening: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onOpen: <#T##(() -> Void)?##(() -> Void)?##() -> Void#>, onEvent: <#T##((String, [String : String], Any) -> Void)?##((String, [String : String], Any) -> Void)?##(String, [String : String], Any) -> Void#>, onEnd: <#T##((Int?, [String : String]?, Any?) -> Void)?##((Int?, [String : String]?, Any?) -> Void)?##(Int?, [String : String]?, Any?) -> Void#>, onError: <#T##((Error) -> Void)?##((Error) -> Void)?##(Error) -> Void#>)
    }

    */
    
}
