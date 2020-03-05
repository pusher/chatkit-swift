
enum InstanceType {
    case subscription(SubscriptionType)
    // When we implement Services I anticipate a `service` case here
    // case service(ServiceType)
}

extension InstanceType: Hashable {}
