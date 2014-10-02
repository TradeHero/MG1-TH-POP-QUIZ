//
//  TestViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 10/2/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class TestViewController : UIViewController, UITableViewDataSource, UITableViewDelegate {
    
    let cellIdentifier = "cell"
    override func viewDidLoad() {
        super.viewDidLoad()
        self.title = "Hello"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
    }
    
    func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 1
    }
    
    func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return 100
        default:
            return 0
        }
    }
    
    func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        var cell = tableView.dequeueReusableCellWithIdentifier(cellIdentifier) as UITableViewCell?
        if cell == nil {
            cell = UITableViewCell(style: UITableViewCellStyle.Default, reuseIdentifier: cellIdentifier)
        }
        
        cell?.textLabel?.text = "Random \(arc4random() % 100)"
        
        return cell!
    }
    
    
}
