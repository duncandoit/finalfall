//
//  TitleBlock.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/19/21.
//

import UIKit

class TitleBlock: StandardTextBlock {
    init(_ title: String) {
        super.init(text: title)
        messageAlignment = .center
        primaryTextColor = BFL.Color.light
    }
    
    override func cell(in tableView: UITableView) -> UITableViewCell {
        guard let cell = super.cell(in: tableView) as? MessageBlockCell else { return UITableViewCell() }
        cell.message.isHidden = true
        cell.titleLabel.isHidden = false
        cell.titleLabel.textAlignment = .center
        cell.titleLabel.font = BFL.Font.title
        cell.titleLabel.sizeToFit()
        cell.titleLabel.numberOfLines = 1
        cell.titleLabel.adjustsFontSizeToFitWidth = true
        cell.titleLabel.minimumScaleFactor = 0.5
        cell.titleLabel.text = cell.message.text.uppercased()
        return cell
    }
}
