//
//  GameScene.swift
//  Solo Mission
//
//  Created by Virginia Wong on 3/7/19.
//  Copyright © 2019 Virginia Wong. All rights reserved.
//

import SpriteKit
import GameplayKit

// Where user plays the game
class GameScene: SKScene {
   
   // let - never changes
   // Make player spaceship global variable, acessible to all methods
   let player = SKSpriteNode(imageNamed: "playerShip")
   
   // Make bullet sound global so we don't get lag whenever we use it
   // wait: false - to let sound play while its moving
   // wait: true  - sound plays entirely before running next sequence of actions
   let bulletSound = SKAction.playSoundFileNamed("bulletSound.mp3",
                                                 waitForCompletion: false)
   
   // Generates random float
   func random() -> CGFloat {
      return CGFloat(Float(arc4random()) / 0xFFFFFFFF)
   }
   // Returns a random CGFloat between a minimum & maximum range
   func random(min: CGFloat, max: CGFloat) -> CGFloat {
      return random() * (max - min) + min
   }
   
   
   // Declare CGRect
   // (To make a game area - a scene selection where all Nodes are enclosed in)
   let gameArea: CGRect
   
   //-------------------------------------------------------------------------
   // Set up game area
   //-------------------------------------------------------------------------
   
   // Scene initializer - sets up the scene
   override init(size: CGSize) {
      
      // Set width of game scene - how wide of an area can we see on every device
      let maxAspectRatio: CGFloat = 16.0/9.0
      let playableWidth = size.height / maxAspectRatio
      let margin = (size.width - playableWidth) / 2
      
      // Set up game area - a CGRect rectangle
      gameArea = CGRect(x: margin, y: 0, width: playableWidth, height: size.height)

      // Must be included for this init() method
      super.init(size: size)
      
   }
   
   required init?(coder aDecoder: NSCoder) {
      fatalError("init(coder:) has not been implemented")
   }
   
   
   //-------------------------------------------------------------------------
   // Set up player scene straight away when user opens app
   // This function will run as soon as the scene loads up
   //-------------------------------------------------------------------------
   override func didMove(to view: SKView) {
      
      //-------------------------------------------------------------------------
      // Create background
      //-------------------------------------------------------------------------
      
      // SKSpriteNode is an image object(e.g. player spaceship) on the screen
      let background = SKSpriteNode(imageNamed: "background")
      // self is this scene (window we play on)
      // Want background to match size of this scene
      background.size = self.size
      // position is placed on center of the image
      // Put our background on the center (x,y) of our scene
      background.position = CGPoint(x: self.size.width/2, y: self.size.height/2 )
      // zPosition "layers" objects; lower # = further back on screen
      // Here we put background in the back layer of our game images
      background.zPosition = 0;
      // Make background on self
      self.addChild(background);
      
      //-------------------------------------------------------------------------
      // Create ship for player to control
      //-------------------------------------------------------------------------
      
      // Set spaceship to original image size (=1);
      // if want bigger, make >1 ;; smaller <1 ;; 0 = barely noticable
      player.setScale(1)
      // Spawn image @ mid-width of screen, lower bottom
      player.position = CGPoint(x: self.size.width/2, y: self.size.height * 0.2)
      // Put spaceship above background (2)
      // (and above bullet (1), which is underneath the spaceship)
      player.zPosition = 2;
      self.addChild(player)
      
      //-------------------------------------------------------------------------
      // Start level - spawn enemies
      //-------------------------------------------------------------------------
      
      startNewLevel()
      
   }
   
   //-------------------------------------------------------------------------
   // Make enemies only appear every once in a while
   //-------------------------------------------------------------------------

   func startNewLevel() {
      
      // Spawn enemy
      let spawn = SKAction.run(spawnEnemy)
      // How long is it going to wait to spawn new enemy? - 1 sex
      let waitToSpawn = SKAction.wait(forDuration: 1)
      let spawnSequence = SKAction.sequence([spawn, waitToSpawn])
      let spawnForever = SKAction.repeatForever(spawnSequence)
      
      // Run the action on this scene
      self.run(spawnForever)
      
   }
   
   //-------------------------------------------------------------------------
   // Make spaceship fire bullets
   //-------------------------------------------------------------------------
   
   func fireBullet() {
      
      // Make SpriteNode
      let bullet = SKSpriteNode(imageNamed: "bullet")
      bullet.setScale(1)
      bullet.position = player.position // Bullet spawns where player ship is
      bullet.zPosition = 1
      self.addChild(bullet)
      
      // Make bullet move off top of the screen in 1 sec
      let moveBullet = SKAction.moveTo(y: self.size.height +
                                          bullet.size.height, duration: 1)
      // Delete SpriteNode
      // To prevent bullets building up on top of screen (creating a lag time)
      let deleteBullet = SKAction.removeFromParent()
      
      // Use sequence to make our bullet move and delete itself
      // Sequence: list of actions that will run in order
      let bulletSequence =  SKAction.sequence([bulletSound,
                                               moveBullet,
                                               deleteBullet])
      bullet.run(bulletSequence)
      
   }
   
   //-------------------------------------------------------------------------
   // Make enemies that move randomly from off top to below the screen
   //-------------------------------------------------------------------------
   
   func spawnEnemy() {
      
      // Generate random x-coord
      let randomXStart = random(min: gameArea.minX, max: gameArea.maxX)
      let randomXEnd = random(min: gameArea.minX, max: gameArea.maxX)
      
      // 1.2 = 20% above top of screen; starts out of scene
      let startPoint = CGPoint(x: randomXStart, y: self.size.height * 1.2)
      // 20% of the height
      let endPoint = CGPoint(x: randomXEnd, y: -self.size.height * 0.2 )
      
      // Spawn enemy off the top of the screen
      let enemy = SKSpriteNode(imageNamed: "enemyShip")
      enemy.setScale(0.35)
      enemy.position = startPoint
      enemy.zPosition = 2
      self.addChild(enemy)
      
      // Movie enemy diagonally to bottom of the screen
      let moveEnemy = SKAction.move(to: endPoint, duration: 1.5)
      let deleteEnemy = SKAction.removeFromParent()
      let enemySequence = SKAction.sequence([moveEnemy, deleteEnemy])
      enemy.run(enemySequence)
      
      // Rotate the enemy ship
      let dx = endPoint.x - startPoint.x
      let dy = endPoint.y - startPoint.y
      let amountToRotate = atan2(dy, dx)
      enemy.zRotation = amountToRotate    // Do base rotation
      
   }

   
   //-------------------------------------------------------------------------
   // When we PRESS on the screen(w.touchpad)
   // -- Make spaceship fire a bullet (per PRESS)
   //-------------------------------------------------------------------------
   override func touchesBegan(_ touches: Set<UITouch>, with event: UIEvent?) {
      
      fireBullet()
      
   }
   
   //-------------------------------------------------------------------------
   // Make spaceship move (only) LEFT & RIGHT when we drag finger on screen
   // -- Will run whenever we move finger around the screen
   //-------------------------------------------------------------------------
   override func touchesMoved(_ touches: Set<UITouch>, with event: UIEvent?) {
      
      // Find current location finger is tounching screen
      // touch: info about touch on screen
      for touch: AnyObject in touches{
         
         // 1 - What's the location we are touching in this scene?
         // pointOfTouch is where we are CURRENTLY touching in this scene
         let pointOfTouch = touch.location(in: self)
         
         // 2 - Find previous location finger is touching the screen
         let previousPointOfTouch = touch.previousLocation(in: self)
         
         // 3 - Find distance we moved finger in one direction (L or R)
         let amountDragged = pointOfTouch.x - previousPointOfTouch.x
         
         // 4 - Change player spaceship position
         // Move spaceship in the same distance finger dragged
         player.position.x += amountDragged
         
         //-------------------------------------------------------------------------
         // Lock player ship in the game area
         // --- Reminder: squeeze in player ship's width on screen
         //-------------------------------------------------------------------------
         
         // IF player spaceship is TOO FAR RIGHT
         if player.position.x > gameArea.maxX - player.size.width/2 {
            player.position.x = gameArea.maxX - player.size.width/2
         }
         // IF player spaceship is TOO FAR LEFT
         if player.position.x < gameArea.minX + player.size.width/2 {
            player.position.x = gameArea.minX + player.size.width/2
         }
         
      }
   }
}
