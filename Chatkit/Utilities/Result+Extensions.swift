

extension Result where Success == Void {
    
    // Allows us to write `.success` rather than the more verbose `.success(())`
    static var success: Self {
        return Result.success(())
    }
    
}
