//
//  GameViewController.swift
//  Minesweeper
//
//  Created by Gustavo Chaves on 26/11/19.
//  Copyright © 2019 Gustavo Chaves. All rights reserved.
//

import UIKit
import SpriteKit
import GameplayKit


/// Class that controls the view, setup the navigation and the scene
class GameViewController: UIViewController {

    var skView: SKView!
    var navBar: UINavigationBar!
    var showButton: UIBarButtonItem!
    var resizeButton: UIBarButtonItem!
    var scene: GameScene!
    
    var boardSize = BoardSize(sizeX: 10, sizeY: 13)
    
    
    /// Setup navigation and scene
    override func viewDidLoad() {
        super.viewDidLoad()
        setupNavigationBar()
        setupSKView()
  
        // Load the SKScene from 'GameScene.sks'
        scene = GameScene(action: restartGame, boardSize: boardSize)
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .resizeFill

        // Present the scene
        skView.presentScene(scene)
    }
    
    
    /// Setup the navigation title and bar buttons and constraints
    func setupNavigationBar(){
        navBar = UINavigationBar()
        navBar.delegate = self
        navBar.isTranslucent = false
        navBar.barTintColor = UIColor(named: "CustomGreen")
        view.addSubview(navBar)
        
        navBar.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            navBar.topAnchor.constraint(equalTo: view.safeAreaLayoutGuide.topAnchor),
            navBar.leftAnchor.constraint(equalTo: view.leftAnchor),
            navBar.rightAnchor.constraint(equalTo: view.rightAnchor),
            navBar.heightAnchor.constraint(equalToConstant: 44)])
        
        
        let label = UILabel()
        let localizedTitle = NSLocalizedString("Minesweeper", comment: "")

        label.text = localizedTitle
        label.textAlignment = .left
        label.textColor = UIColor.black
        let navigationItem = UINavigationItem()
        navigationItem.leftBarButtonItem = UIBarButtonItem(customView: label)
        
        showButton = UIBarButtonItem(image: UIImage(named: "visibilityIcon"), style: .plain, target: scene, action: #selector(showTileValues))
        
        let restartGameButton = UIBarButtonItem(image: UIImage(named: "replayIcon"), style: .plain, target: scene, action: #selector(restartGame))
        resizeButton = UIBarButtonItem(image: UIImage(named: "mineSizeIcon"), style: .plain, target: scene, action: #selector(resizeMinesweeperAction))
        navigationItem.rightBarButtonItems = [restartGameButton, showButton, resizeButton]
        navigationItem.rightBarButtonItems?.forEach { $0.tintColor = .black }
        navBar.setItems([navigationItem], animated: false)
    }
    
    
    /// Action of show all values of the board
    @objc func showTileValues(){
        if scene.showMinesweeperValues(){
            if showButton.image == UIImage(named: "visibilityIcon"){
                showButton?.image = UIImage(named: "visibilityOffIcon")
            }
            else{
                showButton?.image = UIImage(named: "visibilityIcon")
            }
        }
    }
    
    
    /// Restart the game by reseting the scene
    @objc func restartGame(){
        showButton?.image = UIImage(named: "visibilityIcon")
        scene = GameScene(action: restartGame, boardSize: boardSize)
        // Set the scale mode to scale to fit the window
        scene.scaleMode = .resizeFill
        
        // Present the scene
        skView.presentScene(scene)
    }

    
    /// Resize the board and restart the scene
    @objc func resizeMinesweeperAction(){
        let localizedTitle = NSLocalizedString("Select the field size:", comment: "")
        let alert = UIAlertController(title: localizedTitle, message: "", preferredStyle: .alert)
        
        let boardSizes = [BoardSize(sizeX: 25, sizeY: 30),
                          BoardSize(sizeX: 15, sizeY: 20),
                          BoardSize(sizeX: 10, sizeY: 15),
                          BoardSize(sizeX: 5, sizeY: 10)]
             
        boardSizes.forEach { fieldSize in
            let actionTitle = "\(fieldSize.sizeX)x\(fieldSize.sizeY)"
            let sizeAction = UIAlertAction(title: actionTitle, style: .default, handler: { _ in
                self.resizeMinesweeper(to: fieldSize)
                self.dismiss(animated: true, completion: nil)
            })
            alert.addAction(sizeAction)
        }
        let localizedCancelTitle = NSLocalizedString("Cancel", comment: "")
        let cancelAction = UIAlertAction(title: localizedCancelTitle, style: .cancel, handler: nil)
        alert.addAction(cancelAction)
        present(alert, animated: true, completion: nil)
    }
    
    /// Resize the board
    /// - Parameter size: Desired size of the board
    func resizeMinesweeper(to size: BoardSize){
        boardSize = size
        restartGame()
    }
    
    
    /// Setup the view and constraints
    func setupSKView(){
        skView = SKView(frame: view.frame)
        view.addSubview(skView)
        skView.translatesAutoresizingMaskIntoConstraints = false
        NSLayoutConstraint.activate([
            skView.topAnchor.constraint(equalTo: navBar.bottomAnchor),
            skView.leftAnchor.constraint(equalTo: view.leftAnchor),
            skView.rightAnchor.constraint(equalTo: view.rightAnchor),
            skView.bottomAnchor.constraint(equalTo: view.bottomAnchor)])
    }
}

extension GameViewController: UINavigationBarDelegate{
    func position(for bar: UIBarPositioning) -> UIBarPosition {
        return .topAttached
    }
}
