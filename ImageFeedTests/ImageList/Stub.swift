@testable import ImageFeed
import UIKit

extension Photo {
    static func stub(
        id: String = UUID().uuidString,
        isLiked: Bool = false
    ) -> Photo {
        Photo(
            id: id,
            size: CGSize(width: 100, height: 100),
            createdAt: nil,
            welcomeDescription: nil,
            thumbImageURL: "",
            largeImageURL: "",
            isLiked: isLiked
        )
    }
}
