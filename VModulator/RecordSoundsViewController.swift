//
//  RecordSoundsViewController.swift
//  VModulator
//
//  Created by Stephen Martinez on 10/25/16.
//  Copyright © 2016 Stephen Martinez. All rights reserved.
//

import UIKit
import AVFoundation
import Foundation

class RecordSoundsViewController: UIViewController, AVAudioRecorderDelegate {
    
    

    @IBOutlet weak var recordingLabel: UILabel!
    
    @IBOutlet weak var recordButton: UIButton!
    
    @IBOutlet weak var timer: UILabel!
    
    @IBOutlet weak var stopRecordButton: UIButton!
    
    var timeClock = Timer()
    
    var counter = 0
    
    var audioRecorder: AVAudioRecorder!
    
    func updateCounter() {
        counter = counter + 1
        // if statement for clock display. Sases in swift switch statements don't take comparitive statemente with arguments (seemingly).
        if (counter%60) < 10 && (Int(counter/60)) < 10 {
            timer.text = "0\(Int(counter/60)):0\(counter%60)"
        }else if (counter%60) > 10 && (Int(counter/60)) > 10{
            timer.text = "\(Int(counter/60)):\(counter%60)"
        }else if (counter%60) < 10 && (Int(counter/60)) > 10{
            timer.text = "\(Int(counter/60)):0\(counter%60)"
        }else{
            timer.text = "0\(Int(counter/60)):\(counter%60)"
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        stopRecordButton.isEnabled = false
        timer.text = "00:00"
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func recordAudio(_ sender: AnyObject) {
        print("I've been pressed and I'm now recording")
        timeClock = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RecordSoundsViewController.updateCounter)), userInfo: nil, repeats: true)
        stopRecordButton.isEnabled = true
        recordButton.isEnabled = false
        recordingLabel.text = "Recording in progress..."
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        print(filePath ?? "No File Path!")
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSessionCategoryPlayAndRecord)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true  // all enabled properties must be changed to the new isEnabled property name!
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
 
    
    @IBAction func stopRecording(_ sender: AnyObject) {
        print("I've been pressed and I've stopped recording") // print statement for debugging
        timeClock.invalidate()
        counter = 0
        timer.text = "00:00"
        stopRecordButton.isEnabled = false
        recordButton.isEnabled = true
        if recordingLabel.text == "Recording in progress..."{
            recordingLabel.text = "Tap Mic to Record!"
        }
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
            print("Recording has finished") // print statement for debugging
        if (flag){
            self.performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        }else{
            print("The saving of the recording has failed!")
        }

    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! NSURL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
}






