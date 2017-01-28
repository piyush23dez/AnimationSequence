//
//  ViewController.swift
//  AnimationSequenceDemo
//
//  Created by Piyush Sharma on 1/27/17.
//  Copyright © 2017 Piyush Sharma. All rights reserved.
//

import UIKit
import AVFoundation
import AVKit


enum OutRoomStates {
    case none, announcement, screensaver
}

class ViewController: UIViewController {
        
    @IBOutlet weak var announceImgView: UIImageView!
    
    let announcementFadeInDuration: TimeInterval = 5
    let announcementFadeOutDuration: TimeInterval = 5
    var outRoomState: OutRoomStates = .screensaver //flip between screensaver and announcement
    
    let airplayIcon: UIImage = {
        return UIImage(named: "airplay")!.withRenderingMode(UIImageRenderingMode.alwaysTemplate)
    }()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        view.backgroundColor = UIColor.black
        outRoomState == .announcement ? showAnnouncement() : playHandWriting()
    }
}


//MARK: Announcement fade-in-out animation

extension ViewController {
    
    func showAnnouncement() {
        
        announceImgView.alpha = 0
        announceImgView.image = UIImage(named: "applelogo")

        UIView.animate(withDuration: announcementFadeInDuration, animations: {
            self.announceImgView.alpha = 1
        }) { (finish) in
            
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
                self.fadeAnnouncement()
            })
        }
    }
    
    func fadeAnnouncement() {
        
        UIView.animate(withDuration: announcementFadeOutDuration, animations: {
            self.announceImgView.alpha = 0
        }) { (finish) in
            self.playHandWriting()
        }
    }
}


//MARK: Handwriting video and room image animation

extension ViewController {
    
    func playHandWriting() {
        
        //check if video file exist in bundle
        guard let videoPath = Bundle.main.path(forResource: "Summit", ofType:"mp4") else {
            debugPrint("Summit.mp4 not found")
            return
        }
        
        createPlayer(url: videoPath)
        
        //calculate video playing duration
        let handwritingDuration = getVideoDuration(fileName: videoPath)
        let roomNameImageView = UIImageView(frame: view.bounds)
        
        //hide avplayer after video playing finished and show room name for 5 sec.
        Timer.scheduledTimer(withTimeInterval: handwritingDuration, repeats: false, block: { (timer) in
            self.hidePlayer()
            roomNameImageView.image = UIImage(named: "Summit")
            self.view.addSubview(roomNameImageView)
        })
        
        //fade room name after 5 seconds
        Timer.scheduledTimer(withTimeInterval: 5, repeats: false) { (timer) in
           
            UIView.animate(withDuration: 5, animations: {
                roomNameImageView.alpha = 0
            }) { (finish) in
                //repeat the same process again
                self.outRoomState == .announcement ? self.showAnnouncement() : self.showAirplayImage()
            }
        }
    }
    
    func createPlayer(url: String) {

        let player = AVPlayer(url: URL(fileURLWithPath: url))
        let playerLayer = AVPlayerLayer(player: player)
        playerLayer.frame = self.view.bounds
        self.view.layer.addSublayer(playerLayer)
        player.play()
    }
    
    func hidePlayer() {
        
        for layer in view.layer.sublayers! {
            if layer is AVPlayerLayer {
                layer.removeFromSuperlayer()
            }
        }
    }
    
    func showAirplayImage() {
        
        //create airplay view
        let airplayImageView = UIImageView(frame: CGRect(origin: CGPoint.zero, size: CGSize(width: 65, height: 54)))
        airplayImageView.image = airplayIcon
        airplayImageView.center = view.center
        view.addSubview(airplayImageView)
        airplayImageView.alpha = 0
        
        //fade-in airplay view
        UIView.animate(withDuration: 5, animations: {
            airplayImageView.alpha = 1
        }) { (finish) in
            
            //fade-out airplay view after 5 seconds
            Timer.scheduledTimer(withTimeInterval: 5, repeats: false, block: { (timer) in
               
                UIView.animate(withDuration: 5, animations: {
                    airplayImageView.alpha = 0
                }, completion: { (finish) in
                    //repeat the same process again
                    self.playHandWriting()
                })
            })
        }
    }
    
    func getVideoDuration(fileName: String) -> TimeInterval {
        
        let asset = AVURLAsset(url: URL(fileURLWithPath: fileName), options: nil)
        let videoDuration = asset.duration
        let videoDurationSeconds = CMTimeGetSeconds(videoDuration)
        return videoDurationSeconds
    }
}

