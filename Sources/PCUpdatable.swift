import Foundation

protocol PCUpdatable {
    @discardableResult
    func updateWithPropertiesOf(_: Self) -> Self
}
