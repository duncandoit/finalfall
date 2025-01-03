//
//  Ability.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/21/21.
//

import UIKit

protocol Ability
{
    var name: String { get }
    var emblem: UIImage { get set }
    var description: String { get }
    var type: AbilityType { get set }
    var vectors: [Vector] { get set }
    var isSelected: Bool { get set }
    var observer: AbilityObserver? { get set }
    
    /// Can attack through other Pieces blocking LoS
    var penetrates: Bool { get }
    
    /// Max number of turns the Piece has to wait before using this Ability again
    var cooldown: Int { get }
    
    /// Remaining number of turns the Piece has to wait before using this Ability again
    var remainingCooldown: Int { get set }
    
    /// Effects that take place immediately when the active Piece interacts with another Piece
    var primaryEffects: [PrimaryEffect] { get set }
    
    /// Effects that are added to the target Piece's debuffs and buffs
    var secondaryEffects: [SecondaryEffect] { get set }
    
    /// Returns a UIButton properly formatted for the Ability with the given Piece's context
    func button(for piece: Piece, action: @escaping (()->Void)) -> AbilityButton
    
    /// The first step of Ability usage.
    /// Subclasses should override with .super being called at the end
    /// (Be aware that .super will call execute and trigger the Ability animation)
    /// - Parameters:
    ///   - source: Piece initiating the execution
    ///   - target: The Piece being affected by the source's ability
    ///   - targetSquare: The square that is selected by the player to deplopy or interact with
    ///   - direction: The Direction from the source to the targetSquare
    func preExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction)
    
    /// The second step of Ability usage
    /// - Parameters:
    ///   - source: Piece initiating the execution
    ///   - target: The Piece being affected by the source's ability
    ///   - targetSquare: The square that is selected by the player to deplopy or interact with
    ///   - direction: The Direction from the source to the targetSquare
    func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction, delay: TimeInterval)
    
    /// The Third and final step of Ability usage.
    /// Subclasses should override with .super being called at the end
    /// - Parameters:
    ///   - source: Piece initiating the execution
    ///   - target: The Piece being affected by the source's ability
    ///   - targetSquare: The square that is selected by the player to deplopy or interact with
    ///   - direction: The Direction from the source to the targetSquare
    func postExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction)
}

extension Ability
{
    /// The main endpoint for Ability usage
    func use(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction)
    {
        observer?.abilityUsed(self)
        preExecute(source: source, target: target, targetSquare: targetSquare, direction: direction)
    }
}

class BaseAbility: Ability
{
    var name: String = ""
    var emblem: UIImage = UIImage()
    var description: String = ""
    var type: AbilityType = .damage
    var vectors: [Vector] = []
    var selected: Bool = false
    var penetrates: Bool = false
    var cooldown: Int = 0
    var remainingCooldown: Int = 0
    var primaryEffects: [PrimaryEffect] = []
    var secondaryEffects: [SecondaryEffect] = []
    var observer: AbilityObserver?
    
    var isSelected: Bool = false
    {
        didSet
        {
            if isSelected
            {
                observer?.abilitySelected(self)
            }
            else
            {
                observer?.abilityDeselected(self)
            }
        }
    }
    
    func button(for piece: Piece, action: @escaping (()->Void)) -> AbilityButton
    {
        guard let button = UINib(nibName: "AbilityButton", bundle: nil)
            .instantiate(withOwner: nil, options: nil).first as? AbilityButton
            else { fatalError() }
        
        button.border.roundCorners(radius: 7)
        button.emblem.image = emblem
        button.name.text = name.uppercased()
        
        var statusEffects = piece.statusEffects
        var statusLabel = UILabel(frame: CGRect(origin: button.frame.origin, size: button.frame.size))
        var statusText: String = ""
        
        for effect in StatusEffect.eachDebuff
        {
            if StatusEffect.abilityImpairing.contains(effect) && statusEffects.contains(effect)
            {
                if statusText.isEmpty
                {
                    statusText += "\(effect)"
                }
                else
                {
                    statusText += "\n\(effect)"
                }
            }
        }
        
        // Main conditions for active Abilities
        var enabled = piece.canUseAbilities
            && !(type.contains(.movement) && statusEffects.contains(.immobilized))
            && remainingCooldown == 0
            && !piece.team.usedAbility
        
        button.set(cooldown: remainingCooldown)
        
        // If all other conditions are met for an Ability being active
        // then this is the last condition that can deactivate an ult
        if self is UltimateAbility
        {
            button.isUltimate = true
            
            if piece.ultPercent != 100
            {
                enabled = false
                button.set(ultPercentage: piece.ultPercent)
            }
        }
        
        button.selectAbilityAction = action
        button.isEnabled = enabled
        
        return button
    }
    
    func preExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction)
    {
        source.playAbilityAnimation(self, direction: direction)
        {
            self.execute(source: source, target: target, targetSquare: targetSquare, direction: direction)
        }
    }
    
    func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction, delay: TimeInterval = 0)
    {
        // Give it one more than the expected cooldown because cooldown will be decremented at the end of the turn
        remainingCooldown = cooldown + 1
        
        // We have a target Piece to affect
        if let target = target
        {
            for i in 0 ..< primaryEffects.count
            {
                primaryEffects[i].execute(source: source, target: target, targetSquare: targetSquare, direction: direction)
            }

            for i in 0 ..< secondaryEffects.count
            {
                var effect = secondaryEffects[i]
                
                // This allows charging ults for the source when SecondaryEffects execute
                effect.source = source
                
                if type.contains(.heal) && source.isSameTeam(as: target)
                {
                    target.buffs.append(effect)
                }
                // Not checking for same-team allows AoE DoT and passive damage Effects to be applied
                // to the source Piece
                else
                {
                    target.debuffs.append(effect)
                }
            }
        }
        
        DispatchQueue.main.asyncAfter(deadline: .now() + delay)
        {
            self.postExecute(source: source, target: target, targetSquare: targetSquare, direction: direction)
        }
    }
    
    func postExecute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction)
    {
        if self is UltimateAbility
        {
            source.resetUltCharge()
        }
        
        // Ending the event started in BoardScene selectPiece()
        EventQueue.sync.completeTop()
    }
}

class UltimateAbility: BaseAbility { }

protocol AbilityObserver
{
    func abilitySelected(_ ability: Ability)
    func abilityDeselected(_ ability: Ability)
    func abilityUsed(_ ability: Ability)
}

struct AbilityType: OptionSet
{
    let rawValue: UInt8
    
    static let damage =         AbilityType(rawValue: 1 << 0)
    static let heal =           AbilityType(rawValue: 1 << 1)
    static let shieldRegen =    AbilityType(rawValue: 1 << 2)
    static let movement =       AbilityType(rawValue: 1 << 3)
    static let deploy =         AbilityType(rawValue: 1 << 4)
    
    static let all:             AbilityType = [damage, heal, shieldRegen, movement]
}
