import UIKit
final class ImagesListCell: UITableViewCell{
    // MARK: - IB Outlets
    
    @IBOutlet weak var likeButton: UIButton!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var cellImage: UIImageView!
    
    static let reuseIdentifier = "ImagesListCell"
}
