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
        //Method that tracks the time of recording and is used when recordAudio is pressed.
        counter = counter + 1
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
        stopRecordButton.isEnabled = false
        timer.text = "00:00"
    }

    @IBAction func recordAudio(_ sender: AnyObject) {
        //Setting the recording timer to start
        timeClock = Timer.scheduledTimer(timeInterval: 1, target: self, selector: (#selector(RecordSoundsViewController.updateCounter)), userInfo: nil, repeats: true)
        stopRecordButton.isEnabled = true
        recordButton.isEnabled = false
        recordingLabel.text = "Recording in progress..."
        //Creating a file path location to save file to be recorded
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory,.userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = NSURL.fileURL(withPathComponents: pathArray)
        //Instantiate a singleton audio session
        let session = AVAudioSession.sharedInstance()
        //Setting up a permission request from the user on a seperate thread
        session.requestRecordPermission() {allowed in
            DispatchQueue.main.async {
                if allowed {
                    //If the user permits audio/recorder usage then select location to save file, set default speakers, and start recording.
                    try! session.setCategory(AVAudioSessionCategoryPlayAndRecord, with: AVAudioSessionCategoryOptions.defaultToSpeaker)
                    try! self.audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
                    self.audioRecorder.delegate = self
                    self.audioRecorder.isMeteringEnabled = true
                    self.audioRecorder.prepareToRecord()
                    self.audioRecorder.record()
                }else{
                    //If user denies permission then update the View to dislpay current state.
                    self.recordingLabel.text = "Denied Permission / App Disabled!"
                }
            }
        }
    }
    
    @IBAction func stopRecording(_ sender: AnyObject) {
        timeClock.invalidate()
        counter = 0
        timer.text = "00:00"
        //Resetting all timer displays and logic back to 0.
        stopRecordButton.isEnabled = false
        recordButton.isEnabled = true
        if recordingLabel.text == "Recording in progress..."{recordingLabel.text = "Tap Mic to Record!"}
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
        //Resetting the audio session and buttons for future reuse.
    }
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if (flag){performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)}
        //pushes to next view only if the recording has successfully finished and been saved.
    }
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if (segue.identifier == "stopRecording"){
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! NSURL
            playSoundsVC.recordedAudioURL = recordedAudioURL
            //Casts the neccessary info (audio file location) for next view controller and sends it over.
        }
    }
}






