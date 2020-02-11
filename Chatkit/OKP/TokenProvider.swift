import Foundation
import protocol PusherPlatform.TokenProvider

protocol HasTokenProvider {
    var tokenProvider: TokenProvider { get }
}
