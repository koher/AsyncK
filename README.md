# AsyncK

_AsyncK_ provides `Async`, `await`, `beginAsync` and `suspendAsync` which are compatible with ones in [this proposal](https://gist.github.com/lattner/429b9070918248274f25b714dcfc7619).

The following code written with `async/await`

```swift
func foo() async -> Int {
    return suspendAsync { continuation in
        // ...
    }
}

func bar(_ x: Int) async -> Int {
    // ...
}

beginAsync {
    let a = await foo()
    let b = await bar(a)
    print(b)
}
```

can be rewritten as follows:

```swift
func foo() -> Async<Int> {
    return suspendAsync { continuation in
        // ...
    }
}

func bar(_ x: Int) -> Async<Int> {
    // ...
}

beginAsync {
    foo().await { a in
        bar(a)
    }.await { b -> Void in
        print(b)
    }
}
```

## License

MIT
