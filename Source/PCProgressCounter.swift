class PCProgressCounter {
    private var queue: DispatchQueue
    let totalCount: Int
    var successCount: Int = 0
    var failedCount: Int = 0
    var finished: Bool = false

    init(totalCount: Int, labelSuffix: String? = nil) {
        self.totalCount = totalCount
        let queueLabelSuffix = labelSuffix ?? "progress-counter"
        self.queue = DispatchQueue(label: "com.pusher.chat-api.\(queueLabelSuffix)")
    }

    func incrementSuccess() {
        queue.sync {
            successCount += 1
            if totalCount == (successCount + failedCount) {
                finished = true
            }
        }
    }

    func incrementFailed() {
        queue.sync {
            failedCount += 1
            if totalCount == (successCount + failedCount) {
                finished = true
            }
        }
    }

}
