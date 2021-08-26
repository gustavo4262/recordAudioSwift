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
    
    var filename: String = "audioFile"
    var counter: Int = 1
    let format: String = ".wav"
    
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
        setupRecorder()
    }

    func setupRecorder(){
        
        let recordSettings = [AVFormatIDKey : NSNumber(value: kAudioFormatLinearPCM)  ,
                            AVSampleRateKey : NSNumber(value: Float(44100.0)),
                            AVNumberOfChannelsKey : NSNumber(value: 2),
                            AVEncoderAudioQualityKey : NSNumber(value: Int32(AVAudioQuality.max.rawValue))]
        
        var error : NSError?
        
        let audioName = getDocumentDirectory().appendingPathComponent(filename)
        
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
        
        let audioName = getFileName()
                
        do{
            soundPlay = try AVAudioPlayer(contentsOf: audioName)
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
                filename += String(counter)
                file = filename + format
                audioName = getDocumentDirectory().appendingPathComponent(file)
                counter += 1
            }
            print(audioName)
        }
        catch let error{
            print(error)
        }
        return audioName
    }
    
    @IBAction	 func playSession(_ sender: UIButton) {
        if sender.titleLabel?.text == "Play"{
            preparePlayer()
            soundPlay.play()
            recordButton.isEnabled = false
            sender.setTitle("Stop", for: .normal)
        }
        else{
            soundPlay.stop()
            sender.setTitle("Play", for: .normal)
            recordButton.isEnabled = true
        }
    }
    
    @IBAction func recordSession(_ sender: UIButton) {
        if sender.titleLabel?.text == "Record" {
            soundRecord.record()
            sender.setTitle("Stop", for: .normal)
            playButton.isEnabled = false
        }
        else{
            soundRecord.stop()
            sender.setTitle("Record", for: .normal)
            playButton.isEnabled = true
        }
        
    }
}

