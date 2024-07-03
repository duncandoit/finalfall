//
//  StandardTextBlock.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/19/21.
//

import UIKit

class StandardTextBlock: MessageBlock {
    init(text: String) {
        super.init(text)
        hideLabel = true
    }
    
    override func cell(in tableView: UITableView) -> UITableViewCell {
        guard let cell = super.cell(in: tableView) as? MessageBlockCell else { return UITableViewCell() }
        
        cell.message.backgroundColor = .clear
        cell.backgroundColor = .clear
        
        return cell
    }
}
