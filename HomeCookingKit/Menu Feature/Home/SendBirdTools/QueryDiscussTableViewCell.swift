import UIKit

class QueryDiscussTableViewCell: UITableViewCell {
    
    @IBOutlet weak var cellBackgroundView: UIView!
    @IBOutlet weak var senderImageView: UIImageView!
    @IBOutlet weak var senderNicknameLabel: UILabel!
    @IBOutlet weak var accordingImageView: UIImageView!
    @IBOutlet weak var accordingTitleLabel: UILabel!
    @IBOutlet weak var accordingSubTitleLabel: UILabel!
    @IBOutlet weak var accordingSelectBtn: UIButton!
    @IBOutlet weak var subjectLabel: UILabel!
    @IBOutlet weak var contentLabel: UILabel!
    @IBOutlet weak var dateLabel: UILabel!
    @IBOutlet weak var repostBtn: UIButton!
    @IBOutlet weak var likeBtn: UIButton!

    override func awakeFromNib() {
        super.awakeFromNib()
        
        senderNicknameLabel.text = ""
        subjectLabel.text = ""
        accordingTitleLabel.text = ""
        accordingSubTitleLabel.text = ""
        contentLabel.text = ""
        dateLabel.text = ""
        repostBtn.setTitle("Message 0", for: UIControl.State.normal)
        likeBtn.setTitle("Like 0", for: UIControl.State.normal)
        
    }

}
