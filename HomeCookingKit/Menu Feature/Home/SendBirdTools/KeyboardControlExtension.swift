import Foundation
import UIKit

var kvcIsKeyboardShow:Bool = false
var kvcKeyboardHeight:CGFloat = 0.0
var kvcMainViewFrame:CGRect!
var kvcTargetView:UIView!

class KeyboardViewController:UIViewController, UITextFieldDelegate {
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        kvcMainViewFrame = self.view.frame
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillShow), name: UIResponder.keyboardWillShowNotification, object: nil)
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillHide), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        NotificationCenter.default.removeObserver(self)
    }
    
    func textFieldShouldBeginEditing(_ textField: UITextField) -> Bool {
        kvcTargetView = textField
        if (kvcIsKeyboardShow) {
            let mainDisplacement = self.view.frame.origin.y
            let bottomInputViewFrame = kvcGetViewOfAbsoluteFame(sourceView: kvcTargetView)
            let bottomSpace = kvcMainViewFrame.height - mainDisplacement - bottomInputViewFrame.origin.y  - bottomInputViewFrame.height
            if (kvcKeyboardHeight > bottomSpace) {
                self.view.frame.origin.y = bottomSpace - kvcKeyboardHeight
            } else {
                self.view.frame = kvcMainViewFrame
            }
        }
        return true
    }
    
    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
    
    @objc func keyboardWillShow(_ notification: Notification) {
        let userInfo = (notification as NSNotification).userInfo!
        let keyboardSize = (userInfo[UIResponder.keyboardFrameEndUserInfoKey] as! NSValue).cgRectValue
        
        kvcKeyboardHeight = keyboardSize.height
        
        if (!kvcIsKeyboardShow) {
            let bottomInputViewFrame = kvcGetViewOfAbsoluteFame(sourceView: kvcTargetView)
            let bottomSpace = kvcMainViewFrame.height - bottomInputViewFrame.origin.y - bottomInputViewFrame.height
            if (kvcKeyboardHeight > bottomSpace) {
                self.view.frame.origin.y = bottomSpace - kvcKeyboardHeight
            }
        }
        
        kvcIsKeyboardShow = true
    }
    
    @objc func keyboardWillHide(_ notification: Notification) {
        kvcIsKeyboardShow = false
        self.view.frame = kvcMainViewFrame
    }
    
    func kvcGetViewOfAbsoluteFame(sourceView:UIView) -> CGRect {
        
        var originX:CGFloat = 0
        var originY:CGFloat = 0
        originX = originX + sourceView.frame.origin.x
        originY = originY + sourceView.frame.origin.y
        var superView = sourceView.superview
        while (superView != nil) {
            if superView is UIScrollView {
                originY = originY - (superView as! UIScrollView).contentOffset.y
            }
            originX = originX + superView!.frame.origin.x
            originY = originY + superView!.frame.origin.y
            superView = superView!.superview
        }
        return CGRect(x: originX, y: originY, width: sourceView.frame.size.width, height: sourceView.frame.size.height)
        
    }
}
