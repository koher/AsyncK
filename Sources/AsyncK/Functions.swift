public func beginAsync(_ body: () -> Async<Void>) {
    _ = body()
}

public func suspendAsync<T>(_ body: (_ continuation: @escaping (T) -> ()) -> ()) -> Async<T> {
    return Async<T>(body)
}
