//
//  MusicViewController.swift
//  slowdowner2
//
//  Created by Sharad on 9/28/19.
//  Copyright © 2019 Sharad. All rights reserved.
//

import UIKit
import AVFoundation


//Other imports

class MusicViewController: UIViewController {

//    var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    var engine = AVAudioEngine()
    var speedControl = AVAudioUnitVarispeed()
    var pitchControl = AVAudioUnitTimePitch()
    var reverbControl = AVAudioUnitReverb()
    
    
    var fileStrings = [
        "CHECC",
        "PROBLEMS",
        "ONSIGHT"
    ]
    
    var songNames = [
        "Checc",
        "Problems",
        "On Sight"
    ]
    var artistNames = [
        "MIDDMANN",
        "NK",
        "88GLAM"
    ]
    
    @IBOutlet weak var speedLabel: UILabel!
    
    @IBOutlet weak var pitchLabel: UILabel!
    
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var songTitle: UILabel!
    
    @IBOutlet weak var songArtist: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
    }
    
//  Slider Handlers
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        speedControl.rate = sender.value
        pitchControl.pitch = calculatePitch(speed: sender.value)
        updateText();
        changeColor(lightness: sender.value)
    }
    
    
    @IBAction func reverbValueChanged(_ sender: UISlider) {
        print(sender.value)
        reverbControl.wetDryMix = Float(sender.value)
    }
    
    func updateText() {
        speedLabel.text = "\(speedControl.rate)"
        pitchLabel.text = "\(pitchControl.pitch)"
        sliderLabel.text="\(slider.value)"
    }
    
 
    
    func calculatePitch(speed : Float) -> Float {
        //  .1 units of Speed Change = 50 units of pitch change
        //  pitch = 500(speed) - 500
        return 500 * speed - 500;
    }
    
    func changeColor(lightness: Float) {
        //  Calculate brightness with Offset
        let newBrightness = lightness - 0.5;
        
        // Get HSB color values from backgroundColor
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        view.backgroundColor?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        //  Create and set new color with new brightness
        let color = UIColor(hue: h, saturation: s, brightness: CGFloat(newBrightness), alpha: a)
        view.backgroundColor = color
    }
    
    @IBAction func stopButtonTapped(_ sender: UIButton) {
        print("stopButtonTapped: Trying")
        //            try playURL( audioURL! )
    }
    
    
    @IBAction func speedUpButtonTapped(_ sender: UIButton) {
        pitchControl.pitch += 50
        speedControl.rate += 0.1
        slider.value = speedControl.rate
        updateText()
        changeColor(lightness: speedControl.rate)
    }
    
    @IBAction func slowDownButtonTapped(_ sender: UIButton) {
        pitchControl.pitch -= 50
        speedControl.rate -= 0.1
        slider.value = speedControl.rate
        updateText();
        changeColor(lightness: slider.value);
    }
    
    
    @IBAction func playButtonTapped(_ sender: UIButton) {
        do {
            
            let i = Int(sender.currentTitle!)! - 1;
            let fileString = fileStrings[i]
            
            let url = Bundle.main.url(forResource: fileString, withExtension: "mp3")!
            
            print("playButtonTapped: Trying Playing URL:", url)
            
            try playURL( url )
            
            updateSongText(index: i)
        } catch {
            print("playButtonTapped: Failed")
        }
    }
    
    func updateSongText(index: Int){
        songTitle.text = songNames[index];
        songArtist.text = artistNames[index];
    }
    
    
    func playURL(_ url: URL) throws {

        // 1: load the file
        print(1)
        let file = try AVAudioFile(forReading: url)
        
        // 2: create the audio player
        print(2)
        let audioPlayer = AVAudioPlayerNode()
        
        // 3: connect the components to our playback engine
        print(3)
        engine.attach(audioPlayer)
        engine.attach(pitchControl)
        engine.attach(speedControl)
        engine.attach(reverbControl)
        
        
        // 4: arrange the parts so that output from one is input to another
        print(4)
        engine.connect(audioPlayer, to: speedControl, format: nil)
        engine.connect(speedControl, to: reverbControl, format: nil)
        engine.connect(reverbControl, to: pitchControl, format: nil)
        engine.connect(pitchControl, to: engine.mainMixerNode, format: nil)
        
        // 5: prepare the player to play its file from the beginning
        print(5)
        audioPlayer.scheduleFile(file, at: nil)
        
        // 6: start the engine and player
        print(6)
        try engine.start()
        audioPlayer.play()
    }
    
}
