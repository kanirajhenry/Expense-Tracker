# Networking Reference

Read ONLY the sections matching the developer's networking and concurrency choices.

---

## URLSession (Custom Wrapper — No Third-Party)

A generic, SOLID-compliant API client built on URLSession.

### Shared Infrastructure

```swift
// HTTPMethod.swift
enum HTTPMethod: String {
    case get = "GET"
    case post = "POST"
    case put = "PUT"
    case patch = "PATCH"
    case delete = "DELETE"
}

// APIEndpoint.swift
protocol APIEndpoint {
    var path: String { get }
    var method: HTTPMethod { get }
    var headers: [String: String]? { get }
    var queryParameters: [String: String]? { get }
    var body: Encodable? { get }
}

extension APIEndpoint {
    var headers: [String: String]? { nil }
    var queryParameters: [String: String]? { nil }
    var body: Encodable? { nil }
}

// APIError.swift
enum APIError: LocalizedError {
    case networkError(String)
    case invalidURL
    case decodingError(String)
    case serverError(statusCode: Int, message: String)
    case notFound
    case unauthorized
    case timeout
    case noData
    case unknown(Error)

    var errorDescription: String? {
        switch self {
        case .networkError(let msg): return "Network error: \(msg)"
        case .invalidURL: return "Invalid URL"
        case .decodingError(let msg): return "Data error: \(msg)"
        case .serverError(let code, let msg): return "Server error \(code): \(msg)"
        case .notFound: return "Resource not found"
        case .unauthorized: return "Unauthorized"
        case .timeout: return "Request timed out"
        case .noData: return "No data received"
        case .unknown(let error): return error.localizedDescription
        }
    }
}

// APIConfiguration.swift
struct APIConfiguration {
    let baseURL: URL
    let timeout: TimeInterval
    let maxRetries: Int
    let environment: Environment

    enum Environment: String {
        case development, staging, production
    }

    static var development: APIConfiguration {
        APIConfiguration(
            baseURL: URL(string: "https://dev-api.example.com/v1")!,
            timeout: 30,
            maxRetries: 3,
            environment: .development
        )
    }

    static var production: APIConfiguration {
        APIConfiguration(
            baseURL: URL(string: "https://api.example.com/v1")!,
            timeout: 15,
            maxRetries: 2,
            environment: .production
        )
    }
}
```

### API Client with async/await

```swift
protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: URLSession
    private let decoder: JSONDecoder
    private let encoder: JSONEncoder
    private let configuration: APIConfiguration

    init(configuration: APIConfiguration = .development) {
        let config = URLSessionConfiguration.default
        config.timeoutIntervalForRequest = configuration.timeout
        config.waitsForConnectivity = true
        self.session = URLSession(configuration: config)
        self.configuration = configuration
        self.decoder = JSONDecoder()
        self.decoder.keyDecodingStrategy = .convertFromSnakeCase
        self.decoder.dateDecodingStrategy = .iso8601
        self.encoder = JSONEncoder()
        self.encoder.keyEncodingStrategy = .convertToSnakeCase
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let urlRequest = try buildRequest(from: endpoint)
        return try await executeWithRetry(urlRequest, retries: configuration.maxRetries)
    }

    // MARK: - Private

    private func buildRequest(from endpoint: APIEndpoint) throws -> URLRequest {
        var components = URLComponents(
            url: configuration.baseURL.appendingPathComponent(endpoint.path),
            resolvingAgainstBaseURL: true
        )
        if let params = endpoint.queryParameters {
            components?.queryItems = params.map { URLQueryItem(name: $0.key, value: $0.value) }
        }
        guard let url = components?.url else { throw APIError.invalidURL }

        var request = URLRequest(url: url)
        request.httpMethod = endpoint.method.rawValue
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        endpoint.headers?.forEach { request.setValue($0.value, forHTTPHeaderField: $0.key) }

        if let body = endpoint.body {
            request.httpBody = try encoder.encode(AnyEncodable(body))
        }
        return request
    }

    private func executeWithRetry<T: Decodable>(_ request: URLRequest, retries: Int) async throws -> T {
        var lastError: Error?
        for attempt in 0...retries {
            if attempt > 0 {
                let delay = UInt64(pow(2.0, Double(attempt - 1))) * 1_000_000_000
                try await Task.sleep(nanoseconds: delay)
            }
            do {
                let (data, response) = try await session.data(for: request)
                return try handleResponse(data: data, response: response)
            } catch {
                lastError = error
                if let apiError = error as? APIError,
                   case .serverError(let code, _) = apiError, code < 500 {
                    throw error  // Don't retry 4xx errors
                }
            }
        }
        throw lastError ?? APIError.unknown(NSError(domain: "", code: -1))
    }

    private func handleResponse<T: Decodable>(data: Data, response: URLResponse) throws -> T {
        guard let http = response as? HTTPURLResponse else {
            throw APIError.networkError("Invalid response")
        }
        switch http.statusCode {
        case 200...299:
            do { return try decoder.decode(T.self, from: data) }
            catch { throw APIError.decodingError(error.localizedDescription) }
        case 401: throw APIError.unauthorized
        case 404: throw APIError.notFound
        case 408: throw APIError.timeout
        case 500...599:
            throw APIError.serverError(statusCode: http.statusCode,
                                       message: String(data: data, encoding: .utf8) ?? "Unknown")
        default: throw APIError.networkError("HTTP \(http.statusCode)")
        }
    }
}

// Helper for encoding any Encodable
private struct AnyEncodable: Encodable {
    private let _encode: (Encoder) throws -> Void
    init(_ value: Encodable) {
        _encode = { try value.encode(to: $0) }
    }
    func encode(to encoder: Encoder) throws { try _encode(encoder) }
}
```

### Module-Specific Endpoints

```swift
enum ProductAPIEndpoint: APIEndpoint {
    case list(page: Int, limit: Int)
    case getById(id: UUID)
    case search(query: String)
    case create(ProductDTO)
    case delete(id: UUID)

    var path: String {
        switch self {
        case .list: return "/products"
        case .getById(let id): return "/products/\(id)"
        case .search: return "/products/search"
        case .create: return "/products"
        case .delete(let id): return "/products/\(id)"
        }
    }

    var method: HTTPMethod {
        switch self {
        case .list, .getById, .search: return .get
        case .create: return .post
        case .delete: return .delete
        }
    }

    var queryParameters: [String: String]? {
        switch self {
        case .list(let page, let limit):
            return ["page": "\(page)", "limit": "\(limit)"]
        case .search(let query):
            return ["q": query]
        default: return nil
        }
    }

    var body: Encodable? {
        switch self {
        case .create(let dto): return dto
        default: return nil
        }
    }
}
```

---

## Alamofire

Third-party networking library with built-in features for authentication, retry, and validation.

### Setup (SPM)

```swift
// Package.swift dependency
.package(url: "https://github.com/Alamofire/Alamofire.git", from: "5.9.0")
```

### API Client with Alamofire

```swift
import Alamofire
import Foundation

protocol APIClientProtocol {
    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T
}

final class APIClient: APIClientProtocol {
    private let session: Session
    private let baseURL: URL

    init(baseURL: URL = URL(string: "https://api.example.com/v1")!) {
        self.baseURL = baseURL
        let configuration = URLSessionConfiguration.default
        configuration.timeoutIntervalForRequest = 30
        let interceptor = RetryPolicy(retryLimit: 3, exponentialBackoffBase: 2)
        self.session = Session(configuration: configuration, interceptor: interceptor)
    }

    func request<T: Decodable>(_ endpoint: APIEndpoint) async throws -> T {
        let url = baseURL.appendingPathComponent(endpoint.path)

        let response = await session.request(
            url,
            method: HTTPMethod(rawValue: endpoint.method.rawValue)!,
            parameters: endpoint.queryParameters,
            encoder: URLEncodedFormParameterEncoder.default,
            headers: HTTPHeaders(endpoint.headers ?? [:])
        )
        .validate()
        .serializingDecodable(T.self)
        .response

        switch response.result {
        case .success(let value): return value
        case .failure(let error): throw mapError(error, response: response.response)
        }
    }

    private func mapError(_ error: AFError, response: HTTPURLResponse?) -> APIError {
        switch error {
        case .responseValidationFailed(let reason):
            if case .unacceptableStatusCode(let code) = reason {
                return .serverError(statusCode: code, message: error.localizedDescription)
            }
            return .networkError(error.localizedDescription)
        case .responseSerializationFailed:
            return .decodingError(error.localizedDescription)
        default:
            return .unknown(error)
        }
    }
}
```

---

## Moya (Alamofire-Based)

Abstraction layer on top of Alamofire with typed endpoints.

### Setup

```swift
.package(url: "https://github.com/Moya/Moya.git", from: "15.0.0")
```

### Usage

```swift
import Moya

enum ProductAPI {
    case list(page: Int)
    case detail(id: UUID)
    case search(query: String)
}

extension ProductAPI: TargetType {
    var baseURL: URL { URL(string: "https://api.example.com/v1")! }
    var path: String {
        switch self {
        case .list: return "/products"
        case .detail(let id): return "/products/\(id)"
        case .search: return "/products/search"
        }
    }
    var method: Moya.Method {
        switch self {
        case .list, .detail, .search: return .get
        }
    }
    var task: Moya.Task {
        switch self {
        case .list(let page): return .requestParameters(parameters: ["page": page], encoding: URLEncoding.default)
        case .search(let q): return .requestParameters(parameters: ["q": q], encoding: URLEncoding.default)
        default: return .requestPlain
        }
    }
    var headers: [String: String]? { ["Content-Type": "application/json"] }
}
```

---

## DTO and Mapper Patterns (All Networking Choices)

Regardless of which networking library is used, always separate API models (DTOs) from domain models.

### DTO

```swift
struct [Name]DTO: Codable {
    let id: String
    let name: String
    // Properties match API JSON structure
}

struct [Name]APIResponse: Codable {
    let data: [[Name]DTO]
    let page: Int
    let totalPages: Int
}
```

### Mapper

```swift
enum [Name]DTOMapper {
    static func toDomain(_ dto: [Name]DTO) -> [Name]? {
        guard let id = UUID(uuidString: dto.id) else { return nil }
        return [Name](id: id, name: dto.name)
    }

    static func toDomainList(_ dtos: [[Name]DTO]) -> [[Name]] {
        dtos.compactMap(toDomain)
    }

    static func toDTO(_ entity: [Name]) -> [Name]DTO {
        [Name]DTO(id: entity.id.uuidString, name: entity.name)
    }
}
```

---

## Concurrency: async/await

Modern, recommended approach. All examples above use async/await.

### Key Patterns

```swift
// Sequential calls
let user = try await authService.currentUser()
let products = try await productRepo.fetchAll()

// Parallel calls
async let user = authService.currentUser()
async let products = productRepo.fetchAll()
let (fetchedUser, fetchedProducts) = try await (user, products)

// Task group for dynamic parallelism
let results = try await withThrowingTaskGroup(of: Product.self) { group in
    for id in productIds {
        group.addTask { try await repo.fetchById(id) }
    }
    var products: [Product] = []
    for try await product in group {
        products.append(product)
    }
    return products
}
```

---

## Concurrency: Combine

Reactive approach. Use when the project heavily relies on Combine streams.

```swift
func fetchProducts() -> AnyPublisher<[Product], APIError> {
    URLSession.shared.dataTaskPublisher(for: request)
        .map(\.data)
        .decode(type: [ProductDTO].self, decoder: JSONDecoder())
        .map { $0.compactMap(ProductDTOMapper.toDomain) }
        .mapError { APIError.unknown($0) }
        .receive(on: DispatchQueue.main)
        .eraseToAnyPublisher()
}
```

---

## Concurrency: GCD

Traditional approach. Avoid for new projects — use async/await instead.

```swift
func fetchProducts(completion: @escaping (Result<[Product], APIError>) -> Void) {
    DispatchQueue.global(qos: .userInitiated).async {
        // ... perform work
        DispatchQueue.main.async {
            completion(.success(products))
        }
    }
}
```
