import UIKit

class SendDiscussViewController: KeyboardViewController {
    
    var defaultDarkViewColor:UIColor = UIColor.darkGray
    var defaultLightViewColor:UIColor = UIColor.white
    var defaultHighlightedColor:UIColor = UIColor.gray
    var defaultDarkTextColor:UIColor = UIColor.darkGray
    var defaultLightTextColor:UIColor = UIColor.white
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var sendDiscussView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topBarTitleLabel: UILabel!
    @IBOutlet weak var subjectTitleLabel: UILabel!
    @IBOutlet weak var contentTitleLabel: UILabel!
    @IBOutlet weak var subjectStrokeView: UIView!
    @IBOutlet weak var subjectTextField: UITextField!
    @IBOutlet weak var contentStrokeView: UIView!
    @IBOutlet weak var contentTextField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var sendBtn: UIButton!
    
    var sendClickCallback:((_ subject:String, _ content:String) -> Void)?
    var cancelClickCallback:(() -> Void)?
    
    override init(nibName nibNameOrNil: String?, bundle nibBundleOrNil: Bundle?) {
        super.init(nibName: nibNameOrNil, bundle: nibBundleOrNil)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    init() {
        super.init(nibName: nil, bundle: nil)
        self.modalPresentationStyle = UIModalPresentationStyle.overCurrentContext
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        subjectTextField.delegate = self
        contentTextField.delegate = self
        
        sendDiscussView.backgroundColor = defaultLightViewColor
        topBarView.backgroundColor = defaultDarkViewColor
        topBarTitleLabel.textColor = defaultLightTextColor
        subjectTitleLabel.textColor = defaultDarkTextColor
        contentTitleLabel.textColor = defaultDarkTextColor
        subjectStrokeView.backgroundColor = defaultDarkViewColor
        contentStrokeView.backgroundColor = defaultDarkViewColor
        subjectTextField.textColor = defaultDarkTextColor
        contentTextField.textColor = defaultDarkTextColor
        cancelBtn.backgroundColor = defaultDarkViewColor
        sendBtn.backgroundColor = defaultDarkViewColor
        cancelBtn.setTitleColor(defaultLightTextColor, for: UIControl.State.normal)
        cancelBtn.setTitleColor(defaultHighlightedColor, for: UIControl.State.highlighted)
        sendBtn.setTitleColor(defaultLightTextColor, for: UIControl.State.normal)
        sendBtn.setTitleColor(defaultHighlightedColor, for: UIControl.State.highlighted)

        backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
        sendDiscussView.layer.cornerRadius = 5
        sendDiscussView.clipsToBounds = true
        subjectStrokeView.layer.cornerRadius = 3
        subjectStrokeView.clipsToBounds = true
        subjectTextField.layer.cornerRadius = 3
        subjectTextField.clipsToBounds = true
        contentStrokeView.layer.cornerRadius = 3
        contentStrokeView.clipsToBounds = true
        contentTextField.layer.cornerRadius = 3
        contentTextField.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 3
        cancelBtn.clipsToBounds = true
        sendBtn.layer.cornerRadius = 3
        sendBtn.clipsToBounds = true
        
        sendBtn.addTarget(self, action: #selector(sendBtnClick), for: UIControl.Event.touchUpInside)
        
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: UIControl.Event.touchUpInside)
        
        
    }
    
    @objc func sendBtnClick() {
        if (sendClickCallback != nil) {
            sendClickCallback!(subjectTextField.text!, contentTextField.text!)
        }
    }
    
    @objc func cancelBtnClick() {
        if (cancelClickCallback != nil) {
            cancelClickCallback!()
        }
    }
    
    func setSendCallback(clickCallback: ((_ subject:String, _ content:String) -> Void)?) {
        self.sendClickCallback = clickCallback
    }
    
    func setCancelCallback(clickCallback: (() -> Void)?) {
        self.cancelClickCallback = clickCallback
    }

}
