//
//  Tile.swift
//  Minesweeper
//
//  Created by Gustavo Chaves on 26/11/19.
//  Copyright © 2019 Gustavo Chaves. All rights reserved.
//

import Foundation
import SpriteKit

/// The node that contains a background, a label and a cover to hide the tile value
class TileNode: SKSpriteNode{
    
    var tileType: TileType = .empty
    var number: Int = 0
    var label: SKLabelNode!
    var coverNode: SKSpriteNode!
    let onClick: ((TileType, Position) -> Void)
    let positionInArray: Position
    
    /// The init of the TileNode, it setup the node
    /// - Parameter size: Size of the node
    /// - Parameter position: position in worldspace
    /// - Parameter positionInArray: position at GameScene array storage
    /// - Parameter onClick: Action to be executed by GameScene when this TileNode is clicked
    init(size: CGFloat, position: CGPoint,  positionInArray: Position, onClick: @escaping ((TileType, Position) -> Void)){
        self.onClick = onClick
        self.positionInArray = positionInArray
        super.init(texture: nil, color: UIColor.lightGray, size: CGSize(width: size, height: size))
        self.anchorPoint = CGPoint(x: 0, y: 1)
        self.position = position
        self.isUserInteractionEnabled = true
        setupCoverNode(size: size)
        setupLabel()
    }
    
    /// Force Show value of the node by arrange the cover behind (zPosition = -1) or ahead (zPosition = 1) of the background
    func forceShow(){
        coverNode.zPosition *= -1;
    }
    
    required init?(coder aDecoder: NSCoder){
        fatalError("init(coder:) has not been implemented")
    }
    
    /// Override of touchesEnded, when zPosition = -1 means that the node is forced to show, so doenst accept any interaction, when showValue return true, it calls the OnClick
    override func touchesEnded(_ touches: Set<UITouch>, with event: UIEvent?) {
        if coverNode.zPosition == -1{
            return
        }
        if showValue(){
            onClick(tileType, positionInArray)
        }
        
    }
    
    /// Setup of the cover
    /// - Parameter size: The tile size
    func setupCoverNode(size: CGFloat){
        coverNode = SKSpriteNode(texture: nil, color: UIColor.gray, size: CGSize(width: size, height: size))
        coverNode.anchorPoint = CGPoint(x: 0.5, y: 0.5)
        coverNode.position = CGPoint(x: self.size.width/2, y: -self.size.height/2)
        coverNode.zPosition = 1;
        addChild(coverNode)
    }
    
    /// Show the value of the node by removing the cover, true if the value was hidden, false if not
    func showValue()->Bool{
        if coverNode.parent == self {
            coverNode.removeFromParent()
            return true
        }
        return false
    }
    
    /// Hide the value by adding the cover to the node
    func hideValue(){
        addChild(coverNode)
    }
    
    /// Setup of the label to store the node value
    func setupLabel(){
        label = SKLabelNode(text: "")
        label.fontColor = .black
        label.fontSize = 20
        label.fontName = "HelveticaNeue-Medium"
        label.position = CGPoint(x: size.width/2, y: -size.height/2)
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        addChild(label)
    }
    
    /// Set the tile type of the node, once the tile type is mine, it cant be set again
    /// - Parameter tileType: Tiletype
    func set(tileType: TileType)-> Bool{
        if self.tileType == .mine{
            return false
        }
        self.tileType = tileType
        setLabel(text: tileType.value)
        return true
    }
    
    /// Set the label text and color based on its value
    /// - Parameter text: Tesxto to show
    func setLabel(text: String){
        label.text = text
        var color = UIColor.black
        if tileType == .number{
            color = UIColor(hue: 1 / CGFloat(number), saturation: 0.7, brightness: 1, alpha: 1)
        }
        
        label.fontColor = color
    }
    
    /// Increase the value if it is a number or empty
    func increaseNumber(){
        if(self.tileType == .mine){
            return
        }
        tileType = .number
        number += 1
        setLabel(text: number.description)
    }
}
