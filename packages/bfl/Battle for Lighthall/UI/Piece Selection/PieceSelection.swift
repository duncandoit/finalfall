//
//  PieceSelection.swift
//  BoardGame
//
//  Created by Zachary Duncan on 3/17/21.
//

import UIKit

class PieceSelection: UIView {
    @IBOutlet weak var backview: UIImageView!
    @IBOutlet weak var portrait: UIImageView!
    @IBOutlet weak var classImage: UIImageView!
    var selectionAction: (()->Void)?
    
    override init(frame: CGRect) {
        super.init(frame: frame)
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    @IBAction func requestSelection(_ sender: Any) {
        selectionAction?()
    }
    
    var teamRole: TeamRole = .dps {
        didSet {
            switch teamRole {
            case .dps:
                classImage.image = .dps
            case .healer:
                classImage.image = .healer
            case .tank:
                classImage.image = .tank
            case .deployable:
                classImage.image = #imageLiteral(resourceName: "deployTarget_2")
            }
        }
    }
    
    var heroName: HeroName? {
        didSet {
            if let heroName = heroName {
                backview.alpha = 1
                portrait.image = PieceService.heroPortrait(for: heroName)
                backview.backgroundColor = .systemYellow
                backview.image = #imageLiteral(resourceName: "White gradient")
            } else {
                portrait.image = nil
                backview.alpha = 0.5
                backview.backgroundColor = .clear
                backview.image = #imageLiteral(resourceName: "Black gradient")
            }
        }
    }
}
