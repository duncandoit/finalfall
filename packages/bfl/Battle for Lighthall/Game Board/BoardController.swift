//
//  BoardController.swift
//  BoardGame
//
//  Created by Zachary Duncan on 2/5/21.
//

import SpriteKit

class BoardController: UIViewController, PieceObserver, BoardObserver {
    @IBOutlet weak var boardView: SKView!
    
    // Turn Detail
    @IBOutlet weak var turnColorView: UIView!
    @IBOutlet weak var turnIndicator: UILabel!
    @IBOutlet weak var endButton: UIButton!
    
    // Selected Hero HUD
    @IBOutlet weak var selectedHeroHUD: UIView!
    @IBOutlet weak var classImage: UIImageView!
    @IBOutlet weak var nameplate: UIView!
    @IBOutlet weak var selectedHero: UILabel!
    @IBOutlet weak var health: UILabel!
    @IBOutlet weak var maxHealth: UILabel!
    @IBOutlet weak var healthbarContainer: UIView!
    @IBOutlet weak var statusEffectsStack: UIStackView!
    @IBOutlet weak var abilityStack: UIStackView!
    
    var blueHeroes: [Piece] = [River(), Mercy(), Arryn(), Elayis(), Ana(), Kredic()]
    var redHeroes: [Piece] = [River(), Mercy(), Arryn(), Melbrana(), Ana(), Kiri()]
    var boardScene: BoardScene!
    var selectedHeroHealthbar = Healthbar()
    var selectedHeroPiece: Piece?
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        overrideUserInterfaceStyle = .light
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        turnColorView.backgroundColor = .systemBlue
        classImage.contentScaleFactor = 10
        healthbarContainer.widthAnchor.constraint(equalToConstant: healthbarContainer.frame.width).isActive = true
        healthbarContainer.addSubview(selectedHeroHealthbar.barView)
        
        clearHeroUI()
    }
    
    override func viewDidAppear(_ animated: Bool) {
        super.viewDidAppear(animated)
        
        boardScene = BoardScene(in: boardView, pieceObserver: self, boardObserver: self)
        boardScene.anchorPoint = CGPoint(x: 0, y: 1)
        boardView.presentScene(boardScene)
        boardScene.createBoard()
        boardScene.addPieces(bluePieces: blueHeroes, redPieces: redHeroes)
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @IBAction func endTurn(_ sender: Any) {
        boardScene?.endTurn()
    }
    
    @IBAction func showHeroDetail(_ sender: Any) {
        guard let hero = selectedHeroPiece else { return }
        let heroDetailVC = HeroDetailController(hero)
        present(heroDetailVC, animated: false, completion: nil)
    }
    
    // MARK: - PieceObserver Methods
    
    func pieceSelected(_ piece: Piece) {
        selectedHeroPiece = piece
        selectedHeroHUD.isHidden = false
        classImage.image = piece.teamRole == .tank ? .tank
            : piece.teamRole == .healer ? .healer
            : .dps
        classImage.tintColor = piece.team.color
        
        selectedHero.text = piece.name.uppercased()
        health.text = "\(piece.health + piece.shield)"
        maxHealth.text = "\(piece.maxHealth + piece.maxShield)"
        
        selectedHeroHealthbar.set(piece: piece, onHUD: true)
        selectedHeroHealthbar.update(frame: healthbarContainer.frame)
        selectedHeroHealthbar.createUI()
        selectedHeroHealthbar.update(health: piece.health, shield: piece.shield, animated: false)
        nameplate.backgroundColor = piece.team.color
        
        addEffectLabels(to: piece)
        
        for var ability in piece.abilities {
            let action = {
                for var a in piece.abilities where a.isSelected { a.isSelected = false }
                ability.isSelected = true
            }
            
            let button = ability.button(for: piece, action: action)
            abilityStack.addArrangedSubview(button)
        }
    }
    
    func pieceDeselected(_ piece: Piece) {
        selectedHeroPiece = nil
        clearHeroUI()
    }
    
    func pieceMoved(_ piece: Piece) {
        for button in abilityStack.subviews as! [AbilityButton] {
            button.isSelected = false
        }
    }
    
    func abilitySelected(_ ability: Ability, piece: Piece) {
        boardScene?.highlightAbilitySquares(for: piece, using: ability)
        
        for button in abilityStack.subviews as! [AbilityButton] {
            if button.name.text?.uppercased() == ability.name.uppercased() {
                button.isSelected = true
            } else {
                button.isSelected = false
            }
        }
    }
    
    func abilityDeselected(_ ability: Ability, piece: Piece) {
        boardScene?.resetSquares()
    }
    
    func abilityUsed(_ ability: Ability, piece: Piece) {
        
    }
    
    // MARK: - BoardObserver Methods
    
    func newTurnStart(color: UIColor, text: String) {
        EventQueue.sync.pushAndWait {
            UIView.animate(withDuration: 0.5) {
                self.turnColorView.backgroundColor = color
                self.turnIndicator.text = text.uppercased()
            } completion: { finished in
                EventQueue.sync.completeTop()
            }
        }
    }
    
    // MARK: - Helper Methods
    
    private func clearHeroUI() {
        selectedHeroHUD.isHidden = true
        selectedHeroHealthbar.reset()
        
        for effect in statusEffectsStack.subviews {
            effect.removeFromSuperview()
        }
        
        for ability in abilityStack.subviews {
            ability.removeFromSuperview()
        }
    }
    
    private func addEffectLabels(to piece: Piece) {
        for statusEffect in StatusEffect.each where piece.statusEffects.contains(statusEffect) {
            guard !statusEffect.contains(.damaged) else { continue }
            addEffectLabel(statusEffect)
        }
    }
    
    private func addEffectLabel(_ effect: StatusEffect) {
        let rect = CGRect(x: 0, y: 0, width: statusEffectsStack.frame.height * 4, height: statusEffectsStack.frame.height)
        let effectLabel = UIButton(frame: rect)
        effectLabel.backgroundColor = effect.color
        effectLabel.setImage(effect.emblem, for: .normal) //setTitle(text, for: .normal)
//        effectLabel.titleLabel?.font = UIFont.systemFont(ofSize: 9, weight: .semibold)
        effectLabel.tintColor = .white//effect.color > #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1) ? .black : .white//setTitleColor(effect.color > #colorLiteral(red: 0.3137254902, green: 0.3137254902, blue: 0.3137254902, alpha: 1) ? .black : .white, for: .normal)
        effectLabel.widthAnchor.constraint(equalToConstant: statusEffectsStack.frame.height).isActive = true
        
        statusEffectsStack.addArrangedSubview(effectLabel)
        effectLabel.roundCorners()
    }
}
