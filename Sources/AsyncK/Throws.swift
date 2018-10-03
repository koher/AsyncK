public struct Throws<Value> {
    private var result: Result<Value>
    
    public init(value: Value) {
        result = .success(value)
    }
    
    public init(error: Error) {
        result = .failure(error)
    }
    
    public func get() throws -> Value {
        switch result {
        case .success(let value):
            return value
        case .failure(let error):
            throw error
        }
    }
}

extension Throws {
    public init(_ operation: @autoclosure () throws -> Value) {
        do {
            let value: Value = try operation()
            self.init(value: value)
        } catch let error {
            self.init(error: error)
        }
    }
}

fileprivate enum Result<Value> {
    case success(Value)
    case failure(Error)
}
