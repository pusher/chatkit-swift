
enum SubscriptionType {
    case user
    case room(roomIdentifier: String)
}

extension SubscriptionType: Hashable {}
