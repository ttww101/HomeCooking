import UIKit

class LoginViewController: KeyboardViewController {
    
    var defaultDarkViewColor:UIColor = UIColor.darkGray
    var defaultLightViewColor:UIColor = UIColor.white
    var defaultHighlightedColor:UIColor = UIColor.gray
    var defaultDarkTextColor:UIColor = UIColor.darkGray
    var defaultLightTextColor:UIColor = UIColor.white
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var loginView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topBarTitleLabel: UILabel!
    @IBOutlet weak var accountTitleLabel: UILabel!
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet weak var accountStrokeView: UIView!
    @IBOutlet weak var accountTextField: UITextField!
    @IBOutlet weak var passwordStrokeView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var confirmBtn: UIButton!
    
    var confirmClickCallback:((_ account:String, _ password:String) -> Void)?
    var cancelClickCallback:(() -> Void)?
    var registerClickCallback:(() -> Void)?
    
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
        
        accountTextField.delegate = self
        passwordTextField.delegate = self
        
        loginView.backgroundColor = defaultLightViewColor
        topBarView.backgroundColor = defaultDarkViewColor
        topBarTitleLabel.textColor = defaultLightTextColor
        accountTitleLabel.textColor = defaultDarkTextColor
        passwordTitleLabel.textColor = defaultDarkTextColor
        accountStrokeView.backgroundColor = defaultDarkViewColor
        passwordStrokeView.backgroundColor = defaultDarkViewColor
        accountTextField.textColor = defaultDarkTextColor
        passwordTextField.textColor = defaultDarkTextColor
        cancelBtn.backgroundColor = defaultDarkViewColor
        confirmBtn.backgroundColor = defaultDarkViewColor
        cancelBtn.setTitleColor(defaultLightTextColor, for: UIControl.State.normal)
        cancelBtn.setTitleColor(defaultHighlightedColor, for: UIControl.State.highlighted)
        confirmBtn.setTitleColor(defaultLightTextColor, for: UIControl.State.normal)
        confirmBtn.setTitleColor(defaultHighlightedColor, for: UIControl.State.highlighted)

        backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
        loginView.layer.cornerRadius = 5
        loginView.clipsToBounds = true
        accountStrokeView.layer.cornerRadius = 3
        accountStrokeView.clipsToBounds = true
        accountTextField.layer.cornerRadius = 3
        accountTextField.clipsToBounds = true
        passwordStrokeView.layer.cornerRadius = 3
        passwordStrokeView.clipsToBounds = true
        passwordTextField.layer.cornerRadius = 3
        passwordTextField.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 3
        cancelBtn.clipsToBounds = true
        confirmBtn.layer.cornerRadius = 3
        confirmBtn.clipsToBounds = true
        
        confirmBtn.addTarget(self, action: #selector(confirmBtnClick), for: UIControl.Event.touchUpInside)
        
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: UIControl.Event.touchUpInside)
        
    }
    
    @objc func confirmBtnClick() {
        if (confirmClickCallback != nil) {
            DispatchQueue.main.async {
                self.confirmClickCallback!(self.accountTextField.text!, self.passwordTextField.text!)
            }
        }
    }
    
    @objc func cancelBtnClick() {
        if (cancelClickCallback != nil) {
            DispatchQueue.main.async {
                self.cancelClickCallback!()
            }
        }
    }
    
    func setConfirmCallback(clickCallback: ((_ account:String, _ password:String) -> Void)?) {
        self.confirmClickCallback = clickCallback
    }
    
    func setCancelCallback(clickCallback: (() -> Void)?) {
        self.cancelClickCallback = clickCallback
    }

}
