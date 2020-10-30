//
//  TileType.swift
//  Minesweeper
//
//  Created by Gustavo Chaves on 26/11/19.
//  Copyright © 2019 Gustavo Chaves. All rights reserved.
//

import Foundation


/// The Type of the tile

enum TileType{
    case empty
    case mine
    case number
    
    var value: String{
        switch self {
            case .mine:
                return "*"
            default:
                return ""
        }
    }
}
