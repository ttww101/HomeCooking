import UIKit
import Photos

class RegisterViewController: KeyboardViewController, UIImagePickerControllerDelegate, UINavigationControllerDelegate {

    var defaultDarkViewColor:UIColor = UIColor.darkGray
    var defaultLightViewColor:UIColor = UIColor.white
    var defaultHighlightedColor:UIColor = UIColor.gray
    var defaultDarkTextColor:UIColor = UIColor.darkGray
    var defaultLightTextColor:UIColor = UIColor.white
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var registerView: UIView!
    @IBOutlet weak var topBarView: UIView!
    @IBOutlet weak var topBarTitleLabel: UILabel!
    @IBOutlet weak var userImageView: UIImageView!
    @IBOutlet weak var userImageBtn: UIButton!
    @IBOutlet weak var nicknameTitleLabel: UILabel!
    @IBOutlet weak var emailTitleLabel: UILabel!
    @IBOutlet weak var passwordTitleLabel: UILabel!
    @IBOutlet weak var confirmTitleLabel: UILabel!
    @IBOutlet weak var nicknameStrokeView: UIView!
    @IBOutlet weak var nicknameTextField: UITextField!
    @IBOutlet weak var emailStrokeView: UIView!
    @IBOutlet weak var emailTextField: UITextField!
    @IBOutlet weak var passwordStrokeView: UIView!
    @IBOutlet weak var passwordTextField: UITextField!
    @IBOutlet weak var confirmStrokeView: UIView!
    @IBOutlet weak var confirmTextField: UITextField!
    @IBOutlet weak var cancelBtn: UIButton!
    @IBOutlet weak var submitBtn: UIButton!
    
    var submitClickCallback:((_ nickname:String, _ email:String, _ password:String, _ confirm:String, _ imageUrl:String) -> Void)?
    var cancelClickCallback:(() -> Void)?
    
    let imagePicker = UIImagePickerController()
    var userImageUrl:String = ""
    
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

        imagePicker.delegate = self
        nicknameTextField.delegate = self
        emailTextField.delegate = self
        passwordTextField.delegate = self
        confirmTextField.delegate = self
        
        registerView.backgroundColor = defaultLightViewColor
        topBarView.backgroundColor = defaultDarkViewColor
        topBarTitleLabel.textColor = defaultLightTextColor
        userImageView.backgroundColor = defaultDarkViewColor
        nicknameTitleLabel.textColor = defaultDarkTextColor
        emailTitleLabel.textColor = defaultDarkTextColor
        passwordTitleLabel.textColor = defaultDarkTextColor
        confirmTitleLabel.textColor = defaultDarkTextColor
        nicknameStrokeView.backgroundColor = defaultDarkViewColor
        emailStrokeView.backgroundColor = defaultDarkViewColor
        passwordStrokeView.backgroundColor = defaultDarkViewColor
        confirmStrokeView.backgroundColor = defaultDarkViewColor
        nicknameTextField.textColor = defaultDarkTextColor
        emailTextField.textColor = defaultDarkTextColor
        passwordTextField.textColor = defaultDarkTextColor
        confirmTextField.textColor = defaultDarkTextColor
        
        cancelBtn.backgroundColor = defaultDarkViewColor
        submitBtn.backgroundColor = defaultDarkViewColor
        
        cancelBtn.setTitleColor(defaultLightTextColor, for: UIControl.State.normal)
        cancelBtn.setTitleColor(defaultHighlightedColor, for: UIControl.State.highlighted)
        submitBtn.setTitleColor(defaultLightTextColor, for: UIControl.State.normal)
        submitBtn.setTitleColor(defaultHighlightedColor, for: UIControl.State.highlighted)
        
        backgroundImageView.contentMode = UIView.ContentMode.scaleAspectFill
        registerView.layer.cornerRadius = 5
        registerView.clipsToBounds = true
        userImageView.contentMode = UIView.ContentMode.scaleAspectFill
        userImageView.layer.cornerRadius = userImageView.frame.width / 2
        userImageView.clipsToBounds = true
        nicknameStrokeView.layer.cornerRadius = 3
        nicknameStrokeView.clipsToBounds = true
        nicknameTextField.layer.cornerRadius = 3
        nicknameTextField.clipsToBounds = true
        emailStrokeView.layer.cornerRadius = 3
        emailStrokeView.clipsToBounds = true
        emailTextField.layer.cornerRadius = 3
        emailTextField.clipsToBounds = true
        passwordStrokeView.layer.cornerRadius = 3
        passwordStrokeView.clipsToBounds = true
        passwordTextField.layer.cornerRadius = 3
        passwordTextField.clipsToBounds = true
        confirmStrokeView.layer.cornerRadius = 3
        confirmStrokeView.clipsToBounds = true
        confirmTextField.layer.cornerRadius = 3
        confirmTextField.clipsToBounds = true
        cancelBtn.layer.cornerRadius = 3
        cancelBtn.clipsToBounds = true
        submitBtn.layer.cornerRadius = 3
        submitBtn.clipsToBounds = true
        
        userImageBtn.addTarget(self, action: #selector(userImageBtnClick), for: UIControl.Event.touchUpInside)
        
        submitBtn.addTarget(self, action: #selector(submitBtnClick), for: UIControl.Event.touchUpInside)
        
        cancelBtn.addTarget(self, action: #selector(cancelBtnClick), for: UIControl.Event.touchUpInside)
        
    }
    
    override func viewDidAppear(_ animated: Bool) {
        requestPhotoAuth()
    }
    
    func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey : Any]) {
        
        if let pickedImage = info[UIImagePickerController.InfoKey.originalImage] as? UIImage {
            
            dismiss(animated: true) {
                
                startIndicator(callback: { (indicatorView01) in
                    uploadImageGetLink(image: pickedImage) { (imageLink) in
                        self.userImageUrl = imageLink
                        stopIndicator(indicatorView: indicatorView01, callback: {
                            if (self.userImageUrl.count > 0) {
                                startIndicator(callback: { (indicatorView02) in
                                    downloadImage(url: self.userImageUrl) { (image) in
                                        stopIndicator(indicatorView: indicatorView02, callback: {
                                            self.userImageView.image = image
                                        })
                                    }
                                })
                            }
                        })
                    }
                    
                })
                
            }
            
        }
        
    }
    
    func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
        dismiss(animated: true, completion: nil)
    }
    
    @objc func userImageBtnClick() {
        self.imagePicker.allowsEditing = false
        self.imagePicker.sourceType = .photoLibrary
        self.present(self.imagePicker, animated: true, completion: nil)
    }
    
    @objc func submitBtnClick() {
        if (submitClickCallback != nil) {
            DispatchQueue.main.async {
                self.submitClickCallback!(self.nicknameTextField.text!, self.emailTextField.text!, self.passwordTextField.text!, self.confirmTextField.text!, self.userImageUrl)
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
    
    func setSubmitCallback(clickCallback: ((_ nickname:String, _ email:String, _ password:String, _ confirm:String, _ imageUrl:String) -> Void)?) {
        self.submitClickCallback = clickCallback
    }
    
    func setCancelCallback(clickCallback: (() -> Void)?) {
        self.cancelClickCallback = clickCallback
    }
    
    func requestPhotoAuth() {
        let photoAuthorizationStatus = PHPhotoLibrary.authorizationStatus()
        if (photoAuthorizationStatus == .notDetermined) {
            PHPhotoLibrary.requestAuthorization { (authorizationStatus) in
                self.requestPhotoAuth()
            }
        } else {
            if (photoAuthorizationStatus != .authorized) {
                
                let alertController = UIAlertController(title: "同意App使用相簿",
                                                        message: "您必须同意App存取相簿才能上传个人照片，照片将于您发布文章或留言时使用", preferredStyle: .alert)
                let okAction = UIAlertAction(title: "关闭", style: .default, handler: {
                    action in
                    self.navigationController?.popViewController(animated: true)
                })
                alertController.addAction(okAction)
                self.present(alertController, animated: true, completion: nil)
                
            }
        }
    }

}
