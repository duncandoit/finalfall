//
//  AbilityDetailBlock.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/19/21.
//

import UIKit

class AbilityDetailBlock: Block {
    // MARK: - AbilityDetailBlock Properties
    
    let ability: Ability
    
    // MARK: - Block Properties
    
    var state: State = .view
    var observer: Observer?
    let isValid: Bool = true
    let modified: Bool = false
    var label: String?
    var required: Bool = false
    var hidden: Bool = false
    var enabled: Bool = false
    var primaryColor: UIColor = .clear
    var primaryTextColor: UIColor = .white
    var secondaryColor: UIColor = .clear
    var secondaryTextColor: UIColor = .clear
    
    // MARK: - Init
    
    init(_ ability: Ability) {
        self.ability = ability
    }
    
    // MARK: - Views
    
    var viewController: UIViewController?
    
    func cell(in tableView: UITableView) -> UITableViewCell {
        tableView.register(UINib(nibName: "AbilityDetailCell", bundle: nil), forCellReuseIdentifier: "AbilityDetailCell")
        guard let cell = tableView.dequeueReusableCell(withIdentifier: "AbilityDetailCell") as? AbilityDetailCell else { return UITableViewCell() }
        cell.selectionStyle = .none
        cell.contentView.backgroundColor = .clear
        
        // MARK: Top details
        
        cell.emblem.image = ability.emblem
        cell.name.text = ability.name.uppercased()
        cell.detail.text = ability.description
        cell.ultimateAbilityLabel.isHidden = !(ability is UltimateAbility)
        
        // MARK: Usage Info Stack
        
        for view in cell.usageInfoStack.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        if let targetVectorsBlock = AbilityDetailBlock.sectionHeader(text: "Target") {
            cell.usageInfoStack.addArrangedSubview(targetVectorsBlock)
        }
        
        for vector in ability.vectors {
            if let vectorView = AbilityDetailBlock.view(for: vector) {
                cell.usageInfoStack.addArrangedSubview(vectorView)
            }
        }
        
        if ability.cooldown > 0 {
            if let cooldownView = UINib(nibName: "AbilityEffectView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? AbilityEffectView {
                cooldownView.emblem.image = BFL.Emblem.cooldown
                cooldownView.effectName.text = "Cooldown"
                cooldownView.effectValue.text = "\(ability.cooldown - 1) turns"
                cell.usageInfoStack.addArrangedSubview(cooldownView)
            }
        }
        
        for view in cell.usageInfoStack.arrangedSubviews {
            if let abilityView = view as? AbilityEffectView {
                abilityView.emblem.roundCorners()
            }
        }
        
        // MARK: Effects Stack
        
        for view in cell.effectsStack.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for pEffect in ability.primaryEffects {
            if let effectView = UINib(nibName: "AbilityEffectView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? AbilityEffectView {
                effectView.emblem.image = pEffect.emblem
                effectView.emblem.backgroundColor = pEffect.color
                effectView.effectName.text = pEffect.name
                effectView.effectValue.text = pEffect.description
                cell.effectsStack.addArrangedSubview(effectView)
            }
        }
        
        for sEffect in ability.secondaryEffects {
            if let effectView = UINib(nibName: "AbilityEffectView", bundle: nil).instantiate(withOwner: nil, options: nil).first as? AbilityEffectView {
                effectView.emblem.image = sEffect.emblem
                effectView.emblem.backgroundColor = sEffect.color
                effectView.effectName.text = sEffect.name
                effectView.effectValue.text = sEffect.description
                cell.effectsStack.addArrangedSubview(effectView)
            }
        }
        
        for view in cell.effectsStack.arrangedSubviews {
            if let effectView = view as? AbilityEffectView {
                effectView.emblem.roundCorners()
            }
        }
        
        return cell
    }
    
    static func view(for vector: Vector) -> AbilityEffectView? {
        guard let vectorView = UINib(nibName: "AbilityEffectView", bundle: nil)
                                .instantiate(withOwner: nil, options: nil).first
                                as? AbilityEffectView
                                else { return nil }
        
        vectorView.effectValue.text = "\(vector.range) spaces"
        
        if vector.directions.contains(.all) {
            vectorView.emblem.image = BFL.Emblem.allDirections
            vectorView.effectName.text = "All Directions"
            return vectorView
        }
        else if vector.range == 0 {
            vectorView.emblem.image = BFL.Emblem.noDirection
            vectorView.effectName.text = "Self-Target"
            vectorView.effectValue.text = ""
            return vectorView
        }
        else {
            if vector.directions.contains(.lateral) {
                vectorView.emblem.image = BFL.Emblem.lateralDirections
                vectorView.effectName.text = "Orthogonal Directions"
                return vectorView
            }
            
            if vector.directions.contains(.diagonal) {
                vectorView.emblem.image = BFL.Emblem.diagonalDirections
                vectorView.effectName.text = "Diagonal Directions"
                return vectorView
            }
        }
        
        return nil
    }
    
    static func sectionHeader(text: String) -> AbilityEffectView? {
        guard let view = UINib(nibName: "AbilityEffectView", bundle: nil)
                            .instantiate(withOwner: nil, options: nil).first
                            as? AbilityEffectView
                            else { return nil }
        
        view.emblem.image = nil
        view.emblem.backgroundColor = .clear
        view.effectName.text = text.uppercased()
        view.effectValue.text = ""
        
        return view
    }
}
