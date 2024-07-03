//
//  StandardController.swift
//  Battle for Lighthall
//
//  Created by Zachary Duncan on 4/19/21.
//

import Foundation

class StandardController: ContainerController {
    override func viewDidLoad() {
        super.viewDidLoad()
        
        tableView.showsVerticalScrollIndicator = false
        tableView.bounces = false
    }
    
    override var prefersStatusBarHidden: Bool {
        return true
    }
    
    override var prefersHomeIndicatorAutoHidden: Bool {
        return true
    }
}
