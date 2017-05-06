//
//  Highscore.swift
//  Kids Joy Center
//
//  Created by Matt Argao on 3/26/17.
//  Copyright © 2017 Matt Argao. All rights reserved.
//

import UIKit

var fromRoot: Bool?

class Highscore: UIViewController {
    
    
    let container = UIView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        view.isOpaque = false
        
        
        container.frame = CGRect(x: screenWidth/2-310, y: screenHeight/2-225, width: 620, height: 450)
        container.backgroundColor = UIColor.white
        
        if fromRoot == false {
            checkNewHighScore()
        }
        let highscoreArray = UserDefaults.standard.array(forKey: "highscore") as! [[String]]
        
        var gameArray = [String]()
        var difficultyArray = [String]()
        var scoreArray = [String]()
        
        for i in highscoreArray {
            gameArray.append(i[0])
            difficultyArray.append(i[1])
            scoreArray.append(i[2])
        }
        
        buildColumn(0, "Rank", ["1", "2", "3", "4", "5"])
        buildColumn(1, "Game", gameArray)
        buildColumn(2, "Difficulty", difficultyArray)
        buildColumn(3, "Score", scoreArray)

        let containerWidth = 620
        let containerHeight = 450
        

        
        if fromRoot == false {
            let tryLabel = UILabel(frame: CGRect(x: containerWidth-180-100, y: containerHeight-55, width: 80, height: 40))
            tryLabel.text = "Try again?"
            tryLabel.textAlignment = .center
            container.addSubview(tryLabel)
            let cancelButton = UIButton(frame: CGRect(x: containerWidth-100-80, y: containerHeight - 55, width: 80, height: 35))
            cancelButton.backgroundColor = UIColor.red
            cancelButton.setTitle("No..", for: .normal)
            cancelButton.addTarget(self, action: #selector(cancelAction), for: .touchUpInside)
            
            container.addSubview(cancelButton)
            
            let confirmButton = UIButton(frame: CGRect(x: containerWidth-10-80, y: containerHeight - 55, width: 80, height: 35))
            confirmButton.backgroundColor = UIColor.green
            confirmButton.setTitle("Yes!", for: .normal)
            confirmButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
            
            container.addSubview(cancelButton)
            container.addSubview(confirmButton)
        } else {
            let closeButton = UIButton(frame: CGRect(x: containerWidth-10-80, y: containerHeight - 55, width: 80, height: 35))
            closeButton.backgroundColor = UIColor.lightGray
            closeButton.setTitle("Close", for: .normal)
            closeButton.addTarget(self, action: #selector(confirmAction), for: .touchUpInside)
            container.addSubview(closeButton)
        }

        
        self.view.backgroundColor = UIColor.black.withAlphaComponent(0.8)
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func checkNewHighScore() {
        var highscoreArray = UserDefaults.standard.array(forKey: "highscore") as! [[String]]
        
        var index:Int?
        
        for i in 0..<5 {
            print("comparing \(highscoreArray[i][2]) and \(finalScore[2])")
            if Int(highscoreArray[i][2])! < Int(finalScore[2])! {
                index = i
                break;
            }
        }
        
        if index != nil {
            highscoreArray.insert(finalScore, at: index!)
            if highscoreArray.count > 5 {
                highscoreArray.remove(at: 5)
            }
            UserDefaults.standard.set(highscoreArray, forKey: "highscore")
            print("Inserted new highscore.")
        }

    }
    
    func confirmAction(sender: UIButton!) {
        print("Confirm")
        ModalTransitionMediator.instance.sendPopoverDismissed(modelChanged: true)
        dismiss(animated: true, completion: nil)
    }
    
    func cancelAction(sender: UIButton!) {
        print("Cancel")
        let navigationController = self.presentingViewController as? UINavigationController
        self.dismiss(animated: true) {
            let _ = navigationController?.popToRootViewController(animated: true)
        }
    }
    
    func buildColumn(_ columnID: Int, _ attribute: String,_ values: [String]) {
        
        
        var position = CGRect(x: 10+columnID*150, y: 10, width: 150, height: 66)
        let attributeLabel = UILabel(frame: position)
        attributeLabel.text = attribute
        attributeLabel.textAlignment = .center
        container.addSubview(attributeLabel)
        
        for i in 1..<6 {
            position = CGRect(x: 10+columnID*150, y: 66*i, width: 150, height: 66)
            let valueLabel = UILabel(frame: position)
            valueLabel.text = values[i-1]
            valueLabel.textAlignment = .center
            
            container.addSubview(valueLabel)
        }
        
        view.addSubview(container)
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        // Get the new view controller using segue.destinationViewController.
        // Pass the selected object to the new view controller.
    }
    */

}
