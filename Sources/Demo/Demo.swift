import Napi

func hello() -> String {
    "Hello, Node-API ~"
}

func add(a: Double, b: Double) -> Double {
    a + b
}

@_cdecl("_init")
func initHelloWorld(env: OpaquePointer, exports: OpaquePointer) -> OpaquePointer? {
    initModule(env, exports, [
        .value("name", "swift-napi"),
        .function("hello", hello),
        .function("add", add),
        .function("callback") { (fn: Function) in
            try fn.call(env, "Hello, callback")
        }
    ])
}
