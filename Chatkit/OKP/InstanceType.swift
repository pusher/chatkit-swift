
enum InstanceType {
    case subscription(SubscriptionType)
    case service(ServiceType)
}

extension InstanceType: Hashable {}
