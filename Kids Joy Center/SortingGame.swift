//
//  SortingGame.swift
//  Kids Joy Center
//
//  Created by Matt Argao on 3/24/17.
//  Copyright © 2017 Matt Argao. All rights reserved.
//

import UIKit
import AVFoundation

class SortingGame: UIViewController, UIPopoverPresentationControllerDelegate, ModalTransitionListener   {
    var cheerSoundEffect: AVAudioPlayer!
    var difficulty = ""
    var seconds = 0
    var images = [item(UIImage(named: "1-1.jpg")!, "air"),
                  item(UIImage(named: "1-2.jpg")!, "air"),
                  item(UIImage(named: "1-3.jpg")!, "air"),
                  item(UIImage(named: "1-4.jpg")!, "air"),
                  item(UIImage(named: "1-5.jpg")!, "air"),
                  item(UIImage(named: "2-1.jpg")!, "water"),
                  item(UIImage(named: "2-2.jpg")!, "water"),
                  item(UIImage(named: "2-3.jpg")!, "water"),
                  item(UIImage(named: "2-4.jpg")!, "water"),
                  item(UIImage(named: "2-5.jpg")!, "water"),
                  item(UIImage(named: "3-1.jpg")!, "ground"),
                  item(UIImage(named: "3-2.jpg")!, "ground"),
                  item(UIImage(named: "3-3.jpg")!, "ground"),
                  item(UIImage(named: "3-4.jpg")!, "ground"),
                  item(UIImage(named: "3-5.jpg")!, "ground")]
    
    class item {
        var image: UIImage
        var type:String
        init(_ a: UIImage, _ b: String) {
            image = a
            type = b
        }
    }
    
    var imageViews = [UIImageView]()
    
    var originalPoint = [CGRect]()
    var numVehicles = 8
    
    let groundHitbox1 = UIView()
    let groundHitbox2 = UIView()
    let waterHitbox1 = UIView()
    let waterHitbox2 = UIView()
    let airHitbox = UIView()
    
    var timer = Timer()
    let mImage = UIImageView()
    let s1Image = UIImageView()
    let s2Image = UIImageView()
    var counter = 0
    var score = 0
    var lastFoundTime:Int? = nil
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.subviews.forEach({ $0.removeFromSuperview() })
        imageViews = [UIImageView]()
        
        counter = 0
        score = 0
        lastFoundTime = nil
        
        ModalTransitionMediator.instance.setListener(listener: self)
        let bgImage = UIImageView(frame: screenSize)
        bgImage.image = #imageLiteral(resourceName: "air-land-water")
        bgImage.contentMode = .scaleToFill
        bgImage.alpha = 1
        
        self.navigationItem.title = "Sorting Game"
        
        if difficulty == "Easy" {
            seconds = 60
            numVehicles = 8
        } else if difficulty == "Medium" {
            seconds = 45
            numVehicles = 10
        } else {
            seconds = 30
            numVehicles = 12
        }
        
        self.view.insertSubview(bgImage, at: 0)
        
        shuffleImages()
        buildGrid()
        buildHitbox()
        buildTimerScore()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func shuffleImages() {
        for i in 0..<images.count {
            let j = Int(arc4random_uniform(UInt32(images.count-1-i))) + i
            if i != j {
                swap(&images[i], &images[j])
            }
        }
    }
    
    func buildHitbox() {

//        groundHitbox1.backgroundColor = UIColor.red.withAlphaComponent(0.5)
//        groundHitbox2.backgroundColor = UIColor.red.withAlphaComponent(0.5)
        groundHitbox1.frame = CGRect(x: screenWidth-300, y: screenHeight*0.55, width: 300, height: screenHeight/2)
        groundHitbox2.frame = CGRect(x: screenWidth/2-50, y: screenHeight-screenHeight*0.23,
                                     width: screenWidth-(screenWidth-groundHitbox1.frame.minX)-(screenWidth/2-50),
                                     height: screenHeight/2)
        
        view.insertSubview(groundHitbox1, at: 3)
        view.insertSubview(groundHitbox2, at: 4)
        
//        waterHitbox1.backgroundColor = UIColor.green.withAlphaComponent(0.5)
//        waterHitbox2.backgroundColor = UIColor.green.withAlphaComponent(0.5)
        waterHitbox1.frame = CGRect(x: 0, y: screenHeight*0.55,
                                    width: screenWidth-(screenWidth-groundHitbox1.frame.minX),
                                    height: screenHeight-(screenHeight*0.55)-(screenHeight-groundHitbox2.frame.minY))
        waterHitbox2.frame = CGRect(x: 0, y: waterHitbox1.frame.maxY,
                                    width: screenWidth-300-(screenWidth-(screenWidth-groundHitbox1.frame.minX)-(screenWidth/2-50)),
                                    height: screenHeight)
        
        view.insertSubview(waterHitbox1, at: 2)
        view.insertSubview(waterHitbox2, at: 2)
//        airHitbox.backgroundColor = UIColor.yellow.withAlphaComponent(0.5)
        airHitbox.frame = CGRect(x: 0, y: 200, width: screenWidth, height: screenHeight-200-(0.45*screenHeight))
        
        view.insertSubview(airHitbox, at: 1)
        
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
    
    func buildGrid() {
        var tag = 0
        
        for i in 0..<numVehicles {
            let vehicle = UIImageView(image: images[i].image)
            
            let frame = CGRect(x:screenWidth/CGFloat(numVehicles)*CGFloat(i), y: 110, width: 80, height: 80)
            vehicle.frame = frame
            let dragGesture = UIPanGestureRecognizer(target: self, action: #selector(dragAction))
            vehicle.addGestureRecognizer(dragGesture)
            vehicle.isUserInteractionEnabled = true
            originalPoint.append(frame)
            vehicle.tag = tag
            tag += 1
            imageViews.append(vehicle)
        }

        for i in imageViews {
            view.addSubview(i)
        }
    }
    
    func calcDistance(_ a: CGPoint, _ b: CGPoint) -> CGFloat {
        let xDist = a.x - b.x
        let yDist = a.y - b.y
        return CGFloat(sqrt((xDist*xDist) + (yDist*yDist)))
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
    
    
    func dragAction(sender: UIPanGestureRecognizer) {
        
        let tag = sender.view!.tag
        
        if sender.state == .began || sender.state == .changed {
            let translation = sender.translation(in: self.view)

            sender.view!.frame = CGRect(x: sender.view!.frame.minX + translation.x, y: sender.view!.frame.minY + translation.y, width: 120, height: 120)
            sender.setTranslation(CGPoint.zero, in: self.view)
        }
        
        if sender.state == .ended {
            let currentPoint = sender.view!.center
            let originalPoint = self.originalPoint[tag]
            let distance = calcDistance(currentPoint, CGPoint(x: originalPoint.minX, y: originalPoint.minY))
            let animationDuration = distance/500
            
            if (groundHitbox1.frame.contains(currentPoint) && images[tag].type == "ground") ||
                (groundHitbox2.frame.contains(currentPoint) && images[tag].type == "ground") ||
                (waterHitbox1.frame.contains(currentPoint) && images[tag].type == "water") ||
                (waterHitbox2.frame.contains(currentPoint) && images[tag].type == "water") ||
                (airHitbox.frame.contains(currentPoint) && images[tag].type == "air") {
                
                imageViews[tag].isUserInteractionEnabled = false
                
                if lastFoundTime == nil {
                    lastFoundTime = seconds
                    counter += 1
                } else {
                    let difference = lastFoundTime! - seconds
                    if difference < 2 {
                        score += 5
                        counter += 1
                    } else if (difference > 2 && difference <= 4) {
                        self.score += 4
                        counter += 1
                    } else {
                        score += 3
                        counter += 1
                    }
                    updateScore()
                    print(counter)
                    print(numVehicles)
                    
                    let path = Bundle.main.path(forResource: "cheer", ofType:"mp3")!
                    let url = URL(fileURLWithPath: path)
                    
                    do {
                        let sound = try AVAudioPlayer(contentsOf: url)
                        cheerSoundEffect = sound
                        
                        sound.play()
                    } catch {
                        print("File not loaded.")
                    }
                    
                    //Check if finished
                    if counter == numVehicles {
                        timer.invalidate()
                        print("Well done!")
                        finalScore = ["Sorting", difficulty, String(score)]
                        showHighScore()
                    }
                }
            
            } else {
                UIView.animate(withDuration: Double(animationDuration), animations: {
                    sender.view!.frame = self.originalPoint[tag]
                })
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
    
    func popoverDismissed() {
        viewDidLoad()
    }
    
}
