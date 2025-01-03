//
//  PieceOption.swift
//  BoardGame
//
//  Created by Zachary Duncan on 3/17/21.
//

import UIKit

class PieceOption: UIView {
    @IBOutlet weak var selectionBorder: UIView!
    @IBOutlet weak var portrait: UIImageView!
    @IBOutlet weak var selectionNameplate: UIView!
    @IBOutlet weak var name: UILabel!
    @IBOutlet weak var heroInspectButton: UIButton!
    
    var selectOptionAction: (()->Void)?
    var heroInspectAction: (()->Void)?
    
    @IBAction func selectOption(_ sender: Any) {
        selectOptionAction?()
    }
    
    @IBAction func heroInspect(_ sender: Any) {
        heroInspectAction?()
    }
    
    func select() {
        selectionBorder.backgroundColor = .white
        selectionBorder.addShadow(radius: 8, color: .systemYellow)
        selectionNameplate.alpha = 1
        heroInspectButton.alpha = 1
        portrait.backgroundColor = .systemYellow
    }
    
    func deselect() {
        selectionBorder.backgroundColor = .clear
        selectionBorder.addShadow(radius: 0, color: .clear)
        selectionNameplate.alpha = 0
        heroInspectButton.alpha = 0
        portrait.backgroundColor = .darkGray
    }
    
    func unavailable() {
        alpha = 0.5
        isUserInteractionEnabled = false
    }
    
    var heroName: HeroName? {
        didSet {
            guard let heroName = heroName else { return }
            portrait.image = PieceService.heroPortrait(for: heroName)
            name.text = heroName.rawValue
        }
    }
}
