//
//  MusicViewController.swift
//  slowdowner2
//
//  Created by Sharad on 9/28/19.
//  Copyright © 2019 Sharad. All rights reserved.
//


//https://stackoverflow.com/questions/36167852/apple-music-avaudioengine-in-swift
//https://stackoverflow.com/questions/49925673/is-there-a-way-to-show-lock-screen-controls-using-avaudioengine-and-avaudioplaye
//https://forums.developer.apple.com/thread/108512
// https://medium.com/better-programming/create-audio-unit-extension-from-scratch-77abee79d12

import UIKit
import AVFoundation
import MediaPlayer
import os.log


//Other imports

class MusicViewController: UIViewController {
    
    static let logger = OSLog(subsystem: "com.sharadshekar.slowdowner", category: "ViewController")

    // var musicPlayer = MPMusicPlayerController.applicationMusicPlayer
    var engine = AVAudioEngine()
    var audioPlayer = AVAudioPlayerNode()
    var speedControl = AVAudioUnitVarispeed()
    var pitchControl = AVAudioUnitTimePitch()
    var reverbControl = AVAudioUnitReverb()
    
    
    
    // UI Props
    @IBOutlet weak var speedLabel: UILabel!
    @IBOutlet weak var pitchLabel: UILabel!
    
    @IBOutlet weak var sliderLabel: UILabel!
    @IBOutlet weak var slider: UISlider!
    
    @IBOutlet weak var songTitle: UILabel!
    @IBOutlet weak var songArtist: UILabel!
    
//    Play Button
    @IBOutlet weak var playPauseButton: UIButton!
    
    //    New Stuff
    @IBOutlet weak var currentTimeLabel: UILabel!
    @IBOutlet weak var durationTimeLabel: UILabel!

    @IBOutlet weak var playButton: UIButton!
    @IBOutlet weak var progressSlider: ProgressSlider!
    

    var isSeeking = false
    var currentURL = URL(string: "")

    
    override func viewDidLoad() {
        super.viewDidLoad()
        playPauseButton.isHidden = true;
    }
    
    // Button Handlers
    @IBAction func selectSongClicked(_ sender: UIButton) {
        print("boobs")
        let mediaPicker = MPMediaPickerController(mediaTypes: .music)
        mediaPicker.allowsPickingMultipleItems = false
        mediaPicker.showsCloudItems = false // you won't be able to fetch the URL for media items stored in the cloud
        mediaPicker.delegate = self
        mediaPicker.prompt = "Pick a track"
        present(mediaPicker, animated: true, completion: nil)
    }
    
    //  Slider Handlers
    @IBAction func sliderValueChanged(_ sender: UISlider) {
        speedControl.rate = sender.value
        pitchControl.pitch = calculatePitch(speed: sender.value)
        updateLabelText();
        view.backgroundColor = changeColor(lightness: sender.value)
    }
    
    @IBAction func reverbValueChanged(_ sender: UISlider) {
        print(sender.value)
        reverbControl.wetDryMix = Float(sender.value)
    }
 
    //  Update Text
    func updateLabelText() {
        speedLabel.text = String(format: "%.3fx", speedControl.rate)
        pitchLabel.text = "\(pitchControl.pitch)"
        sliderLabel.text = String(format: "%.3fx", slider.value)
    }
    
    func updateSongText(title: String, artist: String){
        songTitle.text = title;
        songArtist.text = artist;
    }
    
    //  Calc functions
    func calculatePitch(speed : Float) -> Float {
        //  .1 units of Speed Change = 50 units of pitch change
        //  pitch = 500(speed) - 500
        return 500 * speed - 500;
    }
    
    func changeColor(lightness: Float) -> UIColor {
        //  Calculate brightness with Offset
        let newBrightness = lightness - 0.55;
        
        // Get HSB color values from backgroundColor
        var h: CGFloat = 0
        var s: CGFloat = 0
        var b: CGFloat = 0
        var a: CGFloat = 0
        view.backgroundColor?.getHue(&h, saturation: &s, brightness: &b, alpha: &a)
        
        //  Create a new color with new brightness
        return UIColor(hue: h, saturation: s, brightness: CGFloat(newBrightness), alpha: a)
    }

    
    
  
    
    func playURL(_ url: URL) throws {
        // 1: load the file
        print(1)
        let file = try AVAudioFile(forReading: url)
        
        // 2: create the audio Session
        print(2)
        try AVAudioSession.sharedInstance().setCategory(.playback)
        
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
        
        // Set label
        playPauseButton.setTitle("PAUSE", for: .normal)
    }
    
    func pause() {
        audioPlayer.pause()
        playPauseButton.setTitle("PLAY", for: .normal)
    }
    
    
 
    @IBAction func playButtonToggled(_ sender: UIButton) {
        let url = currentURL!
        if (audioPlayer.isPlaying){
            pause()
        } else {
            do {
               try playURL(url)
            } catch {
                print("Error Playing Track")
            }
        }
        
    }
    
}


//Apple Music Media Extension
extension MusicViewController: MPMediaPickerControllerDelegate {
    func mediaPicker(_ mediaPicker: MPMediaPickerController, didPickMediaItems mediaItemCollection: MPMediaItemCollection) {
        guard let item = mediaItemCollection.items.first else {
            print("no item")
            return
        }
        print("picking \(item.title!) - \(item.artist): \(item.assetURL)")
        print("item,", item)
        guard let url = item.assetURL else {
            return print("no url")
        }
        
        dismiss(animated: true) { [weak self] in
            do{
                self?.currentURL = url
                try self?.playURL(url)
                self?.updateSongText(title: item.title!, artist: item.artist!)
                self?.playPauseButton.isHidden = false;
            } catch {
                
            }
           
        }
    }
    
    func mediaPickerDidCancel(_ mediaPicker: MPMediaPickerController) {
        dismiss(animated: true, completion: nil)
    }
}
