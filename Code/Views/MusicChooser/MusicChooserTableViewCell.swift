//
//  MusicChooserTableViewCell.swift
//  TH-PopQuiz
//
//  Created by Ryne Cheow on 4/11/14.
//  Copyright (c) 2014 TradeHero. All rights reserved.
//

import UIKit

class MusicChooserTableViewCell: UITableViewCell {

    @IBOutlet weak var musicNameLabel: UILabel!
    var musicURL: NSURL!
    
    @IBOutlet weak var defaultButton: UIButton!
    var delegate: MusicChooserTableViewCellDelegate!
    
    override func awakeFromNib() {
        super.awakeFromNib()
        // Initialization code
    }
    
    func bindMusicURL(url: NSURL, name: String){
        musicURL = url
        musicNameLabel.text = name
        defaultButton.enabled = musicNameLabel.text != kTHDefaultSong
    }
    
    @IBAction func voteAction(sender: AnyObject) {
        self.delegate.musicChooserTableViewCell(self, didTapVoteButton: musicNameLabel.text!)
    }
    
    
    @IBAction func playAction(sender: AnyObject) {
        self.delegate.musicChooserTableViewCell(self, didTapPlayButton: musicURL)
    }
    
    
}

protocol MusicChooserTableViewCellDelegate :class, NSObjectProtocol {
    func musicChooserTableViewCell(cell:MusicChooserTableViewCell, didTapVoteButton musicToVote:String)
    func musicChooserTableViewCell(cell:MusicChooserTableViewCell, didTapPlayButton musicToPlay:NSURL)
}
