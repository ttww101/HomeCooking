//
//  CookingDetailVC.swift
//  iFitnessMan
//
//  Created by Apple on 2019/4/11.
//  Copyright © 2019年 whitelok.com. All rights reserved.
//

import UIKit

class CookingDetailVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var titleView: UIView!
    @IBOutlet weak var foodImage: UIImageView!
    @IBOutlet weak var detailTable: UITableView!
    
    var rightBarBtn: UIBarButtonItem!
    var materialData = [String]()
    var contentData = [CookingDetailMode]()
    var parameter: [String:String]!
    var collectSave = false
    
    var collectChange: ((_ collect: Bool) -> Void)?
    
    var titleLabel: UILabel = {
       let label = UILabel(frame: CGRect(x: 0, y: 0, width: 100, height: 30))
        label.textAlignment = .center
        label.adjustsFontSizeToFitWidth = true
        return label
    }()
    
    init(_ parameter: [String:String]) {
        super.init(nibName: "CookingDetailVC", bundle: nil)
        self.parameter = parameter
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        detailTable.register(UINib(nibName: "MaterialDetailCell", bundle: nil), forCellReuseIdentifier: "MaterialDetailCell")
        detailTable.register(UINib(nibName: "CookingDetailCell", bundle: nil), forCellReuseIdentifier: "CookingDetailCell")
        
        setUI()
        getData()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UI
    func setUI() {
        setLabel()
        setBarButton()
    }
    func setLabel() {
        titleView.addSubview(titleLabel)
        titleView.addViewLayout(titleLabel, 0, 0, 0, 0)
    }
    func setBarButton() {
        var btnLabel = "收藏"
        for i in 0..<HomeCookingData.collection.count {
            if parameter["id"] == HomeCookingData.collection[i] {
                btnLabel = "已收藏"
                self.collectSave = true
                break
            }
        }
        rightBarBtn = UIBarButtonItem(title: btnLabel, style: .plain, target: self, action: #selector(collectionData(_:)))
        self.navigationItem.rightBarButtonItem = rightBarBtn
    }
    
    // MARK: - Data
    func getData() {
        APIManager.shared.getData(parameter: parameter, completion: { (json) in
            let status: String = json["status"] as! String
            if status == "1" {
                self.organizeData(json["data"] as! AnyObject)
            }
        }) { (error) in
            print(error.localizedDescription)
        }
    }
    func organizeData(_ data: AnyObject) {
        titleLabel.text = data["title"] as! String
        let img: String = data["title_image"] as! String
        foodImage.downloadedFrom(imageurl: img)
        self.materialData = data["material"] as! [String]
        let content = data["content"] as! [AnyObject]
        let contentImage = data["image"] as! [AnyObject]
        for i in 0...content.count - 1 {
            contentData.append(CookingDetailMode.init(content: content[i] as! String, contentImage: contentImage[i] as! String, check: false))
        }
        detailTable.reloadData()
    }
    @objc func collectionData(_ sender: Any) {
        self.collectSave = !self.collectSave
        if self.collectSave { self.rightBarBtn.title = "已收藏" }
        else { self.rightBarBtn.title = "收藏" }
        self.collectChange?(self.collectSave)
    }
    
    // MARK: - tableview data source
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "材料"
        case 1:
            return "做法"
        default:
            return ""
        }
    }
    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        switch indexPath.section {
        case 0:
            return 35
        case 1:
            return 200
        default:
            return 0
        }
    }
    func numberOfSections(in tableView: UITableView) -> Int {
        return 2
    }
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            var origCount = self.materialData.count
            var count = self.materialData.count / 2
            if (origCount - (count * 2)) == 1 {
                count += 1
            }
            return count
        case 1:
            return self.contentData.count
        default:
            return 0
        }
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        if indexPath.section == 0 {
            let row = indexPath.row * 2
            let cellData = self.materialData[row]
            let cell = detailTable.dequeueReusableCell(withIdentifier: "MaterialDetailCell", for: indexPath) as! MaterialDetailCell
            cell.materialLabel1.text = cellData
            cell.materialLabel1.adjustsFontSizeToFitWidth = true
            if (row + 1) < self.materialData.count {
                cell.materialLabel2.text = self.materialData[row + 1]
                cell.materialLabel2.adjustsFontSizeToFitWidth = true
            } 
            return cell
        } else {
            let cellData = self.contentData[indexPath.row]
            let cell = detailTable.dequeueReusableCell(withIdentifier: "CookingDetailCell", for: indexPath) as! CookingDetailCell
            cell.foodImage.downloadedFrom(imageurl: cellData.contentImage)
            cell.stepLabel.text = "步骤\(indexPath.row + 1)"
            cell.contentLabel.text = cellData.content
            cell.contentLabel.lineBreakMode = .byCharWrapping
            cell.contentLabel.numberOfLines = 0
            return cell
        }
        
    }

}
