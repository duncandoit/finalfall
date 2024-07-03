//
//  Effect.swift
//  BoardGame
//
//  Created by Zachary Duncan on 3/8/21.
//

import SpriteKit

protocol Effect {
    var emblem: UIImage { get set }
    var name: String { get set }
    var description: String { get set }
    var color: UIColor { get }
    mutating func execute(source: Piece, target: Piece?, targetSquare: SquareNode, direction: Direction)
}
extension Effect {
    /// Handles a given action on all Pieces in given range
    /// - Parameters:
    ///   - range: Number of Nodes from the source Piece
    ///   - penetrates: Does the Effect propagation continue in a direction after hitting a Piece
    ///   - source:
    ///   - target: The Piece that is the center of the AOE Effect
    ///   - action: Something to be performed on the Pieces surrounding the target
    ///   - subTarget: Sub-target Piece of the target
    ///   - direction: Direction from the source to target
    func aoeAction(range: Int, penetrates: Bool, source: Piece, target: Piece,
                   action: (_ subTarget: Piece, _ direction: Direction)->Void) {
        var vector = Vector(directions: .all, range: range)
        
        // This accounts for the center Piece of the AoE Effect
        action(target, .none)
        
        for direction in Direction.each where vector.directions.contains(direction) {
            vector.range = range
            
            inner: for _ in 1 ... range {
                if let subTarget = target.occupiedSquare.direction(by: vector.range, direction: direction)?.hero {
                    action(subTarget, direction)
                    guard penetrates else { break inner }
                }
                
                vector.range -= 1
            }
        }
    }
    
    /// End-point for use in Effects
    /// - Parameters:
    ///   - source: The source of the Ability
    ///   - target: The Piece to be moved
    ///   - range: The distance to move the target
    ///   - direction: The direction in which to move the target
    ///   - maxStack: The number of Pieces (including the target) that can be moved along with the target
    ///   - sourceAction: If the source Piece is moving and must play a unique texture animation also
    func playMovementAnimation(source: Piece, target: Piece, range: Int, direction: Direction, maxStack: Int, sourceAction: SKAction? = nil) {
        let duration: Double = sourceAction == nil ? 0.1 : sourceAction!.duration
        
        if let (movingPieces, destinationSquares) = movementData(target: target, range: range, direction: direction, maxStack: maxStack) {
            for i in 0 ..< movingPieces.count {
                let piece = movingPieces[i]
                let square = destinationSquares[i]
                
                if piece === source {
                    var actions = [source.snapAction(to: square, direction: direction, duration: duration, commit: true)]
                    if let sourceAction = sourceAction {
                        actions.append(sourceAction)
                    }
                    source.animate(actions)
                } else {
                    let group = [
//                        piece.damagedTextureAction(direction: direction),
                        piece.snapAction(to: square, direction: direction, duration: duration, commit: true)
                    ]
                    piece.animate(group)
                }
            }
        }
    }
    
    /// Gives a singular SKAction that contains all movement for Pieces affected by the targets movement
    /// - Parameters:
    ///   - target: The Piece to be pushed back
    ///   - range: The number of squares from it's current position that it can potentially be pushed back
    ///   - direction: In what direction it should be pushed
    ///   - maxStack: The number of other Pieces the target can push with it before it is prevented from moving farther
    /// - Returns: A tuple of Pieces array to be moved and corresponding SquareNodes array to which the Pieces will be moved. Returns nil if target doesn't move
    ///   - .0 [Piece]: The Pieces to move
    ///   - .1 [SquareNode]: The squares where the Pieces should go
    private func movementData(target: Piece, range: Int, direction: Direction, maxStack: Int) -> ([Piece], [SquareNode])? {
        // This won't cause the target to go anywhere
        guard range > 0 && direction != .none else { return nil }
        
        // Pieces to move ordered furthest from the source to closest
        var movingPieces: [Piece] = [target]
        for i in 1 ... range {
            // Can't exceed the stack size
            guard movingPieces.count < maxStack else { break }
            
            if let square = target.occupiedSquare.direction(by: i, direction: direction) {
                // There is no Piece in the adjacent square
                guard let piece = square.hero else { continue }
                
                // Keep track of the Pieces that are to be pushed with the farthest Piece
                movingPieces.insert(piece, at: 0)
            }
        }
        
        // Sends the farthest Piece from the source to the farthest empty square without
        // crossing an occupied square or exceeding the stack size
        let farPiece = movingPieces[0]
        var farSquare = farPiece.occupiedSquare!
        if !farPiece.statusEffects.contains(.immobilized) {
            farSquare = farthestSquare(fromPiece: farPiece, range: movingPieces.count, direction: direction, currentSquare: farPiece.occupiedSquare)
        }
        
        var destinationSquares: [SquareNode] = [farSquare]
        
        var distance = 1
        for piece in movingPieces {
            // Don't want to modify the farthest Piece's position again
            guard piece != farPiece else { continue }
            guard !piece.statusEffects.contains(.immobilized) else { continue }
            
            // Send each susequent Piece to 1 square away from the previous
            let newSquare = farSquare.direction(by: -distance, direction: direction)!
            destinationSquares.append(newSquare)
            
            distance += 1
        }
        
        return (movingPieces, destinationSquares)
    }
    
    /// Returns the farthest square from the provided Piece within given parameters
    /// - Parameters:
    ///   - piece: The Piece for which its farthest square is to be determined
    ///   - range: The max number of squares that can be considered the piece's "farthest"
    ///   - distance: It tracks the current distance relative to the range. Do not give this a value
    ///   - direction: The Direction from the piece that we evaluate squares
    ///   - currentSquare: It tracks the last valid square from the piece. Initial value should be the piece's occupied square
    /// - Returns: The farthest square from the provided Piece within given parameters
    private func farthestSquare(fromPiece piece: Piece, range: Int, distance: Int = 1, direction: Direction, currentSquare: SquareNode) -> SquareNode {
        // We've gone beyond the given range
        guard distance <= range else { return currentSquare }

        // There wasn't a square at that distance
        guard let newSquare = currentSquare.direction(by: 1, direction: direction) else { return currentSquare }
        
        // The newSquare was already occupied
        guard newSquare.hero == nil else { return currentSquare }
        
        // Keep traversing the board unil one of the conditions above is met
        return farthestSquare(fromPiece: piece, range: range, distance: distance + 1, direction: direction, currentSquare: newSquare)
    }
}

/// These Effects occur once per Ability usage at the beginning of a turn
protocol PrimaryEffect: Effect { }

/// These Effects append themselves to a Piece's afflictions/curatives and
/// affect them at the end of their turn for the set turnDuration
protocol SecondaryEffect: Effect {
    var source: Piece! { get set }
    var duration: Int { get set }
}

struct StatusEffect: OptionSet, CustomStringConvertible {
    let rawValue: UInt16
    
    // MARK: - Individual Statuses
    
    /// Informs the system that a Piece was damaged last turn
    static let damaged =    StatusEffect(rawValue: 1 << 0)
    /// Currently has a heal over time curative
    static let healing =    StatusEffect(rawValue: 1 << 1)
    /// Impairs Abilities
    static let disabled =   StatusEffect(rawValue: 1 << 2)
    /// Impairs Abilities and movement
    static let stunned =    StatusEffect(rawValue: 1 << 3)
    /// Reduces movement range
    static let slowed =     StatusEffect(rawValue: 1 << 4)
    /// Impairs Abilities and movement
    static let sleeping =   StatusEffect(rawValue: 1 << 5)
    /// Impairs Abilities and movement
    static let frozen =     StatusEffect(rawValue: 1 << 6)
    /// Impairs movement
    static let immobilized = StatusEffect(rawValue: 1 << 7)
    /// Damage over time
    static let poisoned =   StatusEffect(rawValue: 1 << 8)
    /// Damage over time
    static let burning =    StatusEffect(rawValue: 1 << 9)
    /// Dispells and prevents healing Effects
    static let cursed =     StatusEffect(rawValue: 1 << 10)
    /// Increases damage output
    static let amplified =  StatusEffect(rawValue: 1 << 11)
    /// Increases movement range
    static let speed =      StatusEffect(rawValue: 1 << 12)
    /// Prevents death
    static let immortal =   StatusEffect(rawValue: 1 << 13)
    /// Ignores all StatusEffects causing movement impairment
    static let unstoppable = StatusEffect(rawValue: 1 << 14)
    
    // MARK: - Collections
    
    static let none = StatusEffect([])
    
    static let curative: StatusEffect = [healing, amplified, immortal, unstoppable]
    
    static let afflictive: StatusEffect = [damaged, disabled, stunned, slowed, sleeping, frozen,
                                           immobilized, poisoned, burning, cursed]
    
    static let movementImpairing: StatusEffect = [stunned, slowed, sleeping, frozen, immobilized]
    
    static let abilityImpairing: StatusEffect = [disabled, stunned, sleeping, frozen]
    
    static let each: [StatusEffect] = [damaged, healing, disabled, stunned, slowed, sleeping,
                                       frozen, immobilized, poisoned, burning, cursed, amplified,
                                       speed, immortal, unstoppable]
    
    static let eachAfflictive: [StatusEffect] = [damaged, disabled, stunned, slowed, sleeping,
                                                 frozen, immobilized, poisoned, burning, cursed]
    
    static let eachMovementImpairing: [StatusEffect] = [stunned, slowed, sleeping, frozen, immobilized]
    
    // MARK: - Properties for individual statuses
    
    var color: UIColor {
        switch self {
        case .damaged: return .damage
        case .healing: return .healing
        case .disabled: return .disabled
        case .stunned: return .stunned
        case .slowed: return .slowed
        case .sleeping: return .sleeping
        case .frozen: return .frozen
        case .immobilized: return .immobilized
        case .poisoned: return .poisoned
        case .burning: return .burning
        case .cursed: return .cursed
        case .amplified: return .amplified
        case .speed: return .speed
        case .immortal: return .immortal
        case .unstoppable: return .unstoppable
        default:
            return .gray
        }
    }
    
    var name: String {
        switch self {
        case .damaged: return "Damage"
        case .healing: return "Heal"
        case .disabled: return "Disable"
        case .stunned: return "Stun"
        case .slowed: return "Slow"
        case .sleeping: return "Sleep"
        case .frozen: return "Freeze"
        case .immobilized: return "Immobilize"
        case .poisoned: return "Poison"
        case .burning: return "Burn"
        case .cursed: return "Curse"
        case .amplified: return "Amplify"
        case .speed: return "Speed"
        case .immortal: return "Immortality"
        case .unstoppable: return "Unstoppable"
        default:
            return "Unknown"
        }
    }
    
    var affectedLabel: String {
        switch self {
        case .damaged: return "damaged"
        case .healing: return "healing"
        case .disabled: return "disabled"
        case .stunned: return "stunned"
        case .slowed: return "slowed"
        case .sleeping: return "sleeping"
        case .frozen: return "frozen"
        case .immobilized: return "immobilized"
        case .poisoned: return "poisoned"
        case .burning: return "burning"
        case .cursed: return "cursed"
        case .amplified: return "amplified"
        case .speed: return "speed"
        case .immortal: return "immortal"
        case .unstoppable: return "unstoppable"
        default:
            return "Unknown"
        }
    }
    
    var emblem: UIImage {
        switch self {
        case .disabled: return UIImage(systemName: "exclamationmark.triangle.fill")!
        case .stunned: return UIImage(systemName: "star.fill")!
        case .slowed: return UIImage(systemName: "hourglass.bottomhalf.fill")!
        case .sleeping: return UIImage(systemName: "zzz")!
        case .frozen: return UIImage(systemName: "snow")!
        case .immobilized: return UIImage(systemName: "stop.circle.fill")!
        case .poisoned: return UIImage(systemName: "pills.fill")!
        case .burning: return UIImage(systemName: "flame.fill")!
        case .cursed: return UIImage(systemName: "person.fill.xmark.rtl")!
        case .amplified: return UIImage(systemName: "bolt.horizontal.fill")!
        case .speed: return UIImage(systemName: "speedometer")!
        case .immortal: return UIImage(systemName: "heart.circle")!
        case .unstoppable: return UIImage(systemName: "arrow.right.to.line.alt")!
        default:
            return UIImage()
        }
    }
    
    var description: String {
        var list = ""
        
        var i = 0
        for effect in StatusEffect.each where self.contains(effect) {
            if i > 0 { list += ", " }
            list +=  effect.name
            i += 1
        }
        
        return list
    }
}
