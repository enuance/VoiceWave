//
//  PlaySoundsViewController+Audio.swift
//  PitchPerfect
//
//  Copyright © 2016 Udacity. All rights reserved.
//
//  Updated for Swift 3 by Stephen Martinez on 10/28/2016
//
import UIKit
import AVFoundation

extension PlaySoundsViewController: AVAudioPlayerDelegate {
    struct Alerts {
        static let DismissAlert = "Dismiss"
        static let RecordingDisabledTitle = "Recording Disabled"
        static let RecordingDisabledMessage = "You've disabled this app from recording your microphone. Check Settings."
        static let RecordingFailedTitle = "Recording Failed"
        static let RecordingFailedMessage = "Something went wrong with your recording."
        static let AudioRecorderError = "Audio Recorder Error"
        static let AudioSessionError = "Audio Session Error"
        static let AudioRecordingError = "Audio Recording Error"
        static let AudioFileError = "Audio File Error"
        static let AudioEngineError = "Audio Engine Error"
    }
    
    enum PlayingState { case Playing, NotPlaying }
    
    //MARK: Audio Functions
    func setupAudio(){
        //initialize (recording) audio file
        do{
            audioFile = try AVAudioFile(forReading: recordedAudioURL as URL)
        }catch{
            showAlert(title: Alerts.AudioFileError, message: String(describing: error))
        }
    }
    
    func playSound(rate: Float? = nil, pitch: Float? = nil, echo: Bool = false, reverb: Bool = false){
        audioEngine = AVAudioEngine()//.........................initialize audio engine components
        audioPlayerNode = AVAudioPlayerNode()//.................node for playing audio
        audioEngine.attach(audioPlayerNode)
        let changeRatePitchNode = AVAudioUnitTimePitch()//..........node for adjusting rate/pitch
        if let pitch = pitch{changeRatePitchNode.pitch = pitch}
        if let rate = rate{changeRatePitchNode.rate = rate}
        audioEngine.attach(changeRatePitchNode)
        let echoNode = AVAudioUnitDistortion()//..................node for echo
        echoNode.loadFactoryPreset(.multiEcho2)
        audioEngine.attach(echoNode)
        let reverbNode = AVAudioUnitReverb()//.....................node for reverb
        reverbNode.loadFactoryPreset(.cathedral)
        reverbNode.wetDryMix = 50
        audioEngine.attach(reverbNode)
        if echo == true && reverb == true{  //........................connect nodes
            connectAudioNodes(nodes: audioPlayerNode, changeRatePitchNode, echoNode, reverbNode, audioEngine.outputNode)
        }else if echo == true{
            connectAudioNodes(nodes: audioPlayerNode, changeRatePitchNode, echoNode, audioEngine.outputNode)
        }else if reverb == true{
            connectAudioNodes(nodes: audioPlayerNode, changeRatePitchNode, reverbNode, audioEngine.outputNode)
        }else{
            connectAudioNodes(nodes: audioPlayerNode, changeRatePitchNode, audioEngine.outputNode)
        }//....................................................schedule to play and start the engine!
        audioPlayerNode.stop()
        audioPlayerNode.scheduleFile(audioFile, at: nil){
            var delayInSeconds: Double = 0
            if let lastRenderTime = self.audioPlayerNode.lastRenderTime, let playerTime = self.audioPlayerNode.playerTime(forNodeTime: lastRenderTime){
                if let rate = rate{
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate) / Double(rate)
                }else{
                    delayInSeconds = Double(self.audioFile.length - playerTime.sampleTime) / Double(self.audioFile.processingFormat.sampleRate)
                }
            }//...................................................schedule a stop timer for when audio finishes playing
            self.stopTimer = Timer(timeInterval: delayInSeconds, target: self, selector: #selector(PlaySoundsViewController.stopAudio), userInfo: nil, repeats: false)
            RunLoop.main.add(self.stopTimer!, forMode: RunLoopMode.defaultRunLoopMode)
        }
        do{
            try audioEngine.start()
        }catch{
            showAlert(title: Alerts.AudioEngineError, message: String(describing: error))
            return
        }//....................................................play the recording!
        audioPlayerNode.play()
    }
    
    // MARK: Connect List of Audio Nodes
    func connectAudioNodes(nodes: AVAudioNode...) {
        for x in 0..<nodes.count-1 {
            audioEngine.connect(nodes[x], to: nodes[x+1], format: audioFile.processingFormat)
        }
    }
    
    func stopAudio() {
        if let stopTimer = stopTimer {stopTimer.invalidate()}
        configureUI(playState: .NotPlaying)
        if let audioPlayerNode = audioPlayerNode {audioPlayerNode.stop()}
        if let audioEngine = audioEngine {audioEngine.stop();audioEngine.reset()}
    }
    
    // MARK: UI Functions
    func configureUI(playState: PlayingState) {
        switch(playState) {
        case .Playing:
            setPlayButtonsEnabled(enabled: false)
            StopPlaybackButton.isEnabled = true
        case .NotPlaying:
            setPlayButtonsEnabled(enabled: true)
            StopPlaybackButton.isEnabled = false
        }
    }
    
    func setPlayButtonsEnabled(enabled: Bool) {
        SnailButton.isEnabled = enabled
        ChipmonkButton.isEnabled = enabled
        RabbitButton.isEnabled = enabled
        DarthVaderButton.isEnabled = enabled
        ParrotButton.isEnabled = enabled
        ReverbButton.isEnabled = enabled
    }
    
    func showAlert(title: String, message: String) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: Alerts.DismissAlert, style: .default, handler: nil))
        self.present(alert, animated: true, completion: nil)
    }
    
}

















