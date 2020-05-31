import UIKit

class QueryDiscussViewController: UIViewController, UITableViewDelegate, UITableViewDataSource {
    
    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var discussTV: UITableView!
    
    var discussArray = [DiscussObject]()

    var viewDidAppearCallback:((_ recallback: (() -> Void)?) -> Void)?
    var accordingClickCallback:((_ discuss:DiscussObject) -> Void)?
    var repostClickCallback:((_ discuss:DiscussObject) -> Void)?
    var likeClickCallback:((_ discuss:DiscussObject) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
//        self.title = "评论"
        
        let closeBtn:UIBarButtonItem = UIBarButtonItem(barButtonSystemItem: UIBarButtonItem.SystemItem.cancel, target: self, action: #selector(cancelBtnClick))
        
        self.navigationItem.leftBarButtonItem = closeBtn
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        discussTV.dataSource = self
        discussTV.delegate = self
        discussTV.contentInset = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 5.0, right: 0.0)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        resetTableView(discussArray) {
            
        }
    }
    
    override func viewDidAppear(_ animated: Bool) {
        startIndicator { (indicatorView) in
            if (self.viewDidAppearCallback != nil) {
                self.viewDidAppearCallback!({() -> Void in
                    stopIndicator(indicatorView: indicatorView, callback: {
                        
                    })
                })
            }
        }
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discussArray.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let cell = tableView.dequeueReusableCell(withIdentifier: "queryDiscussTVC", for: indexPath) as! QueryDiscussTableViewCell
        
        cell.senderNicknameLabel.text = self.discussArray[indexPath.row].according.userNickname
        cell.tag = indexPath.row
        if (self.discussArray[indexPath.row].according.userImageUrl.count > 0) {
            cell.senderImageView.isHidden = false
            downloadImage(url: self.discussArray[indexPath.row].according.userImageUrl) { (image) in
                if (cell.tag == indexPath.row) {
                    cell.senderImageView.layer.cornerRadius = cell.senderImageView.frame.height / 2
                    cell.senderImageView.clipsToBounds = true
                    cell.senderImageView.image = image
                }
            }
        } else {
            cell.senderImageView.isHidden = true
        }
        
        
        cell.subjectLabel.text = self.discussArray[indexPath.row].subject
        
        cell.accordingTitleLabel.text = self.discussArray[indexPath.row].according.accordingTitle
        cell.accordingSubTitleLabel.text = self.discussArray[indexPath.row].according.accordingSubTitle
        if (self.discussArray[indexPath.row].according.accordingImageUrl.count > 0) {
            cell.accordingImageView.isHidden = false
            downloadImage(url: self.discussArray[indexPath.row].according.accordingImageUrl) { (image) in
                if (cell.tag == indexPath.row) {
                    cell.accordingImageView.layer.cornerRadius = cell.accordingImageView.frame.height / 2
                    cell.accordingImageView.clipsToBounds = true
                    cell.accordingImageView.image = image
                }
            }
        } else {
            cell.accordingImageView.isHidden = true
        }
        
        cell.contentLabel.text = self.discussArray[indexPath.row].content
        cell.dateLabel.text = self.discussArray[indexPath.row].date
        
        cell.repostBtn.setTitle("留言 \(self.discussArray[indexPath.row].repostArray.count)", for: UIControl.State.normal)
        cell.likeBtn.setTitle("赞 \(self.discussArray[indexPath.row].likeArray.count)", for: UIControl.State.normal)
        
        cell.accordingSelectBtn.tag = indexPath.row
        cell.accordingSelectBtn.addTarget(self, action: #selector(accordingBtnClick), for: UIControl.Event.touchUpInside)
        cell.repostBtn.tag = indexPath.row
        cell.repostBtn.addTarget(self, action: #selector(repostBtnClick), for: UIControl.Event.touchUpInside)
        cell.likeBtn.tag = indexPath.row
        cell.likeBtn.addTarget(self, action: #selector(likeBtnClick), for: UIControl.Event.touchUpInside)
        
        cell.layoutIfNeeded()
            
        return cell
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func cancelBtnClick(sender:UIButton) {
        if let navi = self.navigationController {
            if let naviSelf = navi as? SBThemeNavigationController {
                naviSelf.dismiss(animated: true, completion: nil)
            } else {
                navi.popViewController(animated: true)
            }
        } else {
            self.dismiss(animated: true, completion: nil)
        }
    }
    
    @objc func accordingBtnClick(sender:UIButton) {
        if (accordingClickCallback != nil) {
            accordingClickCallback!(self.discussArray[sender.tag])
        }
    }
    
    @objc func repostBtnClick(sender:UIButton) {
        if (repostClickCallback != nil) {
            repostClickCallback!(self.discussArray[sender.tag])
        }
    }
    
    @objc func likeBtnClick(sender:UIButton) {
        if (likeClickCallback != nil) {
            likeClickCallback!(self.discussArray[sender.tag])
        }
    }
    
    func setViewDidAppearCallback(callback: ((_ recallback: (() -> Void)?) -> Void)?) {
        self.viewDidAppearCallback = callback
    }
    
    func setAccordingCallback(clickCallback: ((_ discuss:DiscussObject) -> Void)?) {
        self.accordingClickCallback = clickCallback
    }
    
    func setRepostCallback(clickCallback: ((_ discuss:DiscussObject) -> Void)?) {
        self.repostClickCallback = clickCallback
    }
    
    func setLikeCallback(clickCallback: ((_ discuss:DiscussObject) -> Void)?) {
        self.likeClickCallback = clickCallback
    }
    
    func resetTableView(_ discussArray:[DiscussObject], callback: (() -> Void)?) {
        DispatchQueue.main.async {
            self.discussArray = discussArray
            self.discussTV.reloadData()
            if (callback != nil) {
                callback!()
            }
        }
    }
    
    func httpConnect(url:String, type:String, headers:[String:String], uploadDic:[String:Any]?, callback: @escaping (_ runStatus:Int, _ headers:[String:String], _ data:Data, _ error:String) -> Void) {
        
        var request = URLRequest(url: URL(string: url)!)
        
        do {
            if type == "GET" {
                
            } else if type == "POST"{
                if (uploadDic != nil) {
                    request.httpBody = try JSONSerialization.data(withJSONObject: uploadDic!, options: JSONSerialization.WritingOptions())
                }
            } else if type == "PUT"{
                if (uploadDic != nil) {
                    request.httpBody = try JSONSerialization.data(withJSONObject: uploadDic!, options: JSONSerialization.WritingOptions())
                }
            } else if type == "DELETE"{
                if (uploadDic != nil) {
                    request.httpBody = try JSONSerialization.data(withJSONObject: uploadDic!, options: JSONSerialization.WritingOptions())
                }
            }
        } catch let error{
            print("http type \(error)")
        }
        
        request.httpMethod = type
        
        for i in 0..<Array(headers.keys).count {
            request.setValue(Array(headers.values)[i], forHTTPHeaderField: Array(headers.keys)[i])
        }
        
        let session = URLSession.shared
        let task = session.dataTask(with: request as URLRequest){
            (data, response, error) -> Void in
            
            if error != nil {
                callback(999, [String:String](), Data(), error!.localizedDescription)
            } else {
                
                let httpResponse = response as! HTTPURLResponse
                let resultStatus = httpResponse.statusCode
                let responseHeaders = httpResponse.allHeaderFields
                var resultHeaders = [String:String]()
                for i in 0..<Array(responseHeaders.keys).count {
                    if let headerKey = Array(responseHeaders.keys)[i] as? String {
                        if let headerValue = Array(responseHeaders.values)[i] as? String {
                            resultHeaders[headerKey] = headerValue
                        }
                    }
                }
                var resultData:Data = Data()
                if (data != nil) {
                    resultData = data!
                }
                
                callback(resultStatus, resultHeaders, resultData, "")
                
            }
        }
        
        task.resume()
    }
    
    func downloadImage(url: String, callback: @escaping (UIImage?) -> Void) {
        httpConnect(url: url, type: "GET", headers: [String:String](), uploadDic: nil) { (resultStatus, resultHeaders, resultData, errorString) in
            DispatchQueue.main.async {
                if (resultStatus == 200) {
                    callback(UIImage(data: resultData))
                } else {
                    callback(nil)
                }
            }
        }
    }

}
