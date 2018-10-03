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

extension Async {
    public func tryAwait<T, V>(_ operation: @escaping (V) throws -> T) -> Async<Throws<T>> where Value == Throws<V> {
        return Async<Throws<T>> { continuation in
            get { throwsValue in
                let newThrowsValue: Throws<T>
                do {
                    let newValue = try operation(try throwsValue.get())
                    newThrowsValue = Throws(value: newValue)
                } catch let error {
                    newThrowsValue = Throws(error: error)
                }
                continuation(newThrowsValue)
            }
        }
    }
    
    public func tryAwait<T, V>(_ operation: @escaping (V) throws -> Async<T>) -> Async<Throws<T>> where Value == Throws<V> {
        return Async<Throws<T>> { continuation in
            get { throwsValue in
                do {
                    let value = try throwsValue.get()
                    
                    try operation(value).get { newValue in
                        let newThrowsValue = Throws<T>(value: newValue)
                        continuation(newThrowsValue)
                    }
                } catch let error {
                    let newThrowsValue = Throws<T>(error: error)
                    continuation(newThrowsValue)
                }
            }
        }
    }
    
    public func tryAwait<T, V>(_ operation: @escaping (V) throws -> Async<Throws<T>>) -> Async<Throws<T>> where Value == Throws<V> {
        return Async<Throws<T>> { continuation in
            get { throwsValue in
                do {
                    let value = try throwsValue.get()
                    
                    try operation(value).get { newThrowsValue in
                        continuation(newThrowsValue)
                    }
                } catch let error {
                    let newThrowsValue = Throws<T>(error: error)
                    continuation(newThrowsValue)
                }
            }
        }
    }
}

fileprivate enum Result<Value> {
    case success(Value)
    case failure(Error)
}
