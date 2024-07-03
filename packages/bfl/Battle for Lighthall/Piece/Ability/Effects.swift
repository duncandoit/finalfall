//
//  Effects.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/22/21.
//

import UIKit

// MARK: - Wrapper Effects

/// Transforms a PrimaryEffect into a SecondaryEffect
struct Secondary: SecondaryEffect {
    var emblem: UIImage
    var name: String
    var description: String
    var color: UIColor
    var source: Piece!
    var duration: Int
    var effect: PrimaryEffect
    
    init(_ effect: PrimaryEffect, duration: Int) {
        self.emblem = effect.emblem
        self.name = effect.name
        self.description = effect.description + " over \(duration) turns"
        self.color = effect.color
        
        self.effect = effect
        self.duration = duration
    }
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        effect.execute(source: source, target: target, targetSquare: targetSquare, direction: direction)
    }
}

/// Transforms a SecondaryEffect into a PrimaryEffect that affects
/// surrounding Pieces in every Direction to a given range
struct AOE: PrimaryEffect {
    var emblem: UIImage
    var name: String
    var description: String
    var color: UIColor
    private let type: AbilityType
    private let range: Int
    private var effect: SecondaryEffect
    
    init(_ effect: SecondaryEffect, range: Int, type: AbilityType) {
        self.emblem = effect.emblem
        self.name = effect.name
        self.description = effect.description + " (AOE)"
        self.color = effect.color
        self.type = type
        self.range = range
        self.effect = effect
    }
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        guard let target = target else { return }
        
        aoeAction(range: range, penetrates: true, source: source, target: target) { subTarget, _ in
            if self.type.contains(.damage) {
                if !source.isSameTeam(as: subTarget) {
                    effect.source = source
                    subTarget.afflictions.append(effect)
                }
            }
            
            if self.type.contains(.heal) {
                if source.isSameTeam(as: subTarget) {
                    effect.source = source
                    subTarget.curatives.append(effect)
                }
            }
        }
    }
}

/// Transforms an Effect into a PrimaryEffect that hits every Piece in the Direction from the
/// source to the target (to the max range of the Effect)
struct Multitarget: PrimaryEffect {
    var emblem: UIImage
    var name: String
    var description: String
    var color: UIColor
    private let type: AbilityType
    private let range: Int
    private var effect: Effect
    
    init(_ effect: Effect, range: Int, type: AbilityType) {
        self.emblem = effect.emblem
        self.name = effect.name
        self.description = effect.description + " (Multitarget)"
        self.color = effect.color
        self.type = type
        self.range = range
        self.effect = effect
    }
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        let nextSquare = source.occupiedSquare.direction(by: 1, direction: direction)
        affectNext(square: nextSquare, direction: direction, distance: 0, source: source, targetSquare: targetSquare)
    }
    
    /// Traverse squares in a given Direction until distance equals range
    /// - Parameters:
    ///   - square: The current square to be visited
    ///   - direction: Direction to traverse
    ///   - distance: Number of squares visited
    private func affectNext(square: SquareNode?, direction: Direction, distance: Int, source: Piece, targetSquare: SquareNode) {
        // Base cases
        guard let square = square else { return } // Ensure we don't continue out of bounds
        guard distance < range else { return } // Ensure we don't go beyond the Ability's range
        
        // Visit square
        if let target = square.hero {
            if var primary = effect as? PrimaryEffect {
                // Enemy
                if type.contains(.damage) && !source.isSameTeam(as: target) {
                    primary.execute(source: source, target: target, targetSquare: targetSquare, direction: direction)
                }
                
                // Friendly
                if type.contains(.heal) && source.isSameTeam(as: target) {
                    primary.execute(source: source, target: target, targetSquare: targetSquare, direction: direction)
                }
            }
            else if var secondary = effect as? SecondaryEffect {
                // Enemy
                if type.contains(.damage) && !source.isSameTeam(as: target) {
                    secondary.source = source
                    target.afflictions.append(secondary)
                }
                
                // Friendly
                if type.contains(.heal) && source.isSameTeam(as: target) {
                    secondary.source = source
                    target.curatives.append(secondary)
                }
            }
        }
        
        // Push to stack
        let nextSquare = square.direction(by: 1, direction: direction)
        affectNext(square: nextSquare, direction: direction, distance: distance + 1, source: source, targetSquare: targetSquare)
    }
}

// MARK: Standard Effects

struct Damage: PrimaryEffect {
    var emblem: UIImage = UIImage(systemName: "target")!
    var name: String
    var description: String
    var color: UIColor = .damage
    let amount: Int
    let aoeRange: Int?
    let ignoreShields: Bool
    let penetrates: Bool
    
    /// Basic attack Effect
    /// - Parameters:
    ///   - amount: The basic value of the attack
    ///   - aoeRange: When a non-nil aoeRange is given the Effect is treated as an AOE Effect
    ///   - penetrates: When aoeRange is non-nil this determines if damage will propagate past the initial sub-target
    ///   - ignoreShields: When true the attack only affects the target's health
    init(_ amount: Int, aoeRange: Int? = nil, penetrates: Bool = false, ignoreShields: Bool = false) {
        self.name = ignoreShields ? "Magic Damage" : "Damage"
        self.description = "\(amount)"
        if aoeRange != nil { description += " (AOE)" }
        if penetrates { description += " (Penetrates)" }
        
        self.amount = amount
        self.aoeRange = aoeRange
        self.penetrates = penetrates
        self.ignoreShields = ignoreShields
    }
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        guard let target = target else { return }
        
        if let range = aoeRange {
            aoeAction(range: range, penetrates: penetrates, source: source, target: target) { subTarget, _ in
                if !source.isSameTeam(as: subTarget) {
                    subTarget.damage(by: amount, direction: direction, ignoreShields: ignoreShields, source: source)
                }
            }
        } else {
            target.damage(by: amount, direction: direction, ignoreShields: ignoreShields, source: source)
        }
    }
}

struct Heal: SecondaryEffect {
    var emblem: UIImage = UIImage(systemName: "cross.circle")!
    var name: String
    var description: String
    var color: UIColor
    var source: Piece!
    var duration: Int
    let amount: Int
    let aoeRange: Int?
    
    /// Basic heal Effect
    /// - Parameters:
    ///   - amount: The basic value of the heal
    ///   - aoeRange: When a non-nil aoeRange is given the Effect is treated as an AOE Effect
    init(_ amount: Int, duration: Int = 1, aoeRange: Int? = nil) {
        self.name = "Heal"
        self.description = "\(amount)"
        if aoeRange != nil { description += " (AOE)" }
        self.color = .healing
        
        self.amount = amount
        self.duration = duration
        self.aoeRange = aoeRange
    }
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        guard let target = target else { return }
        
        if let range = aoeRange {
            aoeAction(range: range, penetrates: true, source: source, target: target) { subTarget, _ in
                if source.isSameTeam(as: subTarget) {
                    subTarget.heal(by: amount, source: source)
                }
            }
        } else {
            target.heal(by: amount, source: source)
        }
    }
}

struct HealDamageCombo: PrimaryEffect {
    var emblem: UIImage = UIImage(systemName: "plusminus.circle")!
    var name: String
    var description: String
    var color: UIColor = #colorLiteral(red: 0.9441839457, green: 0.1662040353, blue: 0.6839093566, alpha: 1)
    let amount: Int
    
    init(_ amount: Int) {
        self.name = "Damage/Heal"
        self.description = "\(amount)/\(amount * 2)"
        self.amount = amount
    }
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        if source.isSameTeam(as: target) {
            target?.heal(by: amount * 2, source: source)
        } else {
            target?.damage(by: amount, direction: direction, source: source)
        }
    }
}

// MARK: - Forced Movement

struct ForceMove: PrimaryEffect {
    var emblem: UIImage = UIImage(systemName: "arrowshape.bounce.right.fill")!
    var name: String
    var description: String
    var color: UIColor = #colorLiteral(red: 0.6084285378, green: 0.5800538659, blue: 0.05890151113, alpha: 1)
    
    private let distance: Int
    private let isAOE: Bool
    private let stackSize: Int
    private let sourceAbilityName: String?
    
    /// Moves the target Piece a certain number of squares
    /// - Parameters:
    ///   - distance: The maximum number of squares the target Piece can move
    ///   - isAOE: Whether adjacenet Pieces from the target will be affected by the movement
    ///   - stackSize: The number of other Pieces that can be moved along with the target
    ///   - selfTargetAbilityName: The source's Ability name (only if you want to self-target)
    init(distance: Int, isAOE: Bool = false, stackSize: Int = 1, selfTargetAbilityName: String? = nil) {
        self.name = selfTargetAbilityName == nil ? "Move Target" : "Move Self"
        self.description = "\(distance) spaces"
        if isAOE { description += " (AOE)" }
        
        self.distance = distance
        self.isAOE = isAOE
        self.stackSize = stackSize
        self.sourceAbilityName = selfTargetAbilityName
    }
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        guard let target = target else { return }
        
        // Target the source
        if let sourceAbilityName = sourceAbilityName {
            if !source.statusEffects.contains(.immobilized) {
                let abilityAction = source.abilityTextureAction(sourceAbilityName, direction: direction)
                playMovementAnimation(source: source, target: source, range: distance, direction: direction, maxStack: stackSize, sourceAction: abilityAction)
            }
        }
        // Target the target and surrounding sub-targets
        else if isAOE {
            aoeAction(range: distance, penetrates: false, source: source, target: target) { subTarget, direction in
                if !source.isSameTeam(as: subTarget) {
                    if !subTarget.statusEffects.contains(.immobilized) {
                        playMovementAnimation(source: source, target: subTarget, range: distance, direction: direction, maxStack: stackSize)
                    }
                }
            }
        }
        // Target the target
        else {
            if !target.statusEffects.contains(.immobilized) {
                playMovementAnimation(source: source, target: target, range: distance, direction: direction, maxStack: stackSize)
            }
        }
    }
}

// MARK: - Status Effects

struct Cure: PrimaryEffect {
    var emblem: UIImage = UIImage(systemName: "sparkles")!
    var name: String = "Cure"
    var description: String = "Removes negative status effects"
    var color: UIColor = #colorLiteral(red: 0.4745098054, green: 0.8392156959, blue: 0.9764705896, alpha: 1)
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        target?.statusEffects = .none
        
        target?.afflictions.removeAll { effect -> Bool in
            if let effect = effect as? Status {
                return effect.statusEffect.contains(.sleeping)
                    || effect.statusEffect.contains(.slowed)
                    || effect.statusEffect.contains(.immobilized)
                    || effect.statusEffect.contains(.stunned)
                    || effect.statusEffect.contains(.disabled)
                    || effect.statusEffect.contains(.poisoned)
                    || effect.statusEffect.contains(.frozen)
                    || effect.statusEffect.contains(.burning)
            }
            
            return false
        }
    }
}

struct Status: SecondaryEffect {
    // MARK: Standard StatusEffects
    static let poison =     Status(.poisoned, duration: 5, damage: 5)
    static let freeze =     Status(.frozen, duration: 3, damage: 10)
    static let burn =       Status(.burning, duration: 3, damage: 10)
    static let disable =    Status(.disabled, duration: 3)
    static let stun =       Status(.stunned, duration: 3)
    static let sleep =      Status(.sleeping, duration: 3)
    static let slow =       Status(.slowed, duration: 3)
    static let immobilize = Status(.immobilized, duration: 3)
    static let cursed =     Status(.cursed, duration: 2)
    static let amplified =  Status(.amplified, duration: 3)
    static let speed =      Status(.speed, duration: 3)
    
    var emblem: UIImage
    var name: String
    var description: String = ""
    var color: UIColor
    
    var source: Piece!
    let statusEffect: StatusEffect
    var duration: Int
    let damage: Int?
    
    init(_ statusEffect: StatusEffect, duration: Int, damage: Int? = nil, name: String? = nil, emblem: UIImage? = nil) {
        self.emblem = emblem ?? statusEffect.emblem
        self.name = name ?? statusEffect.name
        self.color = statusEffect.color
        self.statusEffect = statusEffect
        self.duration = duration
        self.damage = damage
    }
    
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
        if let amount = damage {
            target?.damage(by: amount, direction: direction, source: source)
        }
        
        target?.statusEffects.insert(statusEffect)
    }
}

// MARK: - Deployable

//struct Deploy: PrimaryEffect {
//    var emblem: UIImage
//    var name: String
//    var description: String
//    var color: UIColor
//    
//    private let sourceAbilityName: String?
//    private let 
//    
//    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction) {
//        
//    }
//}
