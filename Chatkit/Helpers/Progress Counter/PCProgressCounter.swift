import Foundation

final class PCProgressCounter {
    private var queue: DispatchQueue
    let totalCount: Int
    var successCount: Int = 0
    var failedCount: Int = 0
    var finished = false

    init(totalCount: Int, labelSuffix: String? = nil) {
        self.totalCount = totalCount
        let queueLabelSuffix = labelSuffix ?? "progress-counter"
        self.queue = DispatchQueue(label: "com.pusher.chatkit.\(queueLabelSuffix)")
    }

    func incrementSuccessAndCheckIfFinished() -> Bool {
        var isFinished = false
        queue.sync {
            successCount += 1
            if totalCount == (successCount + failedCount) {
                finished = true
                isFinished = true
            }
        }
        return isFinished
    }

    func incrementFailedAndCheckIfFinished() -> Bool {
        var isFinished = false
        queue.sync {
            failedCount += 1
            if totalCount == (successCount + failedCount) {
                finished = true
                isFinished = true
            }
        }
        return isFinished
    }
}
