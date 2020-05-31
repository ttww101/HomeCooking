import UIKit

class SBThemeNavigationController: UINavigationController {

    let mNaviBarBgColor:UIColor = appMainColor
    let mNaviButtonColor:UIColor = UIColor.white
    let mTitleTextColor:UIColor = UIColor.white
    let mTitleFont:UIFont = UIFont.boldSystemFont(ofSize: CGFloat(18))
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        self.navigationBar.barTintColor = mNaviBarBgColor
        self.navigationBar.tintColor = mNaviButtonColor
        
        var mTitleAttributes = [NSAttributedString.Key:Any]()
        mTitleAttributes[NSAttributedString.Key.font] = mTitleFont
        mTitleAttributes[NSAttributedString.Key.foregroundColor] = mTitleTextColor
        self.navigationBar.titleTextAttributes = mTitleAttributes
        
    }
    

}
