import Foundation
enum NetworkError: Error {
    case httpStatusCode(Int)
    case urlRequestError(Error)
    case urlSessionError
    case invalidRequest
    case decodingError(Error)
}

extension URLSession {
    func data(
        for request: URLRequest,
        completion: @escaping (Result<Data, Error>) -> Void
    ) -> URLSessionTask {
        let fulfillCompletionOnTheMainThread: (Result<Data, Error>) -> Void = { result in  // 2
            DispatchQueue.main.async {
                completion(result)
            }
        }
        
        let task = dataTask(with: request, completionHandler: { data, response, error in
            if let data = data, let response = response, let statusCode = (response as? HTTPURLResponse)?.statusCode {
                if 200 ..< 300 ~= statusCode {
                    fulfillCompletionOnTheMainThread(.success(data)) // 3
                } else {
                    print("[URLSession.data]: httpStatusCode=\(statusCode)")
                   
                    fulfillCompletionOnTheMainThread(.failure(NetworkError.httpStatusCode(statusCode))) // 4
                }
            } else if let error = error {
                print("[URLSession.data]: urlRequestError=\(error.localizedDescription)")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlRequestError(error))) // 5
            } else {
                print("[URLSession.data]: urlSessionError noDataNoResponse")
                fulfillCompletionOnTheMainThread(.failure(NetworkError.urlSessionError)) // 6
            }
        })
        
        return task
    }
}

extension URLSession {
    func objectTask<T: Decodable>(
        for request: URLRequest,
        completion: @escaping (Result<T, Error>) -> Void
    ) -> URLSessionTask {
        let decoder = JSONDecoder()
        decoder.keyDecodingStrategy = .convertFromSnakeCase // Явно устанавливаем стратегию

        let task = data(for: request) { (result: Result<Data, Error>) in
            switch result {
            case .success(let data):
                if let jsonString = String(data: data, encoding: .utf8) {
                    print("[URLSession.objectTask]: receivedData=\(jsonString)")
                }
                do {
                    let decodedObject = try decoder.decode(T.self, from: data)
                    completion(.success(decodedObject))
                } catch {
                    print("[URLSession.objectTask]: decodingError=\(error)")
                    if let decodingError = error as? DecodingError {
                        
                        print("[URLSession.objectTask]: decodingErrorDetails=\(decodingError) data=\(String(data: data, encoding: .utf8) ?? "nil")")

                    } else {
                        print("[URLSession.objectTask]: decodingErrorDetails=\(error.localizedDescription) data=\(String(data: data, encoding: .utf8) ?? "nil")")

                    }
                    completion(.failure(error))
                }

            case .failure(let error):
                print("[URLSession.objectTask]: requestFailure=\(error)")
                completion(.failure(error))
            }
        }

        return task
    }
}

