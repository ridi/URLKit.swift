import Foundation

public struct RequestError<Success, Failure: Error>: Error {
    let underlyingError: Failure
    let response: Response<Success, Failure>?

    public init(
        underlyingError: Failure,
        response: Response<Success, Failure>?
    ) {
        self.underlyingError = underlyingError
        self.response = response
    }
}

extension RequestError: CustomNSError {
    public var errorUserInfo: [String: Any] {
        return [
            NSUnderlyingErrorKey: underlyingError
        ]
    }
}
