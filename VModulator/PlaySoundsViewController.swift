//
//  PlaySoundsViewController.swift
//  VModulator
//
//  Created by Stephen Martinez on 10/28/16.
//  Copyright © 2016 Stephen Martinez. All rights reserved.
//

import UIKit
import AVFoundation




class PlaySoundsViewController: UIViewController {

    @IBOutlet weak var SnailButton: UIButton!
    @IBOutlet weak var RabbitButton: UIButton!
    @IBOutlet weak var ChipmonkButton: UIButton!
    @IBOutlet weak var DarthVaderButton: UIButton!
    @IBOutlet weak var ParrotButton: UIButton!
    @IBOutlet weak var ReverbButton: UIButton!
    @IBOutlet weak var StopPlaybackButton: UIButton!
    
    var recordedAudioURL: NSURL!
    var audioFile: AVAudioFile!
    var audioEngine: AVAudioEngine!
    var audioPlayerNode: AVAudioPlayerNode!
    var stopTimer: Timer!
    
    enum ButtonType: Int { case Slow = 0, Fast, Chipmonk, Vader, Echo, Reverb} //enum is type int so that we can utilize tag nums for button presses in the switch statement
    
    @IBAction func playSoundForButton(_ sender: UIButton) {
        print("Play Sound Button Pressed") // print statement for debugging.
        switch (ButtonType(rawValue: sender.tag)!) {
        case .Slow:
            playSound(rate: 0.4)
        case .Fast:
            playSound(rate: 2.0)
        case .Chipmonk:
            playSound(pitch: 1500)
        case .Vader:
            playSound(pitch: -1000)
        case .Echo:
            playSound(echo: true)
        case .Reverb:
            playSound(reverb: true)
        }
        configureUI(playState: .Playing)
    }
    
    @IBAction func stopButtonPressed(_ sender: AnyObject) {
        print("Stop Audio Button Pressed") // print statement for debugging
        stopAudio()
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        setupAudio()
    }

    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    override func viewWillAppear(_ animated: Bool) {
        configureUI(playState: .NotPlaying)
    }
    
    @IBAction func returnToRecord() {
        stopAudio()
        self.dismiss(animated: true, completion: nil)
    }
    

}
