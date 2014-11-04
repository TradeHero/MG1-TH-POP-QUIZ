//
//  MusicChooserTableViewController.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 4/11/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit
import ExSwift

class MusicChooserTableViewController: UITableViewController, MusicChooserTableViewCellDelegate {
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.navigationController?.setNavigationTintColor(barColor: UIColor(hex: 0xFF4069))
        self.navigationController?.navigationBar.titleTextAttributes = [NSFontAttributeName : UIFont(name: "AvenirNext-Medium", size: 18)!, NSForegroundColorAttributeName : UIColor.whiteColor(), NSBackgroundColorAttributeName : UIColor.whiteColor()]
        
        self.tableView.registerNib(UINib(nibName: "MusicChooserTableViewCell", bundle: nil), forCellReuseIdentifier: kTHMusicChooserTableViewCellIdentifier)
        self.tableView.rowHeight = UITableViewAutomaticDimension
        self.tableView.estimatedRowHeight = 70
        self.navigationController?.navigationBar.translucent = false
        self.loadMusics()
        self.tableView.tableFooterView = UIView(frame: CGRectZero)
        self.tableView.tableFooterView?.hidden = true
    }
    
    private func loadMusics(){
        
        self.tableView.reloadData()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    // MARK: - Table view data source

    override func numberOfSectionsInTableView(tableView: UITableView) -> Int {
        return 2
    }

    override func tableView(tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        switch section {
        case 0:
            return orchestralMusic.count
        case 1:
            return pianoMusic.count
        default:
            return 0
        }
    }

    override func tableView(tableView: UITableView, titleForHeaderInSection section: Int) -> String? {
        switch section {
        case 0:
            return "Orchestral"
        case 1:
            return "Piano"
        default:
            return nil
        }
    }
    
    override func tableView(tableView: UITableView, cellForRowAtIndexPath indexPath: NSIndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCellWithIdentifier(kTHMusicChooserTableViewCellIdentifier, forIndexPath: indexPath) as MusicChooserTableViewCell
        switch indexPath.section{
        case 0:
            cell.bindMusicURL(orchestralMusic[orchestralMusic.keys.array[indexPath.row]]!, name: orchestralMusic.keys.array[indexPath.row])
            cell.delegate = self
            return cell
        case 1:
            cell.bindMusicURL(pianoMusic[pianoMusic.keys.array[indexPath.row]]!, name: pianoMusic.keys.array[indexPath.row])
            cell.delegate = self
            return cell
        default:
            return UITableViewCell()
        }
    }

    /*
    // MARK: - Navigation

    // In a storyboard-based application, you will often want to do a little preparation before navigation
    override func prepareForSegue(segue: UIStoryboardSegue, sender: AnyObject?) {
        // Get the new view controller using [segue destinationViewController].
        // Pass the selected object to the new view controller.
    }
    */

    func musicChooserTableViewCell(cell: MusicChooserTableViewCell, didTapPlayButton musicToPlay: NSURL) {
        switchMusic(musicToPlay)
    }
    
    func musicChooserTableViewCell(cell: MusicChooserTableViewCell, didTapVoteButton musicToVote: String) {
        println(musicToVote)
    }
}
