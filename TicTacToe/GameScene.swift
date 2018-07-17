//
//  MinmaxScene.swift
//  GameplayKitSandbox
//
//  Created by Tatsuya Tobioka on 2015/09/22.
//  Copyright © 2015年 tnantoka. All rights reserved.
//

import UIKit

import SpriteKit
import GameplayKit

class GameScene: SKScene {

    let level: Int = 3
    let cellImage: Bool = true
    var boardWidth: CGFloat!
    var cellSize: CGFloat = 60.0
    let margin: CGFloat = 2.0

    var board: Board!
    var cells: [SKSpriteNode]!
    var strategist: GKMinmaxStrategist!

    var didGameOver: ((GameScene, String) -> Void)?
    var center: CGPoint {
        return CGPoint(x: frame.midX, y: frame.midY)
    }
    var boardNode: SKSpriteNode!
    var informationLabel: SKLabelNode!
    var gamePieceNodes = [SKNode]()
    
    // MARK: - Scene Loading
    
    override func didMove(to view: SKView) {
        super.didMove(to: view)
        
        anchorPoint = CGPoint(x: 0.5, y: 0.5)
        
        let backgroundNode = SKSpriteNode(imageNamed: "wood-bg")
        addChild(backgroundNode)
        
        boardWidth = view.frame.width - 24
        let borderHeight = ((view.frame.height - boardWidth) / 2) - 24
        /*
        boardNode = SKSpriteNode(
            texture: SKTexture(imageNamed: "board"),
            size: CGSize(width: boardWidth, height: boardWidth)
        )
        boardNode.position.y = -(view.frame.height / 2) + ((view.frame.height - borderHeight) / 2)
        addChild(boardNode)
        */
        let headerNode = SKSpriteNode(
            color: UIColor(red: 46/255, green: 46/255, blue: 46/255, alpha: 1),
            size: CGSize(width: view.frame.width, height: borderHeight)
        )
        headerNode.alpha = 0.65
        headerNode.position.y = (view.frame.height / 2) - (borderHeight / 2)
        addChild(headerNode)
        
        informationLabel = SKLabelNode(fontNamed: "HandDrawnShapes")
        informationLabel.fontSize = UIDevice.current.userInterfaceIdiom == .pad ? 63 : 40
        informationLabel.fontColor = .white
        informationLabel.position = headerNode.position
        informationLabel.verticalAlignmentMode = .center
        addChild(informationLabel)
        
        createSceneContents()
    }
    //
    func createSceneContents() {
        board = Board(level: level)
        board.debug = true

        // strategist
        strategist = GKMinmaxStrategist()
        strategist.gameModel = board
        strategist.maxLookAheadDepth = board.level * 2 - 1
   
        cellSize = boardWidth / CGFloat(level) - margin * (CGFloat(level) - 1)
        //NSLog(String(cellSize))
        
        let spriteSize = CGSize(
            width: cellSize,
            height: cellSize
        )
        
        let step = cellSize + margin
        
        // add cells on board
        cells = [SKSpriteNode]()
        let base = CGFloat(board.level - 1) * 0.5
        let baseX = center.x - step * base
        let baseY = center.y - step * base
        
        for i in 0..<board.cells.count {
            let cell = SKSpriteNode(color: backgroundColor,
                                    size: spriteSize)
            let x = baseX + floor(CGFloat(i) / CGFloat(board.level)) * step
            let y = baseY + CGFloat(i % board.level) * step
            cell.position = CGPoint(x: x, y: y)
            
            addChild(cell)
            cells.append(cell)
        }
        //updateBoard()
        updateHeader()
    }
    
    func addLabelNode(_ i: Int, cell: Mark) {
        let label = SKLabelNode(text: cell.text())
        label.fontName = "Chalkduster"
        label.fontSize = 70.0
        label.fontColor = SKColor.white
        label.verticalAlignmentMode = .center
        cells[i].addChild(label)
    }
    
    func addSpriteNode(_ i: Int, cell: Mark) {
        if cell == .none { return }
        
        let sizeValue = cellSize - 2
        let spriteSize = CGSize(
            width: sizeValue,
            height: sizeValue
        )
        
        let pieceNode = SKSpriteNode(imageNamed: cell.name())
        pieceNode.size = CGSize(
            width: spriteSize.width,
            height: spriteSize.height
        )
        //pieceNode.position = position(for: CGPoint(x: x, y: y))
        //addChild(pieceNode)
        cells[i].addChild(pieceNode)
        
        //pieceNode.run(SKAction.scale(by: 2, duration: 0.25))
    }
    
    func updateHeader() {
        informationLabel.text = "\(board.currentPlayer.mark.name())'s Turn"
    }
    
    func updateBoard() {
        for (i, cell) in board.cells.enumerated() {
            cells[i].removeAllChildren()
            if cellImage {
                addSpriteNode(i, cell: cell)
            }
            else {
                addLabelNode(i, cell: cell)
            }
           
        }
        updateHeader()
        if board.isGameOver() {
            let message: String
            if board.isWin(for: Player.oPlayer()) {
                message = "\(Player.oPlayer().mark.name()) Win"
            } else if board.isWin(for: Player.xPlayer()) {
                message = "\(Player.xPlayer().mark.name()) Win"
            } else {
                message = "Draw"
            }
            if let didGameOver = didGameOver {
                didGameOver(self, message)
            }
        }
    }

    func reset() {
        //removeAllChildren()
        let actions = [
            SKAction.scale(to: 0, duration: 0.25),
            SKAction.customAction(withDuration: 0.5, actionBlock: { node, duration in
                node.removeFromParent()
            })
        ]
        cells.forEach { node in
            node.run(SKAction.sequence(actions))
        }
        cells.removeAll()
        
        createSceneContents()
    }

    override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
        guard let touch = touches.first else { return }
        let location = touch.location(in: self)
        if let node = atPoint(location) as? SKSpriteNode {
            if let index = cells.index(of: node) {
                // update cell on board and switch opponent player
                board.updateCell(index)
                updateBoard()
                if let move = strategist.bestMove(for: board.currentPlayer) as? Move {
                    board.apply(move)
                    updateBoard()
                }
            }
            
            // use GKRandomDistribution
            /**
             * A random distribution is a random source itself with a specific mapping from the input source to the output values.
             * The distribution is uniform, meaning there is no bias towards any of the possible outcomes.
             */
            /*
             let index = GKRandomDistribution(lowestValue: 0, highestValue: board.cells.count - 1).nextInt()
             board.updateCell(index)
             for _ in 0..<board.cells.count - 1 {
             if let move = strategist.bestMove(for: board.currentPlayer) as? Move {
             board.apply(move)
             }
             updateBoard()
             }
             */
        }
    }
}
