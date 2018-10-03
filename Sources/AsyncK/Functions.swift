public func beginAsync(_ body: () -> Async<Void>) {
    _ = body()
}

public func suspendAsync<T>(
    _ body: (_ continuation: @escaping (T) -> ()) -> ()
) -> Async<T> {
    return Async<T>(body)
}

public func suspendAsync<T>(
    _ body: (_ continuation: @escaping (T) -> (),
             _ error: @escaping (Error) -> ()) -> ()
) -> Async<Throws<T>> {
    return Async<Throws<T>> { continuation in
        body({ value in
            continuation(Throws(value: value))
        }, { error in
            continuation(Throws(error: error))
        })
    }
}
