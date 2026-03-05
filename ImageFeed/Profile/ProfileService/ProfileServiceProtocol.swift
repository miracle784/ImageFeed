
import Foundation

protocol ProfileServiceProtocol {
    func fetchProfile(
        _ token: String,
        completion: @escaping (Result<Profile, Error>) -> Void
    )
}
