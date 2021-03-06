//
//  MinmaxViewController.swift
//  GameplayKitSandbox
//
//  Created by Tatsuya Tobioka on 2015/09/20.
//  Copyright © 2015年 tnantoka. All rights reserved.
//

import UIKit
import SpriteKit

class GameViewController: UIViewController {

    var scene: GameScene!

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        if let view = self.view as? SKView {
            let scene = GameScene(size: UIScreen.main.bounds.size)
            scene.scaleMode = .aspectFill
            //scene = GameScene(size: skView.frame.size)
            scene.didGameOver = { scene, message in
                let alertController = UIAlertController(title: "Game Over", message: message, preferredStyle: .alert)
                let action = UIAlertAction(title: "OK", style: .default) { action in
                    scene.reset()
                }
                alertController.addAction(action)
                self.present(alertController, animated: true, completion: nil)
            }
            view.presentScene(scene)
        }
       
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
