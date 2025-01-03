//
//  Piece.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/8/21.
//

import SpriteKit

class Piece {
    // MARK: Character Detail Properties
    let name: String
    let teamRole: TeamRole
    var life: LifeComponent
    private var ultCharge: Float = 0
    private var maxUltCharge: Float
    var ultPercent: Float { ultCharge > 0 ? Float(CGFloat(ultCharge) / CGFloat(maxUltCharge) * 100.0) : 0 }
    
    // MARK: Character Capabilities Properties
    var abilities: [Ability] = []
    var movementVectors: [Vector] = []
    
    // MARK: Character State Properties
    var statusEffects: StatusEffect = .none
    var debuffs: [SecondaryEffect] = []
    var buffs: [SecondaryEffect] = []
    
    // MARK: Game Board Properties
    var team: Team!
    var occupiedSquare: SquareNode!
    var committedSquare: SquareNode!
    var targetSquares: [SquareNode] = []
    var observer: PieceObserver!
    
    // MARK: Sprite Properties
    var sprite: SKSpriteNode!
    var actions: [String:SKAction] = [:]
    var spriteScale: CGFloat = 1
    var spriteOffsetY: CGFloat = 10
    
    // MARK: UI Properties
    var healthbar: Healthbar = Healthbar()
    var healthbarOffsetY: CGFloat = 5
    var isSelected: Bool = false
    var padding: CGFloat!
    
    /// - Parameters:
    ///   - role: .dps, .healer, .tank
    ///   - health: Check Healthbar for the segment length
    ///   - shield: Check Healthbar for the segment length
    ///   - ultCharge: Multiples of 62.5
    init(name: String, role: TeamRole, health: Int, shield: Int = 0, armor: Int = 0, ultCharge: Float = 625.0) {
        self.name = name
        self.teamRole = role
        self.maxUltCharge = ultCharge
        self.life = LifeComponent(health: Float(health), shields: Float(shield), armor: Float(armor))
    }
    
    func setup(onSquare square: SquareNode, board: BoardScene, team: Team) {
        padding = square.frame.width * 0.05
        let width: CGFloat = square.width + padding
        let height: CGFloat = square.height + padding
        let spriteSize = CGSize(width: width + 10, height: height)
        
        sprite = SKSpriteNode(texture: SKTexture(imageNamed: name + "_Idle_0"),
                              size: spriteSize)
        sprite.aspectScale(toFit: spriteSize)
        
        setTextureActions()
        
        occupiedSquare = square
        committedSquare = occupiedSquare
        
        self.team = team
        self.team.add(piece: self)
        observer = board as PieceObserver
        sprite.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        sprite.zPosition = BFL.SceneDepth.heroIdle
        
        square.hero = self
        board.addChild(sprite)
        board.boardView.addSubview(healthbar.barView)
        
        let scaleUp = SKAction.scale(by: spriteScale, duration: 0)
        sprite.run(scaleUp) {
            self.initHealthbar()
            self.playSnapAnimation(to: square)
        }
    }
    
    // MARK: - User Interaction Methods
    
    func select() {
        isSelected = true
        sprite.zPosition = BFL.SceneDepth.heroActive
        observer.pieceSelected(self)
    }
    
    func deselect() {
        isSelected = false
        sprite.zPosition = BFL.SceneDepth.heroIdle
        observer.pieceDeselected(self)
    }
    
    // MARK: - Movement Methods
    
    /// Used while dragging a Piece freely
    func drag(to position: CGPoint) {
        let raisedPosition = CGPoint(x: position.x, y: position.y + spriteOffsetY + occupiedSquare.height * 0.5)
        sprite.position = raisedPosition
        
        alignHealthbar()
    }
    
    /// Used when finished dragging a Piece
    func drop(at position: CGPoint?, validSquares: [SquareNode]) {
        guard let position = position else { resetPosition(); return }
        guard !validSquares.isEmpty else { resetPosition(); return }
        observer.pieceMoved(self)
        
        for square in validSquares {
            if position.isInBounds(of: square) {
                playSnapAnimation(to: square)
                return
            }
        }
        
        // Piece was not dropped on any valid board square
        resetPosition()
    }
    
    /// Used to align this Piece with the provided SquareNode and adjust the affected squares' Piece ownerships
    /// - Parameters:
    ///   - square: The Square to which the Piece will be relocated
    ///   - direction: Provides direction for the sprite's texture animations
    ///   - duration: Determines the duration of the snap movement
    ///   - commit: Whether or not the snap will commit the Piece to its new square
    func snapAction(to square: SquareNode, direction: Direction = .none, duration: Double = 0.1, commit: Bool = false) -> SKAction {
        if committedSquare.hero === self {
            committedSquare?.hero = nil
        }

        occupiedSquare.hero = nil
        occupiedSquare = square
        occupiedSquare.hero = self
        
        let x: CGFloat = square.midX
        let y: CGFloat = square.midY + spriteOffsetY
        let newPosition = CGPoint(x: x, y: y)
        
        var actions: [SKAction] = [
            SKAction.move(to: newPosition, duration: duration),
            alignHealthbarAction(duration: duration)
        ]
        
        if commit {
            actions.append(SKAction.customAction(withDuration: 0) { _, _ in
                self.commitToOccupiedSquare()
            })
        }
        
        let group = SKAction.group(actions)
        return SKAction.sequence([group, idleTextureAction(direction: direction)])
    }
    
    func resetPosition() {
        if committedSquare.hero == nil {
            playSnapAnimation(to: committedSquare)
        } else {
            playSnapAnimation(to: occupiedSquare)
        }
    }
    
    func commitToOccupiedSquare() {
        committedSquare = occupiedSquare
    }
    
    // MARK: - Healthbar Methods
    
    /// First time setup for the Healthbar
    func initHealthbar() {
        healthbar.set(life: life, color: team.color)
        alignHealthbar()
        healthbar.constructHealthbarView()
        healthbar.updateLife(life, animated: false)
    }
    
    func alignHealthbar() {
        let width = occupiedSquare.width - (occupiedSquare.width * 0.01)
        let spriteFrame = CGRect(x: sprite.frame.midX - width / 2,
                                 y: -(sprite.frame.maxY - healthbarOffsetY),
                                 width: width,
                                 height: sprite.height)
        
        healthbar.updateFrame(spriteFrame)
    }
    
    func alignHealthbarAction(duration: Double) -> SKAction {
        let healthbar = SKAction.customAction(withDuration: duration) { _, _ in
            self.alignHealthbar()
        }
        
        return healthbar
    }
    
    // MARK: - Effects
    
    /// Used for attacking or healing a target from player interaction
    func affect(target: Piece?, targetSquare: SquareNode, withAbility ability: inout Ability, direction: Direction) {
        ability.use(source: self, target: target, targetSquare: targetSquare, direction: direction)
    }
    
    /// Used by other methods to cycle through a set of Effects
    private func affected(by effects: inout [SecondaryEffect], type: AbilityType) {
        var i = effects.count - 1
        
        for _ in 0 ..< effects.count {
            effects[i].duration -= 1
            effects[i].execute(source: effects[i].source, target: self, targetSquare: occupiedSquare, direction: .none)

            if effects[i].duration <= 0 { effects.remove(at: i) }
            i -= 1
        }
    }
    
    /// Effects use this to directly damage a Piece
    func damage(by amount: Float, direction: Direction, tags: [String] = [], source: Piece) {
        var selfTags: [String] = tags
        var instigatorTags: [String] = []
        
        for status in StatusEffect.each {
            if statusEffects.contains(status) {
                selfTags.append(status.name)
            }
        }
        
        for status in StatusEffect.each {
            if statusEffects.contains(status) {
                instigatorTags.append(status.name)
            }
        }
        
        let actualDamage = life.handleDamage(received: amount, selfTags: selfTags, instigatorTags: instigatorTags)
        
        playDamagedAnimation(direction: direction)
        animateHealthNumbers(actualDamage, type: .damage)
        statusEffects.insert(.damaged)
        source.chargeUltFromDamage(actualDamage)
        
        if life.getTotalAvailableHealth() <= 0 {
            animateRemovePiece()
        }
    }
    
    /// Effects use this to directly heal a Piece
    func heal(by amount: Float, tags: [String] = [], source: Piece) {
        var selfTags: [String] = tags
        var instigatorTags: [String] = []
        
        for status in StatusEffect.each {
            if statusEffects.contains(status) {
                selfTags.append(status.name)
            }
        }
        
        for status in StatusEffect.each {
            if statusEffects.contains(status) {
                instigatorTags.append(status.name)
            }
        }
        
        let actualHeal = life.handleHealing(received: amount, selfTags: selfTags, instigatorTags: instigatorTags)
        
        animateHealed()
        animateHealthNumbers(actualHeal, type: .heal)
        statusEffects.insert(.healing)
        source.chargeUltFromHealing(actualHeal)
    }
    
    func regenerateShields() {
//        guard shield < maxShield else { return }
//        let regenAmount = 5
//        shield += regenAmount
//        
//        if shield > maxShield {
//            shield = maxShield
//        }
//        
//        animateShieldRegen()
//        animateHealthNumbers(regenAmount, type: .shieldRegen)
    }
    
    // MARK: Start of Turn Calculations
    
    /// Used at the start of a Team's turn to calculate all damage done by lingering debuff Effects
    func affectedByDebuffs() {
        let damagedLastTurn = statusEffects.contains(.damaged)
        statusEffects.remove(StatusEffect.debuff)

        affected(by: &debuffs, type: .damage)
        let damagedThisTurn = statusEffects.contains(.damaged)
        
        if !damagedThisTurn && !damagedLastTurn {
            regenerateShields()
        }
    }
    
    /// If this Piece has .unstoppable StatusEffect this removes all effects that could impair movement
    ///
    /// It is necessary to do this outside the squaresInMovementRange() method because we want to
    /// not only prevent the Piece from being movement impaired, but also ability impaired from those
    /// specific movement impairing StatusEffects (eg. .frozen, .stun).
    /// So we need to not only ingore those StatusEffects but remove them
    func resolveUnstoppable() {
        if statusEffects.contains(.unstoppable) {
            for movementImpairment in StatusEffect.eachMovementImpairing {
                if statusEffects.contains(movementImpairment) {
                    statusEffects.remove(movementImpairment)
                    
                    debuffs.removeAll { effect -> Bool in
                        if let status = effect as? Status {
                            return status.statusEffect.contains(movementImpairment)
                        } else {
                            return false
                        }
                    }
                }
            }
        }
    }
    
    // MARK: End of Turn Calculations
    
    /// Used at the end of a Team's turn to calculate all healing done by lingering buff Effects
    func affectedByBuffs() {
        statusEffects.remove(.buff)
        affected(by: &buffs, type: .heal)
    }
    
    // MARK: - Ult Charging
    
    func chargeUltTurnEnd() {
        chargeUlt(50)
    }
    
    func chargeUltFromDamage(_ damage: Float) {
        guard !ultOnCooldown else { return }
        chargeUlt(damage * 3)
    }
    
    func chargeUltFromHealing(_ healing: Float) {
        guard !ultOnCooldown else { return }
        chargeUlt(healing * 4.0)
    }
    
    private func chargeUlt(_ amount: Float) {
        ultCharge += amount
        ultCharge = ultCharge < maxUltCharge ? ultCharge : maxUltCharge
    }
    
    private var ultOnCooldown: Bool {
        for ability in abilities {
            if ability is UltimateAbility {
                return ability.remainingCooldown != 0
            }
        }
        
        return false
    }
    
    func resetUltCharge() {
        ultCharge = 0
    }
    
    // MARK: - Sprite Texture Methods
    
    // TODO: Put each direction of a sprite's animation in the same atlas
    // (E.g. Heroes/Arryn/Arryn_Idle/Arryn_Idle_Up_0)
    // This way the atlases can be larger and can be accessed in a similar way
    func atlasName(_ state: String) -> String { name + "_" + state + "_" }
    private var idleAtlasName: String { atlasName("Idle") }
    private var jumpAtlasName: String { atlasName("Jump") }
    private var fallAtlasName: String { atlasName("Fall") }
    private var damagedAtlasName: String { atlasName("Damaged") }
    private var deathAtlasName: String { atlasName("Death") }
    
    private func setTextureActions() {
        let fps = 0.15
        
        let idleTextures = SKSpriteNode.texturesFrom(atlasNamed: idleAtlasName)
        let idleAction = SKAction.animate(with: idleTextures, timePerFrame: fps)
        actions.updateValue(SKAction.repeatForever(idleAction), forKey: idleAtlasName)
        
        let jumpTextures = SKSpriteNode.texturesFrom(atlasNamed: jumpAtlasName)
        let jumpAction = SKAction.animate(with: jumpTextures, timePerFrame: fps)
        actions.updateValue(jumpAction, forKey: jumpAtlasName)
        
        let fallTextures = SKSpriteNode.texturesFrom(atlasNamed: fallAtlasName)
        let fallAction = SKAction.animate(with: fallTextures, timePerFrame: fps)
        actions.updateValue(fallAction, forKey: fallAtlasName)
        
        let damagedTextures = SKSpriteNode.texturesFrom(atlasNamed: damagedAtlasName)
        let damagedAction = SKAction.animate(with: damagedTextures, timePerFrame: fps)
        actions.updateValue(damagedAction, forKey: damagedAtlasName)
        
        let deathTextures = SKSpriteNode.texturesFrom(atlasNamed: deathAtlasName)
        let deathAction = SKAction.animate(with: deathTextures, timePerFrame: fps)
        
        actions.updateValue(deathAction, forKey: deathAtlasName)

        for ability in abilities {
            let abilityTextures = SKSpriteNode.texturesFrom(atlasNamed: atlasName(ability.name))
            let abilityAction = SKAction.animate(with: abilityTextures, timePerFrame: fps)
            actions.updateValue(abilityAction, forKey: atlasName(ability.name))
        }
    }
    
    func idleTextureAction(direction: Direction) -> SKAction {
        return actions[idleAtlasName]!
    }
    
    func jumpTextureAction(direction: Direction) -> SKAction {
        return actions[jumpAtlasName]!
    }
    
    func fallTextureAction(direction: Direction) -> SKAction {
        return actions[fallAtlasName]!
    }
    
    func damagedTextureAction(direction: Direction) -> SKAction {
        return actions[damagedAtlasName]!
    }
    
    func deathTextureAction(direction: Direction) -> SKAction {
        return actions[deathAtlasName]!
    }
    
    func abilityTextureAction(_ abilityName: String, direction: Direction) -> SKAction {
        return actions[atlasName(abilityName)]!
    }
    
    // MARK: - Animations
    
    func playSnapAnimation(to square: SquareNode, direction: Direction = .none, duration: Double = 0.1) {
        sprite.run(snapAction(to: square, direction: direction, duration: duration))
    }
    
    func playIdleAnimation(direction: Direction) {
        sprite.run(idleTextureAction(direction: direction))
    }
    
    func playJumpAnimation(direction: Direction) {
        sprite.run(jumpTextureAction(direction: direction))
    }
    
    func playFallAnimation(direction: Direction, completion: (()->Void)? = nil) {
        let fall = fallTextureAction(direction: direction)
        
        sprite.run(fall) {
            completion?()
        }
    }
    
    private func playDamagedAnimation(direction: Direction, completion: (()->Void)? = nil) {
        sprite.run(damagedTextureAction(direction: direction)) {
            completion?()
        }
    }
    
    func playDeathAnimation(direction: Direction, completion: (()->Void)? = nil) {
        let death = deathTextureAction(direction: direction)
        
        sprite.run(death) {
            completion?()
        }
    }
    
    func playAbilityAnimation(_ ability: Ability, direction: Direction, completion: (()->Void)? = nil) {
        let ability = abilityTextureAction(ability.name, direction: direction)
        
        if ability.duration < 0.2 {
            playBumpAction(direction: direction)
            completion?()
        }
        
        else {
            sprite.run(ability) {
                completion?()
            }
        }
    }
    
    func playDangleAnimation(direction: Direction, completion: (()->Void)? = nil) {
        let jump = jumpTextureAction(direction: direction)
        let fall = SKAction.repeatForever(fallTextureAction(direction: direction))
        let sequence = SKAction.sequence([jump, fall])
        
        sprite.run(sequence) {
            completion?()
        }
    }
    
    private func playBumpAction(direction: Direction) {
        let bumpAmount: CGFloat = sprite.width * 0.5
        var delta: CGVector
        
        switch direction {
        case .up:
            delta = CGVector(dx: 0, dy: bumpAmount)
        case .down:
            delta = CGVector(dx: 0, dy: -bumpAmount)
        case .left:
            delta = CGVector(dx: -bumpAmount, dy: 0)
        case .right:
            delta = CGVector(dx: bumpAmount, dy: 0)
        case .upRight:
            delta = CGVector(dx: bumpAmount, dy: bumpAmount)
        case .downRight:
            delta = CGVector(dx: bumpAmount, dy: -bumpAmount)
        case .downLeft:
            delta = CGVector(dx: -bumpAmount, dy: -bumpAmount)
        case .upLeft:
            delta = CGVector(dx: -bumpAmount, dy: bumpAmount)
        default:
            delta = CGVector(dx: 0, dy: 0)
        }
        
        let bump = SKAction.move(by: delta, duration: 0.1)
        let sequence = SKAction.sequence([bump, bump.reversed()])
        sprite.run(sequence)
    }
    
    private func animateHealed() {
        animate(color: .healing)
    }
    
    private func animateShieldRegen() {
        animate(color: .shields)
    }
    
    private func animate(color: UIColor) {
        let colorShift = SKAction.colorize(with: color, colorBlendFactor: 0.6, duration: 0.2)
        let colorReverse = SKAction.colorize(withColorBlendFactor: 0, duration: 0.2)
        
        sprite.run(SKAction.sequence([colorShift, colorReverse]))
    }
    
    private func animateHealthNumbers(_ amount: Float, type: AbilityType) {
        let fontSize: CGFloat = amount >= 100 ? 25 : amount >= 50 ? 20 : 14
        
        EventQueue.sync.pushAndWait {
            let origin = self.healthbar.barView.frame.origin
            let offsetX = origin.x - ((self.sprite.width - self.healthbar.barView.width) / 2)
            let rect = CGRect(x: offsetX, y: origin.y, width: self.sprite.width, height: self.sprite.height)
            let damageLabel = UILabel(frame: rect)
            damageLabel.textAlignment = .center
            damageLabel.font = UIFont.systemFont(ofSize: fontSize, weight: .heavy)
            damageLabel.text = (type == .damage ? "-" : "+") + "\(amount)"
            damageLabel.textColor = type == .damage ? .red : (type == .heal ? .healing : .shields)
            damageLabel.addShadow(radius: 2, offsetY: 3, color: .black)
            (self.observer as! BoardScene).boardView.addSubview(damageLabel)

            UIView.animate(withDuration: 1, delay: 0, options: .allowUserInteraction) {
                damageLabel.frame = CGRect(x: rect.minX, y: rect.minY - 20, width: rect.width, height: rect.height)
            } completion: { finished in
                UIView.animate(withDuration: 1, delay: 0.5, options: .allowUserInteraction) {
                    damageLabel.alpha = 0
                } completion: { _ in
                    damageLabel.removeFromSuperview()
                }
                
                EventQueue.sync.completeTop()
            }
        }
        
        healthbar.updateLife(life)
    }
    
    private func animateRemovePiece() {
        EventQueue.sync.pushAndWait {
            self.sprite.removeAllActions()
            self.playDeathAnimation(direction: .up) {
                self.deselect()
                self.occupiedSquare.hero = nil
                self.team.remove(piece: self)
                self.healthbar.barView.removeFromSuperview()
                self.sprite.removeFromParent()
                EventQueue.sync.completeTop()
            }
        }
    }
    
    func animate(_ actions: [SKAction], duration: Double? = nil) {
        let group = SKAction.group(actions)
        
        if let duration = duration {
            group.duration = duration
        }
        
        sprite.run(group)
    }
    
    // MARK: - Helper Methods
    
    var selectedAbility: Ability? {
        for ability in abilities where ability.isSelected {
            return ability
        }
        
        return nil
    }
    
    func isSameTeam(as piece: Piece?) -> Bool {
        return team == piece?.team
    }
    
    /// Returns an array of board squares that are a valid option for the player to move to
    func squaresInMovementRange() -> [SquareNode] {
        guard canMove else { return [] }
        var squares: [SquareNode] = []
        
        for vector in movementVectors {
            for direction in Direction.each {
                guard vector.directions.contains(direction) else { continue }
                
                let speedIncrease = statusEffects.contains(.speed) ? 2 : 0
                for i in 1 ... vector.range + speedIncrease {
                    guard let square = committedSquare.direction(by: i, direction: direction) else { break }
                    guard square.hero == nil || square.hero === self else { break }
                    squares.append(square)
                }
            }
        }
        
        return squares
    }
    
    func highlightSquaresInRange(of ability: Ability) {
        guard canUseAbilities else { return }
        
        for vector in ability.vectors {
            for direction in Direction.each where vector.directions.contains(direction) {
                // Enables self healing and curing StatusEffects
                if vector.range == 0 {
                    occupiedSquare.blendMode = .add
                    
                    if ability.type.contains(.deploy) {
                        occupiedSquare.color = .squareDeployTarget
                        occupiedSquare.isDeployable = true
                    } else {
                        occupiedSquare.color = .squareFriendlyTarget
                        occupiedSquare.isFriendlyTarget = true
                    }
                    
                    continue
                }
                
                var madeContact = false
                for i in 1 ... vector.range {
                    guard let square = occupiedSquare.direction(by: i, direction: direction) else { continue }
                    square.blendMode = .add
                    
                    // This Piece cannot be targeted because another Piece is in its way
                    if madeContact && !ability.penetrates {
                        square.color = .squareInAbilityRange
                    }
                    
                    // This accounts for targeting filled or empty squares
                    else if ability.type.contains(.deploy) {
                        if !ability.penetrates && square.hero != nil { madeContact = true }
                        square.color = .squareDeployTarget
                        square.isDeployable = true
                    }
                    
                    // Making contact with an enemy or ally
                    else if let target = square.hero {
                        if !ability.penetrates { madeContact = true }
                        
                        if ability.type.contains(.damage) && !isSameTeam(as: target) {
                            square.color = .squareEnemyTarget
                            square.isEnemyTarget = true
                        } else if ability.type.contains(.heal) && isSameTeam(as: target) {
                            square.color = .squareFriendlyTarget
                            square.isFriendlyTarget = true
                        } else {
                            square.color = .squareInAbilityRange
                        }
                    }
                    
                    // Empty square
                    else {
                        square.color = .squareInAbilityRange
                    }
                }
            }
        }
    }
    
    /// - Parameters:
    ///   - target: The Piece for which we determine the distance between it and self
    ///   - direction: The Direction from self to the target Piece
    /// - Returns: The distance between self and target and returns nil if not found
    func distanceTo(target: Piece, direction: Direction) -> Int? {
        let maxLength = BoardScene.rows > BoardScene.columns ? BoardScene.rows : BoardScene.columns
        
        for i in 1 ... maxLength {
            guard let square = occupiedSquare.direction(by: i, direction: direction)  else { continue }
            guard let piece = square.hero else { continue }
            guard piece === target else { continue }
            
            return i - 1
        }
        
        return nil
    }
    
    func piecesInRange(of vector: Vector, penetrates: Bool) -> [Piece] {
        var pieces: [Piece] = []
        
        for direction in Direction.each where vector.directions.contains(direction) {
            if vector.range == 0 { continue }
            
            for i in 1 ... vector.range {
                guard let square = occupiedSquare.direction(by: i, direction: direction)  else { continue }
                guard let piece = square.hero else { continue }
                
                pieces.append(piece)
                
                if !penetrates { break }
            }
        }
        
        return pieces
    }
    
    var canMove: Bool {
        if statusEffects.contains(.unstoppable) {
            return true
        } else {
            let movementBlocking: StatusEffect = StatusEffect.movementImpairing.subtracting(.slowed)
            return statusEffects.isDisjoint(with: movementBlocking)
        }
    }
    
    var canUseAbilities: Bool {
        return statusEffects.isDisjoint(with: StatusEffect.abilityImpairing)
    }
    
    func addAbility(_ ability: Ability) {
        var ability = ability
        ability.observer = self
        
        if let icon = UIImage(named: name + "_" + ability.name) {
            ability.emblem = icon
        }
        
        abilities.append(ability)
    }
}

// MARK: - Extensions

extension Piece: AbilityObserver {
    func abilitySelected(_ ability: Ability) {
        observer.abilitySelected(ability, piece: self)
    }
    
    func abilityDeselected(_ ability: Ability) {
        observer.abilityDeselected(ability, piece: self)
    }
    
    func abilityUsed(_ ability: Ability) {
        observer.abilityUsed(ability, piece: self)
    }
}

extension Piece: CustomStringConvertible {
    var description: String { "Piece: \(name) (\(team.name))" }
}

extension Piece: Equatable {
    static func == (lhs: Piece, rhs: Piece) -> Bool {
        return lhs === rhs
    }
}

protocol PieceObserver {
    func pieceSelected(_ piece: Piece)
    func pieceDeselected(_ piece: Piece)
    func pieceMoved(_ piece: Piece)
    func abilitySelected(_ ability: Ability, piece: Piece)
    func abilityDeselected(_ ability: Ability, piece: Piece)
    func abilityUsed(_ ability: Ability, piece: Piece)
}
