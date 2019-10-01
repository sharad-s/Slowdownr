//
//  TimePitchStreamer.swift
//  slowdowner2
//
//  Created by Sharad on 9/30/19.
//  Copyright © 2019 Sharad. All rights reserved.
//

import UIKit
import AVFoundation
//import AudioStreamer

class TimePitchStreamer: Any {

    lazy var playerNode = AVAudioPlayerNode()
    
    var audioEngine = AVAudioEngine()
    var speedControl = AVAudioUnitVarispeed()
    var pitchControl = AVAudioUnitTimePitch()
    var reverbControl = AVAudioUnitReverb()
    
    /// A `Float` representing the pitch of the audio
    var pitch: Float {
        get {
            return pitchControl.pitch
        }
        set {
            pitchControl.pitch = newValue
        }
    }
    
    /// A `Float` representing the playback rate of the audio
    var speed: Float {
        get {
            return speedControl.rate
        }
        set {
            speedControl.rate = newValue
        }
    }
    
    /// A `Float` representing the reverb dry/wet audio
    var reverb: Float {
        get {
            return reverbControl.wetDryMix
        }
        set {
            reverbControl.wetDryMix = newValue
        }
    }
    
    
    func setupAudioSession() {
        let  session = AVAudioSession.sharedInstance()
        do {
            try session.setCategory(.playback, mode: .default, policy: .default, options: [.allowBluetoothA2DP,.defaultToSpeaker])
            try session.setActive(true)
        } catch {
            print("Failed to activate audio session: %@")
        }
    }
    
    func attachNodes() {
        audioEngine.attach(speedControl)
        audioEngine.attach(pitchControl)
        audioEngine.attach(reverbControl)
    }
    
    func connectNodes() {
        audioEngine.connect(playerNode, to: speedControl, format: nil)
        audioEngine.connect(speedControl, to: pitchControl, format: nil)
        audioEngine.connect(speedControl, to: reverbControl, format: nil)
        audioEngine.connect(reverbControl, to: audioEngine.mainMixerNode, format: nil)
    }

    
    func playSong(fileURL: URL) throws {
        
        print(1)
        let file = try AVAudioFile(forReading: fileURL)
        
        print(2)
        playerNode.scheduleFile(file, at: nil)
        
        // 6: start the engine and player
        print(3)
        try audioEngine.start()
        playerNode.play()
    }
}
