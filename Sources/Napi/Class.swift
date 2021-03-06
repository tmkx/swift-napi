import NapiC

fileprivate func defineClass(_ env: napi_env, named name: String, _ constructor: @escaping Callback, _ properties: [PropertyDescriptor]) throws -> napi_value {
    var result: napi_value?
    let nameCString = name.cString(using: .utf8)!
    let props = try properties.map {
        try $0.value(env)
    }

    let data = CallbackData(callback: constructor)
    let dataPointer = Unmanaged.passRetained(data).toOpaque()

    let status = props.withUnsafeBufferPointer { propertiesBytes in
        napi_define_class(env, nameCString, nameCString.count - 1, swiftNapiCallback, dataPointer, properties.count, propertiesBytes.baseAddress, &result)
    }

    guard status == napi_ok else {
        throw Napi.Error(status)
    }

    return result!
}

fileprivate enum InternalClass {
    case swift(String, Callback, [PropertyDescriptor])
    case javascript(napi_value)
}

public class Class: ValueConvertible {
    fileprivate let value: InternalClass

    public required init(_ env: napi_env, from: napi_value) throws {
        value = .javascript(from)
    }

    public init(named name: String, _ constructor: @escaping Callback, _ properties: [PropertyDescriptor]) {
        value = .swift(name, constructor, properties)
    }

    public func napiValue(_ env: napi_env) throws -> napi_value {
        switch value {
        case .swift(let name, let constructor, let properties): return try defineClass(env, named: name, constructor, properties)
        case .javascript(let value): return value
        }
    }
}
