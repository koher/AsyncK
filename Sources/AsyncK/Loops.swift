public func asyncWhile(_ condition: @autoclosure @escaping () -> Bool, _ operation: @escaping () -> Async<Void>) -> Async<Void> {
    return _asyncWhile(condition) { _ in operation() }
}

public func asyncWhile(_ condition: @autoclosure @escaping () -> Bool, _ operation: @escaping (_ break: @escaping () -> ()) -> Async<Void>) -> Async<Void> {
    return _asyncWhile(condition, operation)
}

private func _asyncWhile(_ condition: @escaping () -> Bool, _ operation: @escaping (_ break: @escaping () -> ()) -> Async<Void>) -> Async<Void> {
    var breaks = false
    func `break`() {
        breaks = true
    }
    
    guard condition() else {
        return Async<Void>(())
    }
    
    return operation(`break`).await {
        if breaks {
            return Async<Void>(())
        }
        return _asyncWhile(condition, operation)
    }
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
