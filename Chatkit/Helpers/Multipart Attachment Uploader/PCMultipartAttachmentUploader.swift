import Foundation
import PusherPlatform

struct PCMultipartAttachmentUploadTask {
    let uploadRequest: PCMultipartAttachmentUploadRequest
    let roomID: String
    let file: Data
    let partNumber: Int
}

struct PCMultipartAttachmentUploadResult {
    let attachmentID: String
    let partNumber: Int
    let payload: [String: Any]
}

class PCMultipartAttachmentUploader {
    fileprivate let instance: Instance
    fileprivate let uploadTasks: Array<PCMultipartAttachmentUploadTask>
    fileprivate let dispatchQueue = DispatchQueue(label: "com.pusher.chatkit.multipart-upload-\(UUID().uuidString)")
    fileprivate let dispatchGroup = DispatchGroup()
    fileprivate let uploadSuccesses = PCSynchronizedArray<PCMultipartAttachmentUploadResult>()
    fileprivate let uploadFailures = PCSynchronizedArray<Error>()

    init(
        instance: Instance,
        uploadTasks: [PCMultipartAttachmentUploadTask]
    ) {
        self.instance = instance
        self.uploadTasks = uploadTasks
    }

    func upload(completionHandler: @escaping ([PCMultipartAttachmentUploadResult]?, [Error]?) -> Void) {
        for task in self.uploadTasks {
            self.dispatchGroup.enter()
            self.dispatchQueue.async {
                self.uploadMultipartAttachment(task: task) { (attachmentID, error) in
                    defer { self.dispatchGroup.leave() }
                    guard error == nil else {
                        self.uploadFailures.append(error!)
                        self.instance.logger.log(
                            "Failed to upload multipart attachment: \(error.debugDescription)",
                            logLevel: .error
                        )
                        return
                    }

                    self.uploadSuccesses.append(
                        PCMultipartAttachmentUploadResult(
                            attachmentID: attachmentID!,
                            partNumber: task.partNumber,
                            payload: [
                                "type": task.uploadRequest.contentType,
                                "attachment": ["id": attachmentID!]
                            ]
                        )
                    )
                }
            }
        }

        self.dispatchGroup.notify(queue: .main) {
            if self.uploadFailures.count > 0 {
                completionHandler(nil, self.uploadFailures.clone())
            } else {
                completionHandler(self.uploadSuccesses.clone(), nil)
            }
        }
    }

    fileprivate func uploadMultipartAttachment(
        task: PCMultipartAttachmentUploadTask,
        completionHandler: @escaping (String?, Error?) -> Void
    ) {
        let uploadRequestMap = task.uploadRequest.toMap()
        guard JSONSerialization.isValidJSONObject(uploadRequestMap) else {
            completionHandler(nil, PCError.invalidJSONObjectAsData(uploadRequestMap))
            return
        }

        guard let data = try? JSONSerialization.data(withJSONObject: uploadRequestMap, options: []) else {
            completionHandler(nil, PCError.failedToJSONSerializeData(uploadRequestMap))
            return
        }

        let path = "/rooms/\(task.roomID)/attachments"
        let requestOptions = PPRequestOptions(method: HTTPMethod.POST.rawValue, path: path, body: data)
        self.instance.request(
            using: requestOptions,
            onSuccess: { data in
                guard let jsonObject = try? JSONSerialization.jsonObject(with: data, options: []) else {
                    let err = PCError.failedToDeserializeJSON(data)
                    self.instance.logger.log(
                        "Error getting upload url: \(err.localizedDescription)",
                        logLevel: .error
                    )
                    completionHandler(nil, err)
                    return
                }

                guard let attachmentResponse = jsonObject as? [String: Any] else {
                    let err = PCError.failedToCastJSONObjectToDictionary(jsonObject)
                    self.instance.logger.log(
                        "Error getting upload url: \(err.localizedDescription)",
                        logLevel: .error
                    )
                    completionHandler(nil, err)
                    return
                }

                let attachmentID = attachmentResponse["attachment_id"] as? String
                let uploadUrl = attachmentResponse["upload_url"] as? String

                self.dispatchGroup.enter()
                self.uploadFileToCloudStorage(
                    uploadUrl: uploadUrl!,
                    file: task.file,
                    contentType: task.uploadRequest.contentType,
                    contentLength: String(task.uploadRequest.contentLength)
                ) { error in
                    defer { self.dispatchGroup.leave() }
                    guard error == nil else {
                        self.instance.logger.log(
                            "Failed to upload attachment with ID: \(attachmentID!). Error: \(error.debugDescription)",
                            logLevel: .error
                        )
                        completionHandler(nil, error)
                        return
                    }
                }
                
                completionHandler(attachmentID, nil)
                return
            },
            onError: { error in
                completionHandler(nil, error)
                return
            }
        )
    }

    fileprivate func uploadFileToCloudStorage(
        uploadUrl: String,
        file: Data,
        contentType: String,
        contentLength: String,
        completionHandler: @escaping (Error?) -> Void
    ) {
        let requestOptions = PPRequestOptions(
            method: HTTPMethod.PUT.rawValue,
            destination: .absolute(uploadUrl),
            body: file,
            shouldFetchToken: false
        )

        requestOptions.addHeaders([
            "content-type": contentType,
            "content-length": contentLength
        ])

        self.instance.request(
            using: requestOptions,
            onSuccess: { _ in
                // dont care about response returned as long as it is successful
                completionHandler(nil)
                return
            },
            onError: { error in
                completionHandler(error)
                return
            }
        )
    }
}
