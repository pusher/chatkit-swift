import Foundation

protocol EventParser {
    
    // MARK: - Methods
    
    func parse(event: Event) throws
    
}
