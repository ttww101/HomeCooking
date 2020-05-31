import UIKit

class RepostDiscussTableViewCellS: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var senderNicknameLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }

    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)

        senderNicknameLabel.text = ""
        contentLabel.text = ""
        dateLabel.text = ""
        
    }

}
