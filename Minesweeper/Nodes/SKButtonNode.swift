//
//  SKButtonNode.swift
//  Minesweeper
//
//  Created by Gustavo Chaves on 27/11/19.
//  Copyright © 2019 Gustavo Chaves. All rights reserved.
//

import Foundation
import SpriteKit


/// Class to create a custom button
class SKButtonNode: SKSpriteNode{
    var label: SKLabelNode!
    var action: (()->())?
    init(color: UIColor, size: CGSize, position: CGPoint, text: String, action: @escaping ()->()) {
        super.init(texture: nil, color: color, size: size)
        let label = setupLabel(message: text, position: position)
        label.zPosition = 1
        self.position = position
        addChild(label)
        isUserInteractionEnabled = true
        self.action = action
    }
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        action?()
    }
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    func setupLabel(message: String, position: CGPoint)->SKLabelNode{
        let label = SKLabelNode(text: message)
        label.fontColor = .black
        label.fontSize = 20
        label.fontName = "HelveticaNeue-Medium"
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
}
