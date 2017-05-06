//
//  ViewController.swift
//  Kids Joy Center
//
//  Created by Matt Argao on 3/24/17.
//  Copyright © 2017 Matt Argao. All rights reserved.
//

import UIKit


class ViewController: UIViewController, UIPopoverPresentationControllerDelegate, ModalTransitionListener {
    
    
    @IBOutlet weak var memoryButton: UIButton!
    @IBOutlet weak var sortingButton: UIButton!
    @IBOutlet weak var balloonButton: UIButton!
    @IBOutlet weak var easyButton: UIButton!
    @IBOutlet weak var mediumButton: UIButton!
    @IBOutlet weak var hardButton: UIButton!
    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var highscoresButton: UIBarButtonItem!
    
    var currentGame = ""
    var difficulty = ""
    
    override func viewDidLoad() {
        super.viewDidLoad()
        print("loaded")
        self.navigationItem.title = "Kids Joy Center"
        
        ModalTransitionMediator.instance.setListener(listener: self)
        
        currentGame = "MemoryGame"
        difficulty = "Easy"
        
        
        if UserDefaults.standard.array(forKey: "highscore") == nil {
            print("Registering default scores...")
            let defaultscore = [["N/A", "N/A", "0"],["N/A", "N/A", "0"],["N/A", "N/A", "0"],["N/A", "N/A", "0"],["N/A", "N/A", "0"]]
            UserDefaults.standard.set(defaultscore, forKey: "highscore")
        } else {
            print("Found previous scores.")
            print(UserDefaults.standard.array(forKey: "highscore")!)
        }
    
    }
    

    override func viewWillAppear(_ animated: Bool) {
        print("view appeared")
    }

    //required delegate func
    func popoverDismissed() {
        viewWillAppear(true)
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
   
    @IBAction func selectMemory(_ sender: Any) {
        currentGame = "MemoryGame"
        memoryButton.alpha = 1
        sortingButton.alpha = 0.5
        balloonButton.alpha = 0.5
    }

    @IBAction func selectSorting(_ sender: Any) {
        currentGame = "SortingGame"
        memoryButton.alpha = 0.5
        sortingButton.alpha = 1
        balloonButton.alpha = 0.5
    }

    @IBAction func selectBalloon(_ sender: Any) {
        currentGame = "BalloonGame"
        memoryButton.alpha = 0.5
        sortingButton.alpha = 0.5
        balloonButton.alpha = 1
    }
    
    @IBAction func selectEasy(_ sender: Any) {
        difficulty = "Easy"
        easyButton.alpha = 1
        mediumButton.alpha = 0.5
        hardButton.alpha = 0.5
    }
    
    @IBAction func selectMedium(_ sender: Any) {
        difficulty = "Medium"
        easyButton.alpha = 0.5
        mediumButton.alpha = 1
        hardButton.alpha = 0.5
    }
    
    @IBAction func selectHard(_ sender: Any) {
        difficulty = "Hard"
        easyButton.alpha = 0.5
        mediumButton.alpha = 0.5
        hardButton.alpha = 1
    }
    
    @IBAction func PlayGame(_ sender: Any) {
        performSegue(withIdentifier: currentGame, sender: self)
    }
    
    @IBAction func viewHighscores(_ sender: Any) {
        fromRoot = true;
        
        let popVC = Highscore()
        popVC.popoverPresentationController?.delegate = self
        popVC.preferredContentSize = CGSize(width: screenWidth, height: screenHeight)
        popVC.modalPresentationStyle = .overCurrentContext
        popVC.popoverPresentationController?.sourceView = view
        popVC.popoverPresentationController?.sourceRect = CGRect(x: 0, y: 0, width: 1, height: 1)
        popVC.popoverPresentationController?.permittedArrowDirections = .init(rawValue: 0)
        present(popVC, animated:true, completion:nil)

        
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if currentGame == "MemoryGame" {
            let destinationVC = segue.destination as! MemoryGame
            destinationVC.difficulty = difficulty
        } else if currentGame == "SortingGame" {
            let destinationVC = segue.destination as! SortingGame
            destinationVC.difficulty = difficulty
        } else {
            let destinationVC = segue.destination as! BalloonGame
            destinationVC.difficulty = difficulty
        }
    }
    
    func adaptivePresentationStyle(for controller: UIPresentationController) -> UIModalPresentationStyle { return .none }
}

