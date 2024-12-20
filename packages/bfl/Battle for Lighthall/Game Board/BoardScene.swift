//
//  BoardScene.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/8/21.
//

import SpriteKit

class BoardScene: SKScene, PieceObserver {
    static let rows = 6
    static let columns = 6
    let boardView: SKView
    let pieceObserver: PieceObserver
    let boardObserver: BoardObserver
    static let offscreen = CGPoint(x: -9999, y: 9999)
    
    var rootSquare: SquareNode!
    var squares: [SquareNode] = []
    var targetAtlas: SKTextureAtlas = SKTextureAtlas(named: "Target")
    
    let blueteam = Team(name: "Blue", color: .teamBlue, theirTurn: true)
    let redteam = Team(name: "Red", color: .teamRed, theirTurn: false)
    var activeteam: Team { blueteam.theirTurn ? blueteam : redteam }
    var boardLocked: Bool = false
    
    init(in view: SKView, pieceObserver: PieceObserver, boardObserver: BoardObserver) {
        boardView = view
        self.pieceObserver = pieceObserver
        self.boardObserver = boardObserver
        
        view.showsDrawCount = true
        view.showsNodeCount = true
        view.showsFPS = true
        view.ignoresSiblingOrder = true
        
        super.init(size: view.bounds.size)
        
        let pan = UIPanGestureRecognizer(target: self, action: #selector(moveHero))
        let tap = UITapGestureRecognizer(target: self, action: #selector(selectPiece))
        boardView.addGestureRecognizer(pan)
        boardView.addGestureRecognizer(tap)
        
        backgroundColor = .clear
        view.allowsTransparency = true
        view.backgroundColor = .clear
        
//        targetAtlas.preload { }
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - BoardScene Setup
    
    func createBoard() {
        let width: CGFloat = frame.width / CGFloat(BoardScene.columns)
        let height: CGFloat = frame.height / CGFloat(BoardScene.rows)
        let grassTexture = SKTexture()
        rootSquare = SquareNode(texture: grassTexture, size: CGSize(width: width, height: height))
        format(square: rootSquare)
        createNeighborNodes(for: rootSquare)
    }
    
    private func createNeighborNodes(for square: SquareNode, row: Int = 1, column: Int = 1) {
        if column < BoardScene.columns {
            // Create SquareNode to the right
            square.right = SquareNode(texture: square.texture, size: square.size)
            square.right!.columnIndex = column + 1
            square.right!.rowIndex = row
            square.right!.left = square
            format(square: square.right!)
        }
        
        if row < BoardScene.rows {
            // Create or connect existing SquareNode downward
            if let downSquare = square.left?.down?.right {
                square.down = downSquare
                downSquare.up = square
            } else {
                square.down = SquareNode(texture: square.texture, size: square.size)
                square.down!.columnIndex = column
                square.down!.rowIndex = row + 1
                square.down!.up = square
                format(square: square.down!)
            }
            
            createNeighborNodes(for: square.down!, row: row + 1, column: column)
        } else {
            if column < BoardScene.columns {
                // Reset at top row, next column
                let nextColumnRoot = squareAt(row: 1, column: column + 1)!
                createNeighborNodes(for: nextColumnRoot, row: 1, column: column + 1)
            } else {
                // Reached the max depth and width
                return
            }
        }
    }
    
    private func format(square: SquareNode) {
        let width = boardView.frame.width / CGFloat(BoardScene.columns)
        let height = width
        let offsetY = boardView.frame.height - height * CGFloat(BoardScene.rows)
        
        square.zPosition = BFL.SceneDepth.squareNode
        square.baseColor = (square.rowIndex + square.columnIndex).isMultiple(of: 2) ? .squareDark : .squareLight
        square.color = square.baseColor
        square.blendMode = .multiply
        square.colorBlendFactor = 1
        
        addChild(square)
        squares.append(square)
        
        square.anchorPoint = CGPoint(x: 0, y: 1)
        square.size = CGSize(width: width, height: height)
        let x = width * CGFloat(square.columnIndex - 1)
        let y = height * CGFloat(square.rowIndex - 1) + offsetY
        square.position = CGPoint(x: x, y: -y)
    }
    
    func addPieces(bluePieces: [Piece], redPieces: [Piece]) {
        let teamPieces: [[Piece]] = [bluePieces, redPieces]
        
        for teamIndex in 0 ... 1 {
            var square: SquareNode? = teamIndex == 0 ? bottomLeftSquare() : topLeftSquare()
            
            for piece in teamPieces[teamIndex] {
                piece.setup(onSquare: square!, board: self, team: activeteam)
                
                square = square?.right
            }
            
            // Pieces are added on the active Team
            changeSides()
        }
    }
    
    // MARK: - SquareNode Traversal
    
    func squareAt(row: Int, column: Int) -> SquareNode? {
        var square: SquareNode? = rootSquare
        
        square = square?.right(by: column - 1)
        square = square?.down(by: row - 1)
        
        return square
    }
    
    func topLeftSquare() -> SquareNode {
        return rootSquare
    }
    
    func bottomLeftSquare() -> SquareNode {
        var square = topLeftSquare()
        
        while true {
            if let downSquare = square.down(by: 1) {
                square = downSquare
            } else {
                 break
            }
        }
        
        return square
    }
    
    // MARK: - Gameplay
    
    @objc
    func moveHero(_ sender: UIPanGestureRecognizer? = nil) {
        guard !boardLocked else { return }
        guard let gesture = sender else { print("Gesture was nil"); return }
        let viewLocation = gesture.location(in: boardView)
        let sceneLocation = convertPoint(fromView: viewLocation)
        
        if gesture.state == .began {
            resetSquares()
            
            guard let square = nodes(at: sceneLocation).last as? SquareNode,
                  let piece = square.hero,
                  piece.team === activeteam else {
                print("Player began dragging on an invalid Square")
                selectNew(piece: nil)
                return
            }
            
            // Began moving a new Piece
            if piece !== selectedPiece {
                selectNew(piece: piece)
            }
            
            // Ensures the selected Piece is not movement impaired
            guard piece.canMove else {
                print("Player attempted to move " + piece.name + " while they're movement impaired")
                gesture.state = .cancelled
                return
            }
            
            highlightMovementSquares(for: piece)
            piece.playDangleAnimation(direction: .up)
            GameAudio.shared.playEffect("Hero_pickup", type: "mp3")
        }
        else if gesture.state == .changed {
            guard let piece = selectedPiece else { return }
            piece.drag(to: sceneLocation)
        }
        else if gesture.state == .ended || gesture.state == .failed {
            resetSquares()
            guard let piece = selectedPiece else { return }
            let squaresInRange = piece.squaresInMovementRange()
            piece.drop(at: sceneLocation, validSquares: squaresInRange)
            GameAudio.shared.playEffect("Hero_drop", type: "mp3")
        }
    }
    
    @objc
    func selectPiece(_ sender: UITapGestureRecognizer? = nil) {
        guard !boardLocked else { return }
        guard let gesture = sender else { print("Gesture was nil"); return }
        let viewLocation = gesture.location(in: boardView)
        let sceneLocation = convertPoint(fromView: viewLocation)
        
        guard let targetSquare = nodes(at: sceneLocation).last as? SquareNode else {
            print("Player tapped outside the board")
            selectNew(piece: nil)
            return
        }
        
        // Deploying a new deployable Piece to a valid square
        if targetSquare.isDeployable {
            // If there is no current hero selected this will just do nothing. However,
            // a square should only be flagged as isDeployable if there is a currently
            // selected hero that has selected an ability that deploys a new Piece.
            useSelectedAbilityOn(target: nil, targetSquare: targetSquare)
            return
        }
        
        // Interacting with a Hero Piece
        if let hero = targetSquare.hero {
            // Using Ability on a valid target Piece
            if hero.occupiedSquare.isEnemyTarget || hero.occupiedSquare.isFriendlyTarget {
                useSelectedAbilityOn(target: hero, targetSquare: targetSquare)
            }
            
            // Selecting a new Piece on your Team
            else if hero.team == activeteam && selectedPiece != hero {
                selectNew(piece: hero)
            }
        }
        
        // Interacting with a deployable Piece
        else if let deployable = targetSquare.deployable {
            selectNew(piece: deployable)
        }
        
        // Selecting an empty unusable square
        else {
            selectNew(piece: nil)
        }
    }
    
    // MARK: - User Interactions
    
    // TODO: This works currently, but sprites with a lot of blank space with 0 alpha will get in the way of other sprites
    //       Need to probe the pixel at the location of the touch to check if it has alpha > 0
//    /// - Parameter point: Location on the BoardScene to check for a Piece's sprite
//    /// - Returns: A Piece if an opaque part of its sprite is at the provided point
//    private func heroPiece(at point: CGPoint) -> Piece? {
//        for hero in activeteam.heroes {
//            if hero.sprite.contains(point) {
//                return hero
//            }
//        }
//
//        return nil
//    }
    
    private func selectNew(piece: Piece?) {
        resetSquares()
        selectedPiece?.deselect()
        piece?.select()
    }
    
    /// Provide only one argument
    /// - Parameters:
    ///   - targetPiece: Provide targetPiece for damaging/healing another Piece
    ///   - targetSquare: Provide targetSquare for abilities that deploy or in some other way interact with a square independent of a target Piece
    private func useSelectedAbilityOn(target: Piece?, targetSquare: SquareNode) {
        guard let source = selectedPiece else { return }
        if var ability = source.selectedAbility {
            // Prevent further actions from the player until the start of the next turn
            //boardLocked = true
            
            let direction = directionFrom(source: source.occupiedSquare, toTarget: targetSquare)
            
            // The execution of the Ability is enqueued so the subsequent ending of the turn is
            // delayed until animations of various lengths play (after which debuffs/buffs
            // are given to the target)
            EventQueue.sync.pushAndWait {
                source.affect(target: target, targetSquare: targetSquare, withAbility: &ability, direction: direction)
            }
            
            EventQueue.sync.push {
                self.endTurn()
                
                // Re-enable player action now that a new turn has begun
                //self.boardLocked = false
                
                // TODO: Support move history
                // endTurn(source: sourcePiece, target: targetPiece, ability: ability)
            }
        }
    }
    
    
    // MARK: - Highlights
    
    func highlightMovementSquares(for piece: Piece) {
        DispatchQueue.main.async {
            piece.squaresInMovementRange().forEach {
                $0.isTraversable = true
            }
        }
    }
    
    /// Highlights the Nodes that are available to the given Piece to attack
    func highlightAbilitySquares(for piece: Piece, using ability: Ability) {
        piece.highlightSquaresInRange(of: ability)
    }
    
    // MARK: - Turn-end
    
    func endTurn() {
        activeteam.endTurn()
        resetSquares()
        changeSides()
        
        boardObserver.newTurnStart(color: self.activeteam.color, text: self.activeteam.name + " Turn")
        activeteam.startTurn()
    }
    
    func resetSquares() {
        for square in squares {
            square.blendMode = .multiply
            square.color = square.baseColor
            square.isTraversable = false
            square.isEnemyTarget = false
            square.isFriendlyTarget = false
            square.isDeployable = false
        }
    }
    
    var selectedPiece: Piece? {
        for piece in activeteam.heroes {
            if piece.isSelected {
                return piece
            }
        }
        
        return nil
    }
    
    // MARK: - PieceObserver Methods
    
    func pieceSelected(_ piece: Piece) {
        pieceObserver.pieceSelected(piece)
    }
    
    func pieceDeselected(_ piece: Piece) {
        pieceObserver.pieceDeselected(piece)
    }
    
    func pieceMoved(_ piece: Piece) {
        pieceObserver.pieceMoved(piece)
    }
    
    func abilitySelected(_ ability: Ability, piece: Piece) {
        pieceObserver.abilitySelected(ability, piece: piece)
    }
    
    func abilityDeselected(_ ability: Ability, piece: Piece) {
        pieceObserver.abilityDeselected(ability, piece: piece)
    }
    
    func abilityUsed(_ ability: Ability, piece: Piece) {
        piece.team.usedAbility = true
        selectNew(piece: nil)
        pieceObserver.abilityUsed(ability, piece: piece)
    }
    
    // MARK: - Helper Methods
    
    func directionFrom(source: SquareNode, toTarget target: SquareNode) -> Direction {
        var direction: Direction = .none
        
        // Source is higher than target
        if source.rowIndex < target.rowIndex {
            
            // Source is farther right than target
            if source.columnIndex > target.columnIndex {
                direction = .downLeft
            }
            
            // Source is farther left than target
            else if source.columnIndex < target.columnIndex {
                direction = .downRight
            }
            
            // Source is in the same column as target
            else {
                direction = .down
            }
        }
        
        // Source is lower than target
        else if source.rowIndex > target.rowIndex {
            
            // Source is farther right than target
            if source.columnIndex > target.columnIndex {
                direction = .upLeft
            }
            
            // Source is farther left than target
            else if source.columnIndex < target.columnIndex {
                direction = .upRight
            }
            
            // Source is in the same column as target
            else {
                direction = .up
            }
        }
        
        // Source is in the same row as target
        else {
            
            // Source is farther right than target
            if source.columnIndex > target.columnIndex {
                direction = .left
            }
            
            // Source is farther left than target
            else if source.columnIndex < target.columnIndex {
                direction = .right
            }
            
            // else { Source is in the same SquareNode as target so direction stays .none }
        }
        
        return direction
    }
    
    func changeSides() {
        blueteam.theirTurn = blueteam.theirTurn.inverse
        redteam.theirTurn = redteam.theirTurn.inverse
        
        let suffix = blueteam.theirTurn ? "_friendly" : "_enemy"
        GameAudio.shared.playMusic("theme_game_adventurous" + suffix, type: "wav")
        GameAudio.shared.playSting("sting_newturn" + suffix, type: "wav")
    }
}

protocol BoardObserver {
    func newTurnStart(color: UIColor, text: String)
}
