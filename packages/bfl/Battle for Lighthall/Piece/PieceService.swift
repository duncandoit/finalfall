//
//  PieceService.swift
//  BoardGame
//
//  Created by Zachary Duncan on 3/17/21.
//

import UIKit

class PieceService {
    static func heroNames(forTeamRole teamRole: TeamRole) -> [HeroName] {
        var heroNames: [HeroName] = []
        
        switch teamRole {
        case .dps:
            heroNames = [.river, .kiri, .kredic]
        case .healer:
            heroNames = [.ana, .mercy]
        case .tank:
            heroNames = [.arryn, .melbrana, .elayis]
        case .deployable:
            heroNames = []
        }
        
        return heroNames
    }
    
    static func heroPortrait(for heroName: HeroName) -> UIImage {
        switch heroName {
        case .kiri: return #imageLiteral(resourceName: "Kiri Portrait")
        case .arryn: return #imageLiteral(resourceName: "Arryn Portrait")
        case .melbrana: return #imageLiteral(resourceName: "Melbrana Portrait")
        case .river: return #imageLiteral(resourceName: "River Portrait")
        default:
            return UIImage(named: heroName.rawValue + "_Idle_0")!
        }
    }
    
    static func newHeroPiece(_ heroName: HeroName) -> Piece {
        switch heroName {
        case .river: return River()
        case .kiri: return Kiri()
        case .kredic: return Kredic()
        case .ana: return Ana()
        case .mercy: return Mercy()
        case .arryn: return Arryn()
        case .melbrana: return Melbrana()
        case .elayis: return Elayis()
        }
    }
}

enum HeroName: String {
    // MARK: DPS
    case river = "River"
    case kiri = "Kiri"
    case kredic = "Kredic"
    
    // MARK: Healers
    case ana = "Ana"
    case mercy = "Mercy"
    
    // MARK: Tanks
    case arryn = "Arryn"
    case melbrana = "Melbrana"
    case elayis = "Elayis"
}
