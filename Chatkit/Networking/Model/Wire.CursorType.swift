import Foundation

extension Wire {

    internal enum CursorType: Int {
        case read = 0
    }

}

extension Wire.CursorType: Decodable {}
