//
//  ViewController.swift
//  AudioTest
//
//  Created by aluno9 on 18/08/21.
//

import UIKit
import AVFoundation

class ViewController: UIViewController, AVAudioPlayerDelegate, AVAudioRecorderDelegate{

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var recordButton: UIButton!
    @IBOutlet weak var timerLabel: UILabel!
    @IBOutlet weak var timerCounterLabel: UILabel!
    @IBOutlet weak var fileNameLabel: UILabel!
    
    var totalTime = 10
    var timeLeft = 10
    var timer : Timer!
    var isRunning = false
    
    var filename: String = "audioRecorded"
    var counter: Int = 0
    let format: String = ".wav"
    var selectedAudio : URL!
    
    var soundPlay : AVAudioPlayer!
    var recordingSession : AVAudioSession!
    var soundRecord : AVAudioRecorder!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        recordingSession = AVAudioSession.sharedInstance()
        do{
            try recordingSession.setCategory(.playAndRecord, mode: .default)
            try recordingSession.setActive(true)
            recordingSession.requestRecordPermission() { [unowned self] allowed in
                DispatchQueue.main.async {
                    if (allowed){
                        self.loadView()
                    }
                    else{
                        print("Client does not allow microfone")
                    }
                }
                
            }
        }
        catch {
            print("Error")
        }
    }

    func setupRecorder(){
        
        let recordSettings = [AVFormatIDKey : NSNumber(value: kAudioFormatLinearPCM)  ,
                            AVSampleRateKey : NSNumber(value: Float(44100.0)),
                            AVNumberOfChannelsKey : NSNumber(value: 2),
                            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue))]
        
        var error : NSError?
        
        let audioName = getFileName()
        
        do{
            soundRecord = try AVAudioRecorder(url: audioName, settings: recordSettings)
        }
        catch let error1 as NSError{
            error = error1
            soundRecord = nil
        }
        
        if let err = error {
            print("Error: \(err.localizedDescription)")
        }
        else{
            soundRecord.delegate = self
            soundRecord.prepareToRecord()
        }
        
        
    }
    
    func preparePlayer(){
        var error: NSError?
        
        let audioName = selectedAudio
        
        print(audioName!)
        do{
            soundPlay = try AVAudioPlayer(contentsOf: audioName!)
        }
        catch let error1 as NSError{
            error = error1
            soundPlay = nil
        }
        
        if let err = error{
            print("Error: \(err.localizedDescription)")
        }
        else{
            soundPlay.delegate = self
            soundPlay.prepareToPlay()
            soundPlay.volume = 1.0
        }
    }
    
    func runTimer(_ sender: String){
        timer = Timer.scheduledTimer(withTimeInterval: 1, repeats: true) { timer in
            if self.timeLeft != 0 {
                self.timeLeft -= 1
                self.timerLabel.text = "\(self.timeLeft)"
            }
            else{
                timer.invalidate()
                if sender == "Record" {
                    self.soundRecord.stop()
                    self.recordButton.setTitle("Record", for: .normal)
                    self.playButton.isEnabled = true
                }
                else if sender == "Play" {
                    self.soundPlay.stop()
                    self.playButton.setTitle("Play", for: .normal)
                    self.recordButton.isEnabled = true
                }
            }
        }
    }
    
    func getDocumentDirectory() -> URL {
        let paths = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)
        return paths[0]
    }
    
    func getFileName() -> URL{
        var file = filename + format
        var audioName = getDocumentDirectory().appendingPathComponent(file)
        do {
            let filesInDirectory = try FileManager.default.contentsOfDirectory(at: getDocumentDirectory(), includingPropertiesForKeys: nil)
            while filesInDirectory.contains(audioName){
                counter+=1
                file = filename + String(counter) + format
                audioName = getDocumentDirectory().appendingPathComponent(file)
            }
        }
        catch let error{
            print(error)
        }
        selectedAudio = audioName
        fileNameLabel.text = file
        return audioName
    }
    
    @IBAction func playSession(_ sender: UIButton) {
        if sender.titleLabel?.text == "Play"{
            preparePlayer()
            timeLeft = totalTime
            runTimer("Play")
            soundPlay.play()
            recordButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
        }
        else{
            timeLeft = totalTime
            timer.invalidate()
            timerLabel.text = String(0)
            soundPlay.stop()
            sender.setTitle("Play", for: .normal)
            recordButton.isEnabled = true
        }
    }
    
    @IBAction func recordSession(_ sender: UIButton) {
        if sender.titleLabel?.text == "Record" {
            setupRecorder()
            timeLeft = totalTime
            runTimer("Record")
            soundRecord.record()
            sender.setTitle("Stop", for: .normal)
            playButton.isEnabled = false
        }
        else{
            timeLeft = totalTime
            timer.invalidate()
            timerLabel.text = String(0)
            soundRecord.stop()
            sender.setTitle("Record", for: .normal)
            playButton.isEnabled = true
        }
    }
        
    @IBAction func increaseTimer(_ sender: UIButton) {
        totalTime += 1
        timerCounterLabel.text = String(totalTime)
        timeLeft = totalTime
    }
    
    @IBAction func decreaseTimer(_ sender: UIButton) {
        totalTime -= 1
        timerCounterLabel.text = String(totalTime)
        timeLeft = totalTime
    }
    
}

