
import Foundation

enum HTTPMethod: String {
    case options = "OPTIONS"
    case get     = "GET"
    case head    = "HEAD"
    case post    = "POST"
    case put     = "PUT"
    case patch   = "PATCH"
    case delete  = "DELETE"
    case trace   = "TRACE"
    case connect = "CONNECT"
}

enum ContentType: String {
    case json = "application/json"
    case urlencoded = "application/x-www-form-urlencoded"
}

class URLRequestBuilder {
    internal let baseURL: URL
    
    init(baseURL: URL) {
        self.baseURL = baseURL
    }
    
    func get(_ requestPath: String, contentType: ContentType = .json) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.get).contentType(contentType)
    }
    
    func post(_ requestPath: String, contentType: ContentType = .json) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.post).contentType(contentType)
    }
    
    func put(_ requestPath: String) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.put)
    }
    
    func delete(_ requestPath: String) -> URLRequest {
        return URLRequest(url: baseURL).path(requestPath).method(.delete)
    }
}

extension URLRequest {
    func path(_ path: String) -> URLRequest {
        var request = self
        request.url = url?.appendingPathComponent(path)
        return request
    }
    
    func method(_ method: HTTPMethod) -> URLRequest {
        var request = self
        request.httpMethod = method.rawValue
        return request
    }
    
    func body(json body: Encodable) -> URLRequest {
        var request = self
        request.httpBody = try? body.serializeToJSON(dateEncodingStrategy: .formatted(.iso8601Full))
        return request.contentType(.json)
    }
    
    func queryItems(_ items: [String: String]) -> URLRequest {
        var request = self
        guard let url = request.url else { return request }
        
        var components = URLComponents(url: url, resolvingAgainstBaseURL: false)
        let urlQueryItems = items.map { key, value in
            return URLQueryItem(name: key, value: value)
        }
        components?.append(queryItems: urlQueryItems)
        
        guard let finalURL = components?.url else { return request }
        request.url = finalURL
        return request
    }
    func contentType(_ contentType: ContentType) -> URLRequest {
        return setValue(contentType.rawValue, forHeader: "Content-Type")
    }
    func setValue(_ value: String, forHeader header: String) -> URLRequest {
        var request = self
        request.setValue(value, forHTTPHeaderField: header)
        return request
    }
    
    func token(_ token: String) -> URLRequest {
        let bearerRequestModifier = BearerTokenRequestModifier(authenticationToken: token)
        return bearerRequestModifier.mutate(self)
    }
    
}

private extension URLComponents {
    mutating func append(queryItems: [URLQueryItem]) {
        guard !queryItems.isEmpty else {
            return
        }
        self.queryItems = (self.queryItems ?? [URLQueryItem]()) + queryItems
    }
}

struct StripeResponseObject: Decodable {
    let id: String
}

class BearerTokenRequestModifier: NetworkRequestModifier {
    
    private var authenticationToken: String
    init(authenticationToken: String) {
        self.authenticationToken = authenticationToken
    }
    
    func mutate(_ request: URLRequest) -> URLRequest {
        var mutableRequest = request
        let bearerTokenHeader = "Bearer \(authenticationToken)"
        mutableRequest.setValue(bearerTokenHeader, forHTTPHeaderField: "Authorization")
        return mutableRequest
    }
    
}
/// Represents a type that adds persistent details to a URL Request. (Ex: adding headers with authentication)
protocol NetworkRequestModifier {
    /// Add authentication details to a URL Request (for example, by adding authentication headers)
    ///
    /// - returns: The modified URL Request
    func mutate(_ request: URLRequest) -> URLRequest
}

extension NetworkRequestModifier {
    func mutate(_ requestModifiable: ConvertsToURLRequest) -> URLRequest {
        let urlRequest = requestModifiable.asURLRequest()
        return mutate(urlRequest)
    }
}

/// Types adopting the `ConvertsToURLRequest` protocol can be used to construct URL requests.
protocol ConvertsToURLRequest {
    /// - returns: A URL request.
    func asURLRequest() -> URLRequest
}

extension URLRequest: ConvertsToURLRequest {
    func asURLRequest() -> URLRequest {
        return self
    }
}

extension URL: ConvertsToURLRequest {
    func asURLRequest() -> URLRequest {
        return URLRequest(url: self)
    }
}
