//
//  TZScenery.swift
//  Treviz
//
//  Created by Tyler Anderson on 7/11/21.
//  Copyright © 2021 Tyler Anderson. All rights reserved.
//

import Foundation

import SpriteKit

/**
 TZScenery contains all the drawing code for static scene backgrounds
 */
class TZScenery {
    let starCount = 70
    let maxStarSize: CGFloat = 40.0
    var sunSize: CGFloat = 80.0
    var scene: TZScene!
    var backgroundStars = [SKSpriteNode]()
    var groundSprite: SKSpriteNode!
    var sunSprite: SKSpriteNode!
    var moonSprite: SKSpriteNode!
    var isNight: Bool?
    
    init(scene sceneIn: TZScene) {
        scene = sceneIn
        var istar = 0
        while istar < starCount {
            let newStar = SKSpriteNode(imageNamed: "star")
            newStar.alpha = 0.8
            newStar.name = "BackgroundStar\(istar)"
            newStar.zPosition = 0.5
            backgroundStars.append(newStar)
            istar += 1
        }
        groundSprite = SKSpriteNode(color: .green, size: CGSize(width: scene.size.width, height: scene.screenMargin))
        groundSprite.anchorPoint = .zero
        groundSprite.zPosition = 0.9
        scene.addChild(groundSprite)
        
        sunSprite = SKSpriteNode(imageNamed: "Sol_viz")
        sunSprite.scale(to: CGSize(width: sunSize, height: sunSize))
        sunSprite.zPosition = 0.9
        
        moonSprite = SKSpriteNode(imageNamed: "Luna_viz")
        moonSprite.scale(to: CGSize(width: sunSize, height: sunSize))
        moonSprite.zPosition = 0.9
    }
    
    func resize(){
        backgroundStars.forEach {
            let xpos = CGFloat.random(in: 0.0...scene.size.width)
            let ypos = CGFloat.random(in: scene.screenMargin...scene.size.height)
            let starsize = CGFloat.random(in: 0.0...maxStarSize)
            $0.position = CGPoint(x: xpos, y: ypos)
            $0.size = CGSize(width: starsize, height: starsize)
        }
        groundSprite.position = CGPoint(x: 0, y: 0)
        groundSprite.size = CGSize(width: scene.size.width, height: scene.screenMargin)
        
        sunSprite.position = CGPoint(x: scene.size.width-sunSize, y: scene.size.height-sunSize)
        moonSprite.position = CGPoint(x: sunSize, y: scene.size.height-sunSize)
    }
    
    /**
     Called when the system changes between dark mode and light mode. Changes the type of background between day and night
     */
    func changeMode(darkMode: Bool){
        if darkMode == isNight {
            return // Do nothing if the desired state is already matched
        } else if darkMode {
            scene.backgroundColor = .blue.blended(withFraction: 0.95, of: .black)!.withAlphaComponent(0.9)
            backgroundStars.forEach({scene.addChild($0)})
            sunSprite.removeFromParent()
            scene.addChild(moonSprite)
            groundSprite.color = .green.blended(withFraction: 0.6, of: .black)!
        } else {
            scene.backgroundColor = NSColor(deviceRed: 0.75, green: 0.9, blue: 0.97, alpha: 0.9)
            backgroundStars.forEach({$0.removeFromParent()})
            moonSprite.removeFromParent()
            scene.addChild(sunSprite)
            groundSprite.color = .green.blended(withFraction: 0.3, of: .black)!
        }
        isNight = darkMode
    }
}

