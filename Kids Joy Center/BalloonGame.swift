//
//  BalloonGame.swift
//  Kids Joy Center
//
//  Created by Matt Argao on 3/24/17.
//  Copyright © 2017 Matt Argao. All rights reserved.
//

import UIKit
import AVFoundation

class BalloonGame: UIViewController, UIPopoverPresentationControllerDelegate, ModalTransitionListener  {
    var difficulty = "Easy"
    var maxBalloons = 0
    var exitPoints = [CGPoint]()
    
    let mImage = UIImageView()
    let s1Image = UIImageView()
    let s2Image = UIImageView()
    var timer = Timer()
    var seconds = 0
    var score = 0
    var previousSecond:Int?
    var isBonus = false
    var bonusStart:Int?
    var counter = 0
    var lastTap = 0
    var activeBalloons = [balloon]()
    var spawnSet = [Int]()
    var updater = CADisplayLink()
    var cheerSoundEffect: AVAudioPlayer!
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        ModalTransitionMediator.instance.setListener(listener: self)
        view.subviews.forEach({ $0.removeFromSuperview() })
        seconds = 0
        score = 0
        previousSecond = nil
        isBonus = false
        bonusStart = nil
        counter = 0
        lastTap = 0
        activeBalloons = [balloon]()
        
        let bgImage = UIImageView(frame: screenSize)
        bgImage.contentMode = .scaleToFill
        bgImage.image = #imageLiteral(resourceName: "sky-background")
        bgImage.alpha = 1
        view.insertSubview(bgImage, at: 0)
        

        
        self.navigationItem.title = "Balloon game"
        
        if difficulty == "Easy" {
            maxBalloons = 1
            seconds = 60
            lastTap = seconds
        } else if difficulty == "Medium" {
            maxBalloons = 2
            seconds = 45
            lastTap = seconds
        } else {
            maxBalloons = 3
            seconds = 30
            lastTap = seconds
        }
        
        for i in 0..<10 {
            exitPoints.append(CGPoint(x: screenWidth/10*CGFloat(i), y: screenHeight))
        }
        
        buildTimerScore()
        
        
        updater = CADisplayLink(target: self, selector: #selector(self.gameLoop))
        updater.preferredFramesPerSecond = 60
        updater.add(to: RunLoop.current, forMode: RunLoopMode.commonModes)
        
    }
    
    func gameLoop() {
        
        //Easy speeds
        var speed = 3.0
        var bonusSpeed = 5.0
        var killerSpeed = 1.0
        var slowSpeed = 1.5
        
        if difficulty == "Medium" {
            speed = 4.5
            bonusSpeed = 6.5
            killerSpeed = 2.5
            slowSpeed = 3
        } else if difficulty == "Hard" {
            speed = 6
            bonusSpeed = 8
            killerSpeed = 4
            slowSpeed = 4.5
        }
        
        if previousSecond == nil {
            previousSecond = seconds
        } else {
            if previousSecond != seconds {
                
                // generate normal and affected balloons
                var numberToSpawn = rng(1)
                
                if difficulty == "Medium" {
                    numberToSpawn = rng(2)
                } else if difficulty == "Hard" {
                    numberToSpawn = rng(3)
                }
                
                
                var newBalloon: balloon?
                for i in 0..<numberToSpawn{
                    if isBonus == false {
                        newBalloon = generateBalloon("normal")
                        view.addSubview(newBalloon!.view)
                        
                    } else {
                        if let start = bonusStart {
                            let difference = start - seconds
                            if difference > 5 && isBonus == true {
                                isBonus = false
                                bonusStart = nil
                            }
                            newBalloon = generateBalloon("slow")
                            view.addSubview(newBalloon!.view)
                        }
                    }
                    
                    if spawnSet == [] || !spawnSet.contains(newBalloon!.exit) {
                        activeBalloons.append(newBalloon!)
                        spawnSet.append(newBalloon!.exit)
                    }

                }

                spawnSet = []
                
                // check for generating special or killer balloons
                if counter%5 == 0 {
                    let seed = rng(2)
                    
                    if seed == 1 {
                        let newKiller = generateBalloon("killer")
                        view.addSubview(newKiller.view)
                        activeBalloons.append(newKiller)
                    } else {
                        let newBonus = generateBalloon("bonus")
                        view.addSubview(newBonus.view)
                        activeBalloons.append(newBonus)
                    }
                    
                }
                
                previousSecond = seconds
                
            }
            
        }
        
        
        // increment active balloon position
        for i in activeBalloons {
            if i.status == "normal" {
                
            } else if i.status == "slow" {
                
            }
            
            let status = i.status
            
            switch status {
                case "normal":
                    i.view.frame = CGRect(x: exitPoints[i.exit-1].x, y: i.view.frame.minY-CGFloat(speed), width: 80, height: 80)
                case "slow":
                    i.view.frame = CGRect(x: exitPoints[i.exit-1].x, y: i.view.frame.minY-CGFloat(slowSpeed), width: 80, height: 80)
                case "killer":
                    i.view.frame = CGRect(x: exitPoints[i.exit-1].x, y: i.view.frame.minY-CGFloat(killerSpeed), width: 80, height: 80)
                case "bonus":
                    i.view.frame = CGRect(x: exitPoints[i.exit-1].x, y: i.view.frame.minY-CGFloat(bonusSpeed), width: 80, height: 80)
            default:
                break
            }

        }
        
        // remove views that reach the top
        for i in 0..<activeBalloons.count{
            if activeBalloons[i].view.frame.minY < 0 {
                activeBalloons[i].view.removeFromSuperview()
                activeBalloons.remove(at: i)
                break
            }
        }
        
        // check for last tap > 10 seconds
        if lastTap - seconds > 10 {
            print("took too long")
            timer.invalidate()
            
            updater.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
            
            let alertController = UIAlertController(title: "Missed balloons...", message: "You lose...Try again?", preferredStyle: .alert)
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                self.navigationController?.popToRootViewController(animated: true)})
            let actionRetry = UIAlertAction(title: "Retry", style: .default) { (action:UIAlertAction) in
                self.viewDidLoad()
            }
            
            alertController.addAction(actionCancel)
            alertController.addAction(actionRetry)
            self.present(alertController, animated:true, completion:nil)
        }
        
        updateScore()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func buildTimerScore() {
        mImage.contentMode = .scaleToFill
        s1Image.contentMode = .scaleToFill
        s2Image.contentMode = .scaleToFill
        
        timer = Timer.scheduledTimer(timeInterval: 1, target: self, selector: #selector(self.updateTimer), userInfo: nil, repeats: true)
        
        mImage.frame = CGRect(x: 5, y: 3, width: 25, height: 35)
        s1Image.frame = CGRect(x: CGFloat(15+27), y: 3, width: 25, height: 35)
        s2Image.frame = CGRect(x: CGFloat(15+25+27), y: 3, width: 25, height: 35)
        
        let timerText = UIImageView()
        timerText.image = #imageLiteral(resourceName: "time")
        timerText.frame = CGRect(x: 5, y: CGFloat(10+navigationBarHeight+statusbarHeight), width: 120, height: 41)
        
        let scoreText = UIImageView()
        scoreText.image = #imageLiteral(resourceName: "score")
        scoreText.frame = CGRect(x: screenWidth-70-150, y: CGFloat(10+navigationBarHeight+statusbarHeight), width: 120, height: 41)
        
        let timerContainer = UIView()
        let colon = UILabel()
        colon.text = ":"
        colon.font = colon.font.withSize(50)
        colon.sizeToFit()
        colon.frame = CGRect(x: 30, y: -2, width: 10, height: 35)
        
        timerContainer.frame = CGRect(x: 130, y: CGFloat(10+navigationBarHeight+statusbarHeight), width: 100, height: 41)
        timerContainer.backgroundColor = UIColor.white
        timerContainer.addSubview(mImage)
        timerContainer.addSubview(colon)
        timerContainer.addSubview(s1Image)
        timerContainer.addSubview(s2Image)
        
        view.addSubview(timerText)
        view.addSubview(timerContainer)
        view.addSubview(scoreText)
    }

    func updateScore() {
        
        let scoreContainer = UIView()
        let s1 = UIImageView()
        let s2 = UIImageView()
        let s3 = UIImageView()
        
        s1.image = UIImage(named: "cartoon-number-\(score/100).jpg")
        s2.image = UIImage(named: "cartoon-number-\(score%100/10).jpg")
        s3.image = UIImage(named: "cartoon-number-\(score%10).jpg")
        
        s1.frame = CGRect(x: 5, y: 3, width: 25, height: 35)
        s2.frame = CGRect(x: 30, y: 3, width: 25, height: 35)
        s3.frame = CGRect(x: 60, y: 3, width: 25, height: 35)
        scoreContainer.frame = CGRect(x: screenWidth-95, y: CGFloat(10+navigationBarHeight+statusbarHeight), width: 90, height: 41)
        scoreContainer.backgroundColor = UIColor.white
        scoreContainer.addSubview(s1)
        scoreContainer.addSubview(s2)
        scoreContainer.addSubview(s3)
        view.addSubview(scoreContainer)
    }
    
    
    func updateTimer() {
        let m = seconds/60
        let s = seconds%60
        let s1 = s/10
        let s2 = s%10
        
        mImage.image = UIImage(named: "cartoon-number-\(m).jpg")
        s1Image.image = UIImage(named: "cartoon-number-\(s1).jpg")
        s2Image.image = UIImage(named: "cartoon-number-\(s2).jpg")
        
        if seconds == 0 {
            print("Time's up")
            timer.invalidate()
            updater.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
            print("Final score: \(score)")
            finalScore = ["Balloon", difficulty, String(score)]
            showHighScore()
        } else {
            seconds -= 1
            counter += 1
        }

    }
    
    class balloon {
        var view: UIView
        var exit: Int
        var status: String
        
        init(_ view: UIView, _ exit: Int, _ status: String) {
            self.view = view
            self.exit = exit
            self.status = status
        }
        
    }
    
    func generateBalloon(_ status: String) -> balloon {
        let container = UIView()
        let b = UIImageView()
        
        b.image = UIImage(named: "color\(rng(10)).jpg")
        
        let exit = rng(10)
        
        container.frame = CGRect(origin: exitPoints[exit-1], size: CGSize(width: 80, height: 80))
        b.frame = CGRect(x: 0, y: 0, width: 80, height: 80)
        
        let graphic = UIImageView()
        graphic.frame = CGRect(x: 10, y: 10, width: 40, height: 40)
        
        let s = rng(10)
        
        if status == "normal" || status == "slow" {
            if s < 10 {
                graphic.image = UIImage(named: "cartoon-number-\(s)")
                container.addSubview(b)
                container.addSubview(graphic)
            } else {
                graphic.image = #imageLiteral(resourceName: "cartoon-number-1")
                let graphic2 = UIImageView()
                graphic2.image = #imageLiteral(resourceName: "cartoon-number-0")
                graphic2.frame = CGRect(x: 50, y: 10, width: 40, height: 40)
                container.addSubview(b)
                container.addSubview(graphic)
                container.addSubview(graphic2)
            }
            container.tag = s
        } else if status == "bonus" {
            graphic.image = #imageLiteral(resourceName: "star")
            container.tag = -1
            container.addSubview(b)
            container.addSubview(graphic)
        } else {
            graphic.image = #imageLiteral(resourceName: "skull")
            container.tag = -2
            container.addSubview(b)
            container.addSubview(graphic)
        }
        
        let singleTap = UITapGestureRecognizer(target: self, action: #selector(handleTap))
        singleTap.numberOfTapsRequired = 1
        container.addGestureRecognizer(singleTap)
        
        return balloon(container,exit,status)
    }
    
    func handleTap(sender: UITapGestureRecognizer) {
        if sender.view!.tag == -1 {
            print("bonus")
            isBonus = true
            bonusStart = seconds
        } else if sender.view!.tag == -2 {
            print("killer")
            timer.invalidate()
            updater.remove(from: RunLoop.current, forMode: RunLoopMode.commonModes)
            let alertController = UIAlertController(title: "Killer balloon!", message: "You lose...Try again?", preferredStyle: .alert)
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                self.navigationController?.popToRootViewController(animated: true)})
            let actionRetry = UIAlertAction(title: "Retry", style: .default) { (action:UIAlertAction) in
                self.viewDidLoad();
            }
            
            alertController.addAction(actionCancel)
            alertController.addAction(actionRetry)
            self.present(alertController, animated:true, completion:nil)
        } else {
            score += sender.view!.tag
        }
        lastTap = seconds
        sender.view!.isUserInteractionEnabled = false
        sender.view!.removeFromSuperview()
        print(score)
        
        let path = Bundle.main.path(forResource: "pop", ofType:"mp3")!
        let url = URL(fileURLWithPath: path)
        
        do {
            let sound = try AVAudioPlayer(contentsOf: url)
            cheerSoundEffect = sound
            
            sound.play()
        } catch {
            print("File not loaded.")
        }
    }

    func rng(_ max: Int) -> Int {
        let randomNum:UInt32 = arc4random_uniform(UInt32(max))+1
        return Int(randomNum)
    }

    func showHighScore() {
        fromRoot = false;
        
        let popVC = Highscore()
        popVC.popoverPresentationController?.delegate = self
        popVC.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        popVC.modalPresentationStyle = .overCurrentContext
        popVC.popoverPresentationController?.sourceView = view
        popVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        popVC.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        present(popVC, animated:true, completion:nil)
    }
    
    func popoverDismissed() {
        viewDidLoad()
    }
    
}
