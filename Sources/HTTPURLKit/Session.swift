import Foundation
import Alamofire
import URLKit

open class Session: SessionProtocol {
    public static var shared: Session = .init()

    open lazy var mainQueue = DispatchQueue(
        label: "\(String(reflecting: Self.self)).main",
        qos: .default
    )

    open lazy var requestQueue = DispatchQueue(
        label: "\(String(reflecting: Self.self)).request",
        qos: .default
    )

    lazy var _alamofireSession: Alamofire.Session = {
        let alamofireSession = Alamofire.Session(rootQueue: requestQueue)

        return alamofireSession
    }()

    @discardableResult
    open func request<T: Requestable>(
        request: T,
        completion: @escaping (Response<T.ResponseBody, Error>) -> Void
    ) -> Request<T> {
        let request = Request.init(
            requestable: request,
            {
                do {
                    return .success(try _alamofireSession.request(request.asURLRequest()))
                } catch {
                    return .failure(error)
                }
            }()
        )

        mainQueue.async {
            switch request._requestResult {
            case .success(let request):
                request
                    .responseDecodable(completionHandler: { completion(.init(result: $0.result.eraseFailureToError())) })
            case .failure(let error):
                completion(.init(result: .failure(error)))
            }
        }

        return request
    }
}
