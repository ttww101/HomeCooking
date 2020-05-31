//
//  IngredientVC.swift
//  HomeCooking
//
//  Created by Apple on 4/22/19.
//  Copyright © 2019 whitelok.com. All rights reserved.
//

import UIKit

class IngredientVC: UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    @IBOutlet weak var finishBtn: UIButton!
    @IBOutlet weak var ingredientTable: UITableView!
    
    var materialData = [IngredientModel]()
    var markCount = 0
    
    var ingredientFinish: (() -> Void)?
    
    init(_ material: [String]) {
        super.init(nibName: "IngredientVC", bundle: nil)
        organizeData(material)
    }
    
    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ingredientTable.register(UINib(nibName: "IngredientCell", bundle: nil), forCellReuseIdentifier: "IngredientCell")
        ingredientTable.reloadData()
    }
    // MARK: - Data
    func organizeData(_ material: [String]) {
        for i in 0..<material.count {
            materialData.append(IngredientModel.init(material: material[i], check: false))
        }
    }
    
    // MARK: - UITableViewDataSource
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return materialData.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cellData = materialData[indexPath.row]
        let cell = ingredientTable.dequeueReusableCell(withIdentifier: "IngredientCell", for: indexPath) as! IngredientCell
        cell.ingredientLabel.text = cellData.material
        cell.ingredientLabel.adjustsFontSizeToFitWidth = true
        cell.accessoryType = (cellData.check) ? .checkmark:.none
        cell.bgView.backgroundColor = .white
        
        return cell
    }
    // MARK: - UITableViewDelegate
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        self.ingredientTable.deselectRow(at: indexPath, animated: true)
        materialData[indexPath.row].check = !materialData[indexPath.row].check
        self.ingredientTable.reloadRows(at: [indexPath], with: .automatic)
        markCount += (materialData[indexPath.row].check) ? 1:-1
        checkMark()
    }
    
    // MARK: - Button
    func checkMark() {
        if markCount == materialData.count {
            finishBtn.isHidden = false
        } else {
            finishBtn.isHidden = true
        }
    }
    @IBAction func finishClick(_ sender: UIButton) {
        self.ingredientFinish?()
    }
}
