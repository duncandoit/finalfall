//
//  PieceSelectionController.swift
//  BoardGame
//
//  Created by Zachary Duncan on 3/17/21.
//

import UIKit

class PieceSelectionController: UIViewController {
    @IBOutlet weak var teamName: UILabel!
    @IBOutlet weak var selectionStack: UIStackView!
    @IBOutlet weak var optionsStack: UIStackView!
    @IBOutlet weak var optionsClass: UIImageView!
    @IBOutlet weak var readyButton: UIButton!
    var pieceSelections: [PieceSelection] = []
    var pieceOptions: [PieceOption] = []
    var gameBoardController: BoardController?
    
    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        for touch in touches {
            
        }
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        overrideUserInterfaceStyle = .light
        setupUI()
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
    
    @IBAction func ready(_ sender: Any) {
        var teamHeroes: [Piece] = []
        for selection in pieceSelections where selection.heroName != nil {
            teamHeroes.append(PieceService.newHeroPiece(selection.heroName!))
        }
        
        if let controller = gameBoardController {
            // When we have each team's pieces chosen
            controller.redHeroes = teamHeroes
            present(controller, animated: true, completion: nil)
        }
        else {
            let storyboard = UIStoryboard(name: "Main", bundle: nil)
            
            // Create the game controller to give it the blue team Pieces
            guard let gameBoardController = storyboard.instantiateViewController(withIdentifier: "GameBoardController")
                    as? BoardController else { return }
            
            gameBoardController.blueHeroes = teamHeroes
            gameBoardController.modalPresentationStyle = .fullScreen
            gameBoardController.modalTransitionStyle = .crossDissolve
            
            // Create and present the red team's selection controller
            guard let pieceSelectionController = storyboard.instantiateViewController(withIdentifier: "PieceSelectionController")
                    as? PieceSelectionController else { return }
            
            pieceSelectionController.gameBoardController = gameBoardController
            pieceSelectionController.modalPresentationStyle = .fullScreen
            pieceSelectionController.modalTransitionStyle = .crossDissolve
            present(pieceSelectionController, animated: true, completion: nil)
        }
    }
    
    private func setupUI() {
        setTeamName()
        optionsClass.image = nil
        addSelectionSlots()
        setReady()
    }
    
    private func setTeamName() {
        teamName.text = gameBoardController == nil ? "BLUE TEAM" : "RED TEAM"
        let color: UIColor = gameBoardController == nil ? .teamBlue : .teamRed
        teamName.backgroundColor = color
        teamName.addShadow(radius: 10, offsetX: 1, offsetY: 1, color: color)
    }
    
    private func addSelectionSlots() {
        for i in 1 ... 6 {
            guard let selection = viewFrom(nibName: "PieceSelection") as? PieceSelection else { return }
            selection.heroName = nil
            
            switch i {
            case 1: selection.teamRole = .dps
            case 2: selection.teamRole = .healer
            case 3: selection.teamRole = .tank
            case 4: selection.teamRole = .tank
            case 5: selection.teamRole = .healer
            case 6: selection.teamRole = .dps
            default: fatalError()
            }
            
            selection.selectionAction = {
                selection.heroName = nil
                self.setReady()
                self.optionsClass.image = selection.classImage.image
                self.addOptionsFor(selection: selection)
            }
            
            pieceSelections.append(selection)
            selectionStack.addArrangedSubview(selection)
        }
    }
    
    private func addOptionsFor(selection: PieceSelection) {
        let availableHeroes = PieceService.heroNames(forTeamRole: selection.teamRole)
        
        // Removing the last list of options
        for view in self.optionsStack.arrangedSubviews {
            view.removeFromSuperview()
        }
        
        for hero in availableHeroes {
            // Create UI
            guard let optionView = viewFrom(nibName: "PieceOption") as? PieceOption else { return }
            
            // Format
            optionView.selectionBorder.roundCorners(radius: 7)
            optionView.portrait.roundCorners(radius: 4)
            optionView.selectionNameplate.roundCorners(radius: 5)
            optionView.heroName = hero
            optionView.deselect()
            
            let alreadySelected = pieceSelections.contains { $0.heroName == optionView.heroName }
            if alreadySelected { optionView.unavailable() }
            
            // Selection behavior
            optionView.selectOptionAction = {
                for optionView in self.pieceOptions {
                    optionView.deselect()
                }
                optionView.select()
                selection.heroName = optionView.heroName
                self.setReady()
            }
            
            optionView.heroInspectAction = {
                if let heroName = optionView.heroName {
                    let piece = PieceService.newHeroPiece(heroName)
                    let heroDetailVC = HeroDetailController(piece)
                    self.present(heroDetailVC, animated: false, completion: nil)
                }
            }
            
            self.pieceOptions.append(optionView)
            self.optionsStack.addArrangedSubview(optionView)
        }
    }
    
    private func setReady() {
        let notReady = pieceSelections.contains { $0.heroName == nil }
        
        if notReady {
            readyButton.addBorders(width: 3, color: .white)
            readyButton.backgroundColor = .secondaryLabel
            readyButton.isUserInteractionEnabled = false
        } else {
            readyButton.addBorders(width: 0, color: .clear)
            readyButton.backgroundColor = .systemYellow
            readyButton.isUserInteractionEnabled = true
        }
    }
}
