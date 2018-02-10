import Foundation

public class Async<Value> {
    private var value: Value?
    private var handlers: [(Value) -> ()] = []
    private let lock = NSRecursiveLock()
    
    public init(_ value: Value) {
        self.value = value
    }
    
    internal init(_ body: (_ continuation: @escaping (Value) -> ()) -> ()) {
        body { value in
            synchronized(with: self.lock) {
                precondition(self.value == nil, "`continuation` cannot be called multiple times.")
                self.value = value
                self.handlers.forEach { $0(value) }
                self.handlers.removeAll(keepingCapacity: false)
            }
        }
    }
    
    private func get(_ handler: @escaping (Value) -> ()) {
        synchronized(with: lock) {
            if let value = self.value {
                handler(value)
            } else {
                handlers.append(handler)
            }
        }
    }
    
    public func await<T>(_ operation: @escaping (Value) -> T) -> Async<T> {
        return Async<T> { continuation in get { continuation(operation($0)) } }
    }
    
    public func await<T>(_ operation: @escaping (Value) -> Async<T>) -> Async<T> {
        return Async<T> { continuation in get { operation($0).get { continuation($0) } } }
    }
}

public func beginAsync(_ body: () -> Async<Void>) {
    _ = body()
}

public func suspendAsync<T>(_ body: (_ continuation: @escaping (T) -> ()) -> ()) -> Async<T> {
    return Async<T>(body)
}

public func asyncFor<S: Sequence>(_ sequence: S, _ operation: @escaping (S.Element) -> Async<Void>) -> Async<Void> {
    return asyncFor(sequence) { element, _ in operation(element) }
}

public func asyncFor<S: Sequence>(_ sequence: S, _ operation: @escaping (S.Element, _ break: @escaping () -> ()) -> Async<Void>) -> Async<Void> {
    var result = Async<Void>(())
    
    var breaks = false
    func `break`() {
        breaks = true
    }
    
    for element in sequence {
        result = result.await { _ in
            if breaks {
                return Async<Void>(())
            }
            return operation(element, `break`)
        }
    }
    
    return result
}

private func synchronized(with lock: NSRecursiveLock, _ operation: () -> ()) {
    lock.lock()
    defer { lock.unlock() }
    operation()
}
