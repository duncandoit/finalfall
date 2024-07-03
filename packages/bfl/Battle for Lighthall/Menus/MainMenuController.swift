//
//  MainMenuController.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/16/21.
//

import UIKit

class MainMenuController: UIViewController {
    @IBOutlet weak var tableView: UITableView!
    let container = MainMenuContainer()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.dataSource = container
        tableView.delegate = container
        tableView.backgroundColor = .clear
    }
}

class MainMenuContainer: Container {
    override init(in state: State = .view) {
        super.init(in: state)
        
        let block = ButtonBlock(label: "Dang ol' block, man")
        sections = [ContainerSection(blocks: [block])]
    }
}
