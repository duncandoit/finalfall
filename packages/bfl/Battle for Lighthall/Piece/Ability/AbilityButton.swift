//
//  AbilityButton.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/21/21.
//

import UIKit

class AbilityButton: UIView {
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var emblem: UIImageView!
    @IBOutlet weak var border: UIView!
    @IBOutlet weak var counter: UILabel!
    
    var selectAbilityAction: (()->Void)?
    var isUltimate: Bool = false
    
    var isSelected: Bool = false {
        didSet {
            setState()
        }
    }
    
    var isEnabled: Bool = true {
        didSet {
            setState()
        }
    }
    
    private func setState() {
        if isSelected {
            border.backgroundColor = .abilitySelected
        } else {
            if isUltimate {
                if isEnabled {
                    border.backgroundColor = .abilityUltimate
                    border.morphBackground(with: .abilityUltimate + 0.1, duration: 1)
                } else {
                    border.backgroundColor = .abilityDisabled
                    counter.backgroundColor = .abilityUltimate
                }
            } else {
                border.backgroundColor = isEnabled ? .abilityEnabled : .abilityDisabled
            }
        }
    }
    
    private func playerInteractionBegan() {
        
    }
    
    private func playerInteractionEnded() {
        
    }
    
    func set(cooldown: Int) {
        if cooldown == 0 {
            counter.isHidden = true
        } else {
            counter.isHidden = false
            counter.text = "\(cooldown)"
            border.backgroundColor = .abilityEnabled
        }
    }
    
    func set(ultPercentage: Int) {
        if ultPercentage == 100 {
            counter.isHidden = true
        } else {
            counter.isHidden = false
            counter.text = "\(ultPercentage)%"
        }
    }
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        if isEnabled && !isSelected {
            setState()
            selectAbilityAction?()
        }
        
        playerInteractionBegan()
    }
    
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        playerInteractionEnded()
    }
}
