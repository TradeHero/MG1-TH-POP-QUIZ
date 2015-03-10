//
//  DevViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 4/3/15.
//  Copyright (c) 2015 TradeHero. All rights reserved.
//

import UIKit

class DevViewController: UIViewController {

    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    


    @IBAction func quizDisplayAction(sender: UIButton) {
        NetworkClient.sharedClient.fetchStaticQuestions({
            debugPrintln("\($0.localizedDescription)")
        }) {
            questionSet in
            let controller = UIStoryboard.devStoryboard().instantiateViewControllerWithIdentifier("QuizDebugViewController") as? QuizDebugViewController
            controller?.bindQuestionSet(questionSet)
            self.presentViewController(controller!, animated: true, completion: nil)
        }
    }

    @IBAction func imageQuizDisplayAction(sender: UIButton) {
        NetworkClient.sharedClient.fetchImageQuestions({
            debugPrintln("\($0.localizedDescription)")
            }) {
                questionSet in
                let controller = UIStoryboard.devStoryboard().instantiateViewControllerWithIdentifier("QuizDebugViewController") as? QuizDebugViewController
                var count = 0
                var partialCompletionHandler: ()->() = {
                    count++
                    println(count)
                    if(count == questionSet.count){
                        controller?.bindQuestionSet(questionSet)
                        self.presentViewController(controller!, animated: true, completion: nil)
                    }
                }
                
                for var i = 0; i<questionSet.count; i++  {
                    var q = questionSet[i]
                    q.fetchImage{
                        partialCompletionHandler()
                    }
                }
                
                
                
                
        }
    }

    
    @IBAction func APItest(sender: AnyObject) {
        NetworkClient.sharedClient.fetchGame(180, force: false, errorHandler: {error in}, completionHandler: {game in
            debugPrintln(game)
        })
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
