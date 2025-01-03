//
//  HeroDetailController.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/19/21.
//

import Foundation

class HeroDetailController: StandardController {
    let piece: Piece
    
    init(_ piece: Piece) {
        self.piece = piece
        
        super.init(style: .grouped)
        modalPresentationStyle = .overCurrentContext
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        container = HeroDetailContainer(piece)
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        tableView.backgroundColor = #colorLiteral(red: 0.1603380442, green: 0.1800295413, blue: 0.2242843509, alpha: 1)
    }
}

class HeroDetailContainer: Container {
    init(_ piece: Piece) {
        super.init()
        
        var blocks: [Block] = [BackButtonBlock(), TitleBlock(piece.name)]
        
        let stackBlock = StackBlock()
        if let movementVectorsBlock = AbilityDetailBlock.sectionHeader(text: "Movement") {
            stackBlock.views.append(movementVectorsBlock)
        }
        for vector in piece.movementVectors {
            if let vectorView = AbilityDetailBlock.view(for: vector) {
                vectorView.emblem.roundCorners()
                stackBlock.views.append(vectorView)
            }
        }
        blocks.append(stackBlock)
        
        for ability in piece.abilities {
            blocks.append(AbilityDetailBlock(ability))
        }
        
        sections = [ContainerSection(blocks: blocks)]
    }
}
