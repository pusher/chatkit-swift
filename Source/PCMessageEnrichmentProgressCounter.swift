class PCMessageEnrichmentProgressCounter {
    private var queue = DispatchQueue(label: "com.pusher.chat-api.message-enrichment-progress-counter")
    let totalCount: Int
    var successCount: Int = 0
    var failedCount: Int = 0
    var finished: Bool = false

    init(totalCount: Int) {
        self.totalCount = totalCount
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
