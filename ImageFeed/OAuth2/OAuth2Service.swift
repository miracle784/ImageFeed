import Foundation

final class OAuth2Service{
    
    static let shared = OAuth2Service()
    private let tokenStorage = OAuth2TokenStorage.shared
    private let decoder = JSONDecoder()
    private init() {}
    
    func fetchOAuthToken(
        _ code: String,
        completion: @escaping (Result<String, Error>) -> Void
    ) {
        guard let request = makeOAuthTokenRequest(code: code) else {
            print("❌ [OAuth] Не удалось создать URLRequest для получения токена")
            DispatchQueue.main.async {
                completion(.failure(NetworkError.invalidRequest))
            }
            return
        }
        
        let task = URLSession.shared.data(for: request) { [weak self] result in
            guard let self = self else { return }
            switch result {
                
            case .success(let data):
                
                do {
                    let response = try self.decoder.decode(OAuthTokenResponseBody.self, from: data)
                    
                    let token = response.accessToken
                    self.tokenStorage.token = token
                    
                    completion(.success(token))
                    
                } catch {
                    print("❌ Ошибка декодирования:", error)
                    print("❌ Полученный JSON:", String(data: data, encoding: .utf8) ?? "nil")
                    completion(.failure(NetworkError.decodingError(error)))
                }
                
            case .failure(let error):
                
                print("❌ Сетевая или HTTP ошибка:", error)
                completion(.failure(error))
            }
        }
        task.resume()
    }
    
    private func makeOAuthTokenRequest(code: String) -> URLRequest? {
        guard let url = URL(string: "https://unsplash.com/oauth/token") else {
            print("❌ [OAuth] Некорректный URL для получения токена")
            return nil
        }
        
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        
        let parameters = [
            "client_id": Constants.accessKey,
            "client_secret": Constants.secretKey,
            "redirect_uri": Constants.redirectURI,
            "code": code,
            "grant_type": "authorization_code"
        ]
        
        let bodyString = parameters
            .map { "\($0.key)=\($0.value)" }
            .joined(separator: "&")
        
        request.httpBody = bodyString.data(using: .utf8)
        request.setValue("application/x-www-form-urlencoded", forHTTPHeaderField: "Content-Type")
        
        return request
    }
}
