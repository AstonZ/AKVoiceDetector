//
//  ViewController.swift
//  AKVoiceDetector
//
//  Created by Aston K Mac on 2017/10/27.
//  Copyright © 2017年 LowBee Tech. All rights reserved.
//

import UIKit

class ViewController: UIViewController {

    let cellIdentifier = "RootCell"
    
    lazy var tableView: UITableView! = {
       let table = UITableView.init(frame: UIScreen.main.bounds, style: .grouped)
        table.delegate = self
        table.dataSource = self
        table.register(UITableViewCell.self, forCellReuseIdentifier: cellIdentifier)
        return table
    }()
    
    lazy var modelDic: Dictionary<String, [String]>! = {
        return [
            "voice":["voiceToChinese"],
            "other":["to be Continue"]
                ]
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.view.addSubview(self.tableView)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }


}

extension ViewController: UITableViewDataSource {
    
    func numberOfSections(in tableView: UITableView) -> Int {
        return self.modelDic.count
    }
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return 1
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        
        let key = ([String](self.modelDic.keys))[indexPath.section]
        let list = self.modelDic[key]
        let text = list![indexPath.row]
        
        let cell = tableView.dequeueReusableCell(withIdentifier: cellIdentifier)
        cell?.textLabel?.text = text
        
        return cell!
    }
    
//    section title
    func tableView(_ tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        let key = ([String](self.modelDic.keys))[section]
        return key
    }
    
//    header & footer height
    func tableView(_ tableView: UITableView, heightForHeaderInSection section: Int) -> CGFloat {
        return 30.0
    }
    func tableView(_ tableView: UITableView, estimatedHeightForFooterInSection section: Int) -> CGFloat {
        return 1
    }
}

extension ViewController: UITableViewDelegate
{
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        
        tableView.deselectRow(at: indexPath, animated: true)
        
        let key = ([String](self.modelDic.keys))[indexPath.section]
        let list = self.modelDic[key]
        let text = list![indexPath.row]
        
        var desVC: UIViewController? = nil
        
        switch text {
        case "voiceToChinese":
           desVC = UIStoryboard.init(name: "Main", bundle: nil).instantiateViewController(withIdentifier: "VoiceTransViewController")
        
        default:
            return
        }
        
        self.navigationController?.pushViewController(desVC!, animated: true)

    }
}

