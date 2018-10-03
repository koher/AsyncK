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
