//
//  BackButtonCell.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/20/21.
//

import UIKit

class BackButtonCell: UITableViewCell {
    @IBOutlet weak var title: UILabel!
    @IBOutlet weak var backview: UIView!
    
    let baseColor: UIColor = #colorLiteral(red: 0.390512228, green: 0.3923245072, blue: 0.3967366219, alpha: 1)
    
    private func interation(_ active: Bool) {
        title.textColor = active ? baseColor : .white
        title.backgroundColor = active ? .white : .clear
        backview.backgroundColor = baseColor
    }
    
    override func setHighlighted(_ highlighted: Bool, animated: Bool) {
        super.setHighlighted(highlighted, animated: animated)
        interation(highlighted)
    }
    
    override func setSelected(_ selected: Bool, animated: Bool) {
        super.setSelected(selected, animated: animated)
        interation(selected)
    }
}
