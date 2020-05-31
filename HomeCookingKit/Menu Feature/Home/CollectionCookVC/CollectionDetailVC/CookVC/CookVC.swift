//
//  CookVC.swift
//  HomeCooking
//
//  Created by Apple on 4/23/19.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

import UIKit

class CookVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    @IBOutlet weak var cookTable: UITableView!
    @IBOutlet weak var finishBtn: UIButton!
    
    var listData = [CookingDetailMode]()
    var markCount = 0
    
    var cookFinish: (() -> Void)?
    
    init(_ data: [CookingDetailMode]) {
        super.init(nibName: "CookVC", bundle: nil)
        self.listData = data
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        cookTable.register(UINib(nibName: "CookCell", bundle: nil), forCellReuseIdentifier: "CookCell")
        cookTable.reloadData()
        // Do any additional setup after loading the view.
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return listData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = listData[indexPath.row]
        let cell = cookTable.dequeueReusableCell(withIdentifier: "CookCell", for: indexPath) as! CookCell
        cell.cookTitle.text = "步骤\(indexPath.row + 1)"
        cell.cookContent.text = cellData.content
        cell.cookContent.lineBreakMode = .byCharWrapping
        cell.cookContent.numberOfLines = 0
        cell.cookContent.adjustsFontSizeToFitWidth = true
        cell.accessoryType = (cellData.check) ? .checkmark:.none
        cell.bgView.backgroundColor = .white
        
        return cell
    }
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.cookTable.deselectRow(at: indexPath, animated: true)
        listData[indexPath.row].check = !listData[indexPath.row].check
        self.cookTable.reloadRows(at: [indexPath], with: .automatic)
        markCount += (listData[indexPath.row].check) ? 1:-1
        checkMark()
    }
    
    // MARK: - Button
    func checkMark() {
        if markCount == listData.count {
            finishBtn.isHidden = false
        } else {
            finishBtn.isHidden = true
        }
    }

    @IBAction func cookFinish(_ sender: UIButton) {
        cookFinish?()
    }
}
