import NapiC
import Foundation

public protocol ValueConvertible {
    init(_ env: napi_env, from: napi_value) throws
    func napiValue(_ env: napi_env) throws -> napi_value
}

extension Optional: ValueConvertible where Wrapped: ValueConvertible {
    public init(_ env: napi_env, from: napi_value) throws {
        if try strictlyEquals(env, lhs: from, rhs: Null.default) {
            self = .none
            return
        }

        if try strictlyEquals(env, lhs: from, rhs: Undefined.default) {
            self = .none
            return
        }

        self = .some(try Wrapped.init(env, from: from))
    }

    public func napiValue(_ env: napi_env) throws -> napi_value {
        try self?.napiValue(env) ?? Value.null.napiValue(env)
    }
}

extension Dictionary: ValueConvertible where Key == String, Value: ValueConvertible {
    public init(_ env: napi_env, from: napi_value) throws {
        fatalError("Not implemented")
    }

    public func napiValue(_ env: napi_env) throws -> napi_value {
        var status: napi_status!
        var result: napi_value!

        status = napi_create_object(env, &result)
        guard status == napi_ok else {
            throw Napi.Error(status)
        }

        for (key, value) in self {
            status = napi_set_property(env, result, try key.napiValue(env), try value.napiValue(env))
            guard status == napi_ok else {
                throw Napi.Error(status)
            }
        }

        return result
    }
}

extension Array: ValueConvertible where Element: ValueConvertible {
    public init(_ env: napi_env, from: napi_value) throws {
        fatalError("Not implemented")
    }

    public func napiValue(_ env: napi_env) throws -> napi_value {
        var status: napi_status!
        var result: napi_value!

        status = napi_create_array_with_length(env, count, &result)
        guard status == napi_ok else {
            throw Napi.Error(status)
        }

        for (index, element) in enumerated() {
            status = napi_set_element(env, result, UInt32(index), try element.napiValue(env))
            guard status == napi_ok else {
                throw Napi.Error(status)
            }
        }

        return result
    }
}

extension String: ValueConvertible {
    public init(_ env: napi_env, from: napi_value) throws {
        var status: napi_status!
        var length: Int = 0

        status = napi_get_value_string_utf8(env, from, nil, 0, &length)
        guard status == napi_ok else {
            throw Napi.Error(status)
        }

        let pointer = UnsafeMutablePointer<CChar>.allocate(capacity: length + 1)
        status = napi_get_value_string_utf8(env, from, pointer, length + 1, &length)

        guard status == napi_ok else {
            throw Napi.Error(status)
        }

        self.init(cString: pointer)
    }

    public func napiValue(_ env: napi_env) throws -> napi_value {
        var result: napi_value?
        let bytes = cString(using: .utf8)!

        let status = napi_create_string_utf8(env, bytes, bytes.count - 1, &result)

        guard status == napi_ok else {
            throw Napi.Error(status)
        }

        return result!
    }
}

extension Double: ValueConvertible {
    public init(_ env: napi_env, from: napi_value) throws {
        self = .nan
        let status = napi_get_value_double(env, from, &self)
        guard status == napi_ok else {
            throw Napi.Error(status)
        }
    }

    public func napiValue(_ env: napi_env) throws -> napi_value {
        var result: napi_value?
        let status = napi_create_double(env, self, &result)
        guard status == napi_ok else {
            throw Napi.Error(status)
        }
        return result!
    }
}

extension Bool: ValueConvertible {
    public init(_ env: napi_env, from: napi_value) throws {
        self = false
        let status = napi_get_value_bool(env, from, &self)
        guard status == napi_ok else {
            throw Napi.Error(status)
        }
    }

    public func napiValue(_ env: napi_env) throws -> napi_value {
        var result: napi_value?
        let status = napi_get_boolean(env, self, &result)
        guard status == napi_ok else {
            throw Napi.Error(status)
        }
        return result!
    }
}
