//
//  ViewController.swift
//  PitchPerfect
//
//  Created by Jonathan Miranda on 4/17/20.
//  Copyright © 2020 Jonathan Miranda. All rights reserved.
//

import UIKit
import AVFoundation

class RecordSoundViewController: UIViewController, AVAudioRecorderDelegate {

    // MARK: - Properties
    
    var audioRecorder: AVAudioRecorder!

    @IBOutlet weak var recordingLabel: UILabel!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var stopRecordingButton: UIButton!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI(.stop)
    }
    
    // MARK: - RecordState (raw values correspond to sender tags)
    
    enum RecordState { case record, stop}

    // MARK: - record and stop audio
    
    @IBAction func recordAudio(_ sender: Any) {
        configureUI(.record)
        
        let dirPath = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0] as String
        let recordingName = "recordedVoice.wav"
        let pathArray = [dirPath, recordingName]
        let filePath = URL(string: pathArray.joined(separator: "/"))
        
        let session = AVAudioSession.sharedInstance()
        try! session.setCategory(AVAudioSession.Category.playAndRecord, mode: AVAudioSession.Mode.default, options: AVAudioSession.CategoryOptions.defaultToSpeaker)
        
        try! audioRecorder = AVAudioRecorder(url: filePath!, settings: [:])
        audioRecorder.delegate = self
        audioRecorder.isMeteringEnabled = true
        audioRecorder.prepareToRecord()
        audioRecorder.record()
    }
    
    
    @IBAction func stopRecording(_ sender: Any) {
        configureUI(.stop)
        
        audioRecorder.stop()
        let audioSession = AVAudioSession.sharedInstance()
        try! audioSession.setActive(false)
    }
    
    // MARK: - Audio Recorder Delegate
    
    func audioRecorderDidFinishRecording(_ recorder: AVAudioRecorder, successfully flag: Bool) {
        if flag {
            performSegue(withIdentifier: "stopRecording", sender: audioRecorder.url)
        } else {
            print("recording was not successful")
        }
    }
    
    // MARK: - Preparing the segue
    
    override func prepare(for segue: UIStoryboardSegue, sender: Any?) {
        if segue.identifier == "stopRecording" {
            let playSoundsVC = segue.destination as! PlaySoundsViewController
            let recordedAudioURL = sender as! URL
            playSoundsVC.recordedAudioURL = recordedAudioURL
        }
    }
    
    
    // MARK: - UI Functions
    
    func configureUI(_ recordState: RecordState) {
        switch recordState {
        case .record:
            setRecordButtonsEnable(false)
        case .stop:
            setRecordButtonsEnable(true)
        }
    }
    
    func setRecordButtonsEnable(_ enabled: Bool) {
        recordButton.isEnabled = enabled
        stopRecordingButton.isEnabled = !enabled
        recordingLabel.text = enabled ? "Tap to Record..." : "Recording in Progress"
    }
}

