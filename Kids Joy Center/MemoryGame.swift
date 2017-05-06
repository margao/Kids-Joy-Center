//
//  MemoryGame.swift
//  Kids Joy Center
//
//  Created by Matt Argao on 3/24/17.
//  Copyright © 2017 Matt Argao. All rights reserved.
//

import UIKit
import AVFoundation

let screenSize = UIScreen.main.bounds
let screenWidth = screenSize.width
let screenHeight = screenSize.height
let statusbarHeight = 20
let navigationBarHeight = 44
var finalScore = [String]()

class MemoryGame: UIViewController, UIPopoverPresentationControllerDelegate, ModalTransitionListener   {
    var cheerSoundEffect: AVAudioPlayer!
    var difficulty = ""
    var imageViews = [#imageLiteral(resourceName: "1"),#imageLiteral(resourceName: "2"), #imageLiteral(resourceName: "3"),#imageLiteral(resourceName: "4"),#imageLiteral(resourceName: "5"),#imageLiteral(resourceName: "6"),#imageLiteral(resourceName: "7"),#imageLiteral(resourceName: "8"),#imageLiteral(resourceName: "9"),#imageLiteral(resourceName: "10")]
    var cardIDarray = [[card]]()
    var numRows = 0
    var firstFlip = false
    var firstFlipcard:card? = nil
    var firstView:UIView? = nil
    var seconds = 0
    let mImage = UIImageView()
    let s1Image = UIImageView()
    let s2Image = UIImageView()
    var timer = Timer()
    var score = 0
    var lastFoundTime:Int? = nil
    
    class card {
        var ID:Int
        var isFlipped = false
        init(_ cardID: Int) {
            ID = cardID
        }
        
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews.forEach({ $0.removeFromSuperview() })
        ModalTransitionMediator.instance.setListener(listener: self)
        
        firstFlip = false
        firstFlipcard = nil
        firstView = nil
        score = 0
        lastFoundTime = nil
        
        let bgImage = UIImageView(frame: screenSize);
        bgImage.image = #imageLiteral(resourceName: "background")
        bgImage.contentMode = .scaleToFill
        bgImage.alpha = 1
        
        self.navigationItem.title = "Memory Game"
        
        if difficulty == "Easy" {
            seconds = 120
        } else if difficulty == "Medium" {
            seconds = 105
        } else {
            seconds = 90
        }
        
        self.view.insertSubview(bgImage, at: 0)
        
        shuffleImages()
        randomizeGrid()
        buildGrid()
        updateScore()
        
        
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
        scoreText.frame = CGRect(x: screenWidth-70-120, y: CGFloat(10+navigationBarHeight+statusbarHeight), width: 120, height: 41)
        
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
    
    //required delegate func
    func popoverDismissed() {
        viewDidLoad()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
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
            let alertController = UIAlertController(title: "Time's up!", message: "You lose...Try again?", preferredStyle: .alert)
            
            let actionCancel = UIAlertAction(title: "Cancel", style: .default, handler: { action in
                self.navigationController?.popToRootViewController(animated: true)})
            let actionRetry = UIAlertAction(title: "Retry", style: .default) { (action:UIAlertAction) in
                self.viewDidLoad();
            }
            
            alertController.addAction(actionCancel)
            alertController.addAction(actionRetry)
            self.present(alertController, animated:true, completion:nil)
        }
        seconds -= 1
    }
    
    func updateScore() {
        
        let scoreContainer = UIView()
        let s1 = UIImageView()
        let s2 = UIImageView()
        
        s1.image = UIImage(named: "cartoon-number-\(score/10).jpg")
        s2.image = UIImage(named: "cartoon-number-\(score%10).jpg")
        
        s1.frame = CGRect(x: 5, y: 3, width: 25, height: 35)
        s2.frame = CGRect(x: 30, y: 3, width: 25, height: 35)
        
        scoreContainer.frame = CGRect(x: screenWidth-65, y: CGFloat(10+navigationBarHeight+statusbarHeight), width: 60, height: 41)
        scoreContainer.backgroundColor = UIColor.white
        scoreContainer.addSubview(s1)
        scoreContainer.addSubview(s2)
        
        view.addSubview(scoreContainer)
    }
    
    func shuffleImages() {
        for i in 0..<imageViews.count {
            let j = Int(arc4random_uniform(UInt32(imageViews.count-1-i))) + i
            if i != j {
                swap(&imageViews[i], &imageViews[j])
            }
        }
    }
    
    func flip(sender: UITapGestureRecognizer) {
        
        let tag = sender.view?.tag
        let row = tag!/4
        let column = tag! - row*4
        var currentCard = cardIDarray[row][column]
        
        if currentCard.isFlipped == false {
        
            UIView.transition(from: (sender.view?.subviews[0])!, to: (sender.view?.subviews[1])!, duration: 0.65, options: [.transitionFlipFromRight, .showHideTransitionViews], completion: nil)
            
            if firstFlip == false {
                firstFlip = true
                firstFlipcard = currentCard
                currentCard.isFlipped = true
                firstView = sender.view
            } else {
                
                if firstFlipcard?.ID == currentCard.ID && currentCard.isFlipped == false {
                    print("Matched!")
                    
                    let path = Bundle.main.path(forResource: "cheer", ofType:"mp3")!
                    let url = URL(fileURLWithPath: path)
                    
                    do {
                        let sound = try AVAudioPlayer(contentsOf: url)
                        cheerSoundEffect = sound
                        
                        sound.play()
                    } catch {
                        print("File not loaded.")
                    }

                    
                    firstFlip = false
                    firstFlipcard = nil
                    firstFlipcard?.isFlipped = true
                    currentCard.isFlipped = true
                    
                    if lastFoundTime == nil {
                        lastFoundTime = seconds
                    } else {
                        let difference = lastFoundTime! - seconds
                        if difference < 3 {
                            score += 5
                        } else if (difference > 3 && difference <= 7) {
                            score += 4
                        } else {
                            score += 3
                        }
                    }
                    updateScore()
                    
                    // Check if finished
                    var finished = false
                    
                    outerLoop: for row in cardIDarray {
                        for element in row {
                            if element.isFlipped == false {
                                finished = false
                                break outerLoop
                            } else {
                                finished = true
                            }
                        }
                    }
                    
                    if finished {
                        timer.invalidate()
                        print("Well done!")
                        finalScore = ["Memory", difficulty, String(score)]
                        showHighScore()
                        
                    }
                    
                } else {
                    print("Try again!")
                    firstFlip = false
                    firstFlipcard?.isFlipped = false
                    firstFlipcard = nil
                    currentCard.isFlipped = false
                    firstFlipcard?.isFlipped = false

                    view.subviews.forEach({ $0.isUserInteractionEnabled = false })
                    
                    DispatchQueue.main.asyncAfter(deadline: .now() + .seconds(1), execute: {
                        UIView.transition(from: (sender.view?.subviews[1])!, to: (sender.view?.subviews[0])!, duration: 0.4, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
                        UIView.transition(from: (self.firstView!.subviews[1]), to: (self.firstView!.subviews[0]), duration: 0.4, options: [.transitionFlipFromLeft, .showHideTransitionViews], completion: nil)
                        
                        self.view.subviews.forEach({ $0.isUserInteractionEnabled = true })
                    })
                    
                    
                
                }
                
            }
        }
       

        
        
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
    
    func randomizeGrid() {
        var set = [Int]()
        
        if difficulty == "Easy" {
            set = [0,0,1,1,2,2,3,3,4,4,5,5]
            cardIDarray = [ [], [], [] ]
        } else if difficulty == "Medium" {
            set = [0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7]
            cardIDarray = [ [], [], [], [] ]
        } else {
            set = [0,0,1,1,2,2,3,3,4,4,5,5,6,6,7,7,8,8,9,9]
            cardIDarray = [ [], [], [], [], [] ]
        }
        
        var randomNum:UInt32
        numRows = cardIDarray.count
            
        for j in 0..<numRows {
            for _ in 0..<4 {
                randomNum = arc4random_uniform(UInt32(set.count))
                cardIDarray[j].append(card(set[Int(randomNum)]))
                set.remove(at: Int(randomNum))
            }
        }
    }
    
    func buildGrid() {
        var tag = 0
        
        
        for j in 0..<numRows {
            for i in 0..<cardIDarray[j].count {
                let back = UIImageView(image: #imageLiteral(resourceName: "question"))
                let front = UIImageView(image: imageViews[cardIDarray[j][i].ID])
                
                let xPosition = CGFloat((Int(screenWidth)/2 - (cardIDarray[j].count*120)/2) + i*120)
                let offsetPosition = ((Int(screenHeight)-navigationBarHeight - statusbarHeight)/2 - (numRows*120)/2 + j*120)
                let yPosition = CGFloat(navigationBarHeight + statusbarHeight + offsetPosition)
                
                let frame = CGRect(x: xPosition,
                                   y: yPosition,
                                   width: 120,
                                   height: 120)
            
                front.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
                back.frame = CGRect(x: 0, y: 0, width: 120, height: 120)
            
                let containerView = UIView()
                containerView.frame = frame
            
                containerView.addSubview(back)
                containerView.addSubview(front)
            
                front.isHidden = true
            
                view.addSubview(containerView)
            
                let singleTap = UITapGestureRecognizer(target: self, action: #selector(flip))
                singleTap.numberOfTapsRequired = 1
                containerView.addGestureRecognizer(singleTap)
            
                containerView.tag = tag
                tag += 1
            }
        }
    }

}
