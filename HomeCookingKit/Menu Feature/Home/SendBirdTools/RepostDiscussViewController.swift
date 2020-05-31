import UIKit

class RepostDiscussViewController: KeyboardViewController, UITableViewDelegate, UITableViewDataSource {

    @IBOutlet weak var backgroundView: UIView!
    @IBOutlet weak var backgroundImageView: UIImageView!
    @IBOutlet weak var repostTV: UITableView!
    @IBOutlet weak var sendView: UIView!
    @IBOutlet weak var sendTextField: UITextField!
    @IBOutlet weak var sendBtn: UIButton!
    
    var discussObject:DiscussObject = DiscussObject()
    var sendClickCallback:((_ content:String) -> Void)?
    
    override func viewDidLoad() {
        super.viewDidLoad()

        self.title = "留言"
        
        self.navigationController?.setToolbarHidden(true, animated: false)
        
        sendTextField.delegate = self
        
        repostTV.dataSource = self
        repostTV.delegate = self
        repostTV.contentInset = UIEdgeInsets(top: 5.0, left: 0.0, bottom: 5.0, right: 0.0)
        
        sendBtn.addTarget(self, action: #selector(sendBtnClick), for: UIControl.Event.touchUpInside)
        
    }
    
    override func viewWillAppear(_ animated: Bool) {
        repostTV.reloadData()
    }

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return discussObject.repostArray.count + 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if (indexPath.row > 0) {
            let cell = tableView.dequeueReusableCell(withIdentifier: "repostDiscussTVCS", for: indexPath) as! RepostDiscussTableViewCellS
            
            cell.senderNicknameLabel.text = discussObject.repostArray[indexPath.row - 1].userNickname
            cell.tag = indexPath.row - 1
            if (discussObject.repostArray[indexPath.row - 1].userImageUrl.count > 0) {
                cell.senderImageView.isHidden = false
                downloadImage(url: discussObject.repostArray[indexPath.row - 1].userImageUrl) { (image) in
                    if (cell.tag == (indexPath.row - 1)) {
                        cell.senderImageView.layer.cornerRadius = cell.senderImageView.frame.height / 2
                        cell.senderImageView.clipsToBounds = true
                        cell.senderImageView.image = image
                    }
                }
            } else {
                cell.senderImageView.isHidden = true
            }
            
            cell.contentLabel.text = discussObject.repostArray[indexPath.row - 1].content
            cell.dateLabel.text = discussObject.repostArray[indexPath.row - 1].date
            
            return cell
        } else {
            let cell = tableView.dequeueReusableCell(withIdentifier: "repostDiscussTVCM", for: indexPath) as! RepostDiscussTableViewCellM
            
            cell.senderNicknameLabel.text = discussObject.according.userNickname
            cell.tag = indexPath.row
            if (discussObject.according.userImageUrl.count > 0) {
                cell.senderImageView.isHidden = false
                downloadImage(url: discussObject.according.userImageUrl) { (image) in
                    if (cell.tag == indexPath.row) {
                        cell.senderImageView.layer.cornerRadius = cell.senderImageView.frame.height / 2
                        cell.senderImageView.clipsToBounds = true
                        cell.senderImageView.image = image
                    }
                }
            } else {
                cell.senderImageView.isHidden = true
            }
            
            
            cell.subjectLabel.text = discussObject.subject
            
            cell.accordingTitleLabel.text = discussObject.according.accordingTitle
            cell.accordingSubTitleLabel.text = discussObject.according.accordingSubTitle
            if (discussObject.according.accordingImageUrl.count > 0) {
                cell.accordingImageView.isHidden = false
                downloadImage(url: discussObject.according.accordingImageUrl) { (image) in
                    if (cell.tag == indexPath.row) {
                        cell.accordingImageView.layer.cornerRadius = cell.accordingImageView.frame.height / 2
                        cell.accordingImageView.clipsToBounds = true
                        cell.accordingImageView.image = image
                    }
                }
            } else {
                cell.accordingImageView.isHidden = true
            }
            
            cell.contentLabel.text = discussObject.content
            
            return cell
        }
        
    }
    
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        return UITableView.automaticDimension
    }
    
    @objc func sendBtnClick(sender:UIButton) {
        if (self.sendTextField.text!.count > 0) {
            if (sendClickCallback != nil) {
                sendClickCallback!(self.sendTextField.text!)
            }
        }
    }
    
    func setSendCallback(clickCallback: ((_ content:String) -> Void)?) {
        self.sendClickCallback = clickCallback
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
