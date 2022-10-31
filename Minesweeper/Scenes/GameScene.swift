//
//  GameScene.swift
//  Minesweeper
//
//  Created by Gustavo Chaves on 26/11/19.
//  Copyright © 2019 Gustavo Chaves. All rights reserved.
//

import SpriteKit
import GameplayKit


/// Class to setup the minesweeper board, bombs and numbers, it control the game end state, win or lose.
class GameScene: SKScene {
    
    var tileSize: CGFloat!
    let margingSpace = 40
    let spaceBetweenTiles = 3
    var tilesArray: [[TileNode]] = []
    var mineCount = 15
    var mineSizeX = 10
    var mineSizeY = 13
    
    var restartGame: (()->())?
    
    var firstTouch = true
    var gameEnded = false
    
    var firstPosition = Position(x: 0, y: 0)
    
    
    /// Setup the board size and the action when the game ends
    /// - Parameter action: Action called when game ends
    /// - Parameter boardSize: Board size
    init(action: @escaping ()->(), boardSize: BoardSize) {
        super.init(size: .zero)
        mineSizeX = boardSize.sizeX
        mineSizeY = boardSize.sizeY
        restartGame = action
    }
    
    required init?(coder aDecoder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    /// Count the tiles shown, if it is enough to win the game, end the game.
    var tileShowCount = 0{
        didSet{
            if tileShowCount >= (mineSizeX * mineSizeY) - mineCount{
                let localizedText = NSLocalizedString("You win", comment: "")
                showEndGameStatus(message: localizedText)
            }
        }
    }
    
    
    /// Create the board when the scene is shown
    /// - Parameter view: The SKView that presents this scene
    override func didMove(to view: SKView) {
        createBoard(sizeX: mineSizeX, sizeY: mineSizeY)
    }
    
    /// Setup the color and anchor point when the scene is loaded
    override func sceneDidLoad() {
        backgroundColor = UIColor(named: "BackgroundColor")!
        self.anchorPoint = CGPoint(x: 0, y: 1)
    }
    
    
    /// Create the board
    /// - Parameter sizeX: Size horizontal of the board
    /// - Parameter sizeY: Size vertical of the board
    func createBoard(sizeX: Int, sizeY: Int){
        tileSize = tileSize(numberOfTiles: sizeX)
        for i in 0..<sizeX {
            tilesArray.append([])
            for j in 0..<sizeY {
                let position = CGPoint(x: (tileSize + CGFloat(spaceBetweenTiles)) * CGFloat(i) + CGFloat(margingSpace), y: -((tileSize + CGFloat(spaceBetweenTiles)) * CGFloat(j) + CGFloat(margingSpace)))
                let tile = createTile(at: position, with: tileSize, positonInArray: Position(x: i, y: j))
                tilesArray[i].append(tile)
                self.addChild(tile)
            }
        }
    }
    
    
    /// Create the tile node that composes the board
    /// - Parameter position: position in world space
    /// - Parameter size: size of the tile
    /// - Parameter positonInArray: position in GameScene array, to fast access
    func createTile(at position: CGPoint, with size: CGFloat, positonInArray: Position)->TileNode{
        let tile = TileNode(size: size, position: position, positionInArray: positonInArray, onClick: onClick(tileType:position:) )
        return tile
    }
    
    
    /// Calculates the size of the tile based on the size of the screen and the spacing between each other
    /// - Parameter numberOfTiles: Number of the tiles of the board
    func tileSize(numberOfTiles: Int)->CGFloat{
        let screenSize = view?.frame.width
        let marging = (2 * margingSpace) + ((numberOfTiles - 1) * spaceBetweenTiles)
        return  (screenSize! - CGFloat(marging))/CGFloat(numberOfTiles)
    }
    
    
    /// Put the mines and number around they
    /// - Parameter toAvoid: Position of the user first interaction to avoid, preventing the suddenly end game
    func generateMineSweeper(position toAvoid: Position){
        var position = Position(x: 0, y: 0)
        var mineCountPut = 0
        while mineCountPut < mineCount {
            position.x = Int.random(in: 0..<mineSizeX)
            position.y = Int.random(in: 0..<mineSizeY)
            if  !(toAvoid.x-1...toAvoid.x+1).contains(position.x) &&  !(toAvoid.y-1...toAvoid.y+1).contains(position.y){
                if putMine(at: position){
                    mineCountPut += 1
                }
            }
        }
    }
    
    
    /// Put mine at position
    /// - Parameter position: Desired position to put a mine
    func putMine(at position: Position)-> Bool{
        if tilesArray[position.x][position.y].set(tileType: .mine){
            checkNeighbor(position: position, completition: setNeighborNumber(position:))
            return true
        }
        else{
            return false
        }
    }
    
    
    /// Set the number around the mine
    /// - Parameter position: Desired Psotion
    func setNeighborNumber(position: Position){
        tilesArray[position.x][position.y].increaseNumber()
    }
    
    
    /// Deafult loop to check the neighborhood of the desired position
    /// - Parameter position: Desired position
    /// - Parameter completition: Action to be executed when a position is valid
    func checkNeighbor(position: Position, completition: (Position) -> ()){
        for i in position.x-1...position.x+1 {
            for j in position.y-1...position.y+1 {
                if isValidPosition(position: Position(x: i, y: j)){
                    completition(Position(x: i, y: j))
                }
            }
        }
    }
    
    
    /// Show the value of the node, if it is a empty space, shows the neighborhood too
    /// - Parameter position: Desired position
    func showValue(position: Position){
        let tile = tilesArray[position.x][position.y]
        
        if(tile.tileType == .number){
            if tile.showValue(){
                tileShowCount += 1
            }
            return
        }
        else if tile.tileType == .empty{
            if tile.showValue(){
                tileShowCount += 1
                checkNeighbor(position: position, completition: showValue(position:))
            }
        }

    }
    
    
    /// Called when a tile was clicked
    /// - Parameter tileType: Type of the tile
    /// - Parameter position: position of the tile
    func onClick(tileType: TileType, position: Position){
         
        if firstTouch{
            firstTouch = false
            generateMineSweeper(position: position)
        }
        
        switch tileType {
            case .mine:
                let localizedText = NSLocalizedString("You lose", comment: "")
                showEndGameStatus(message: localizedText)
            case .empty:
                tileShowCount += 1
                checkNeighbor(position: position, completition: showValue(position:))
            default:
                tileShowCount += 1
                return
        }
    }
    
    /// Show all tile values
    @discardableResult
    func showMinesweeperValues()->Bool{
        if firstTouch || gameEnded{
            return false
        }
        tilesArray.forEach({$0.forEach({$0.forceShow()})})
        return true
    }
    
    
    /// Check if a position is valid
    /// - Parameter position: Desired position
    func isValidPosition(position: Position)->Bool{
        return (0..<mineSizeX).contains(position.x) && (0..<mineSizeY).contains(position.y)
    }
    
    
    /// Show End game message and button
    /// - Parameter message: Message to be shown to the player
    func showEndGameStatus(message: String){
        showMinesweeperValues()
        gameEnded = true
        let boardSize = CGFloat(mineSizeY) * (CGFloat(spaceBetweenTiles) + tileSize)
        let positionY = -(CGFloat(2 * margingSpace) + (boardSize))
        var position = CGPoint(x: view!.bounds.midX, y: positionY)
        let label = setupLabel(message: message, position: position)
        addChild(label)
        
        position.y -= 75
        let localizedText = NSLocalizedString("Try again", comment: "")
        let button = setupButton(message: localizedText, position: position)
        addChild(button)
    }
    
    
    /// Setup the message label
    /// - Parameter message: Message to be shown
    /// - Parameter position: Desired position of the label
    func setupLabel(message: String, position: CGPoint)->SKLabelNode{
        let label = SKLabelNode(text: message)
        label.fontColor = .black
        label.fontSize = 20
        label.fontName = "HelveticaNeue-Medium"
        label.position = position
        label.verticalAlignmentMode = .center
        label.horizontalAlignmentMode = .center
        return label
    }
    
    /// Setup the button of try again
    /// - Parameter message: Message of the button
    /// - Parameter position: Desired position of the button
    func setupButton(message: String, position: CGPoint)->SKSpriteNode{
        let button = SKButtonNode(color: UIColor(named: "CustomGreen")!, size: CGSize(width: 200, height: 60), position: position, text: message, action: restartGame!)
        return button
    }
    
    
}
