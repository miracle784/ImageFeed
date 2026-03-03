import UIKit

final class ImagesListCell: UITableViewCell {
    
    // MARK: - IB Outlets
    
    @IBOutlet private weak var likeButton: UIButton!
    @IBOutlet private weak var dateLabel: UILabel!
    @IBOutlet private weak var cellImage: UIImageView!
    
    static let reuseIdentifier = "ImagesListCell"
    
    weak var delegate: ImagesListCellDelegate?
    
    
    // MARK: - Actions
    
    @IBAction func likeButtonClicked() {
        delegate?.imageListCellDidTapLike(self)
    }
    
    // MARK: - Configuration
    private enum Assets {
        static let liked = UIImage(resource: .likeActive)
        static let notLiked = UIImage(resource: .likeInactive)
    }
    
    func setIsLiked(_ isLiked: Bool) {
        likeButton.setImage(isLiked ? Assets.liked : Assets.notLiked, for: .normal)
    }
    
    // MARK: - Reuse
    
    override func prepareForReuse() {
        super.prepareForReuse()
        
        cellImage.kf.cancelDownloadTask()
        cellImage.image = nil
    }
    override func awakeFromNib() {
        super.awakeFromNib()
        cellImage.contentMode = .scaleAspectFill
        cellImage.clipsToBounds = true
    }
}
