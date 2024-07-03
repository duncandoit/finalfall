//
//  BackButtonBlock.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/20/21.
//

import UIKit

class BackButtonBlock: ContainerBlock {
    override init() {
        super.init()
        
        selectionAction = {
            UIApplication.topController()?.dismiss(animated: false, completion: nil)
        }
    }
    
    override func cell(in tableView: UITableView) -> UITableViewCell {
        tableView.register(UINib(nibName: "BackButtonCell", bundle: nil), forCellReuseIdentifier: "BackButtonCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "BackButtonCell") as? BackButtonCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        return cell
    }
}
