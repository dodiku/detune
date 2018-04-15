//
//  SynthController.swift
//  Face_Music
//
//  Copyright © 2017 Or Fleisher and Dror Ayalon (NYU, ITP). All rights reserved.
//

import Foundation
import AudioKit

class SynthController{
    
    var beatPlayer : AKAudioPlayer
    
    var rightEye : AKAudioPlayer
    var leftEye : AKAudioPlayer
    
    var eyeSide : AKAudioPlayer
    var smileSound : AKAudioPlayer
    
    var baseSynth : AKAudioPlayer
    var baseSynthFilter : AKLowPassFilter
    
    var beatCallback : AKCallback?
 
    //Drum beeps
    var drumBleep1 : AKOscillator = AKOscillator(waveform: AKTable(.sine))
    var drumBank : AKOscillatorBank = AKOscillatorBank(waveform: AKTable(.sine),
                                                       attackDuration: 0.1,
                                                       decayDuration: 0.01,
                                                       sustainLevel: 0.5,
                                                       releaseDuration: 0.2,
                                                       pitchBend: 0,
                                                       vibratoDepth: 0,
                                                       vibratoRate: 0)
    
    
    // Piano
    let pianoNote = AKRhodesPiano()
    var pianoEnv : AKTremolo = AKTremolo()
    var pianoVerb : AKReverb2 = AKReverb2()
    var pianoDly : AKDelay = AKDelay()
    var pianoOut : AKMixer = AKMixer()
    let phrygianDispostion: [Int] = [ 60, 62, 64, 65, 67, 69, 70 ]
    
    var currentAmplitude = 0.4
    
    var noteSet = 0
    
    var mainMixer: AKMixer = AKMixer()
    var mainWah: AKPitchShifter = AKPitchShifter()
    
    
    // status change params
    var setRightBlinkChanged = false
    var setLeftBlinkChanged = false
    var setLookDownChanged = false
    var setLookOutChanged = false
    var setNoseChanged = false
    var setSmileSoundChange = false
    var setBeatChange = false
    
    
    init(){
        
        self.beatPlayer = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/beat_05.wav"), looping: false, lazyBuffering: false, completionHandler: nil)
        self.beatPlayer.endTime = self.beatPlayer.duration - 0.042
        
        self.eyeSide = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/Zoom2.wav"), looping: false, lazyBuffering: true, completionHandler: nil)
        
        self.rightEye = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/Blip 004.wav"), looping: false, lazyBuffering: true, completionHandler: nil)
        
        self.leftEye = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/Effect 002.wav"), looping: false, lazyBuffering: true, completionHandler: nil)
        
        
        self.baseSynth = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/base_synth.wav"), looping: true, lazyBuffering: false, completionHandler: nil)
        self.baseSynthFilter = AKLowPassFilter(self.baseSynth, cutoffFrequency: 6000, resonance: 0)
        
        self.smileSound = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/Award.wav"), looping: false, lazyBuffering: false, completionHandler: nil)
      
        
        // INSTRUMENTS !!!!
        self.pianoEnv = AKTremolo(self.pianoNote)
        self.pianoVerb = AKReverb2(self.pianoEnv)
        self.pianoVerb.dryWetMix = 0.6
        self.pianoDly = AKDelay(self.pianoVerb)
        self.pianoDly.time = 0.1
        self.pianoDly.feedback = 0.9
        self.pianoDly.dryWetMix = 0.7
        self.pianoOut = AKMixer(self.pianoDly)
        
        //Drum bleeps and beeps
        self.drumBank = AKOscillatorBank(waveform: AKTable(.sine),
                                                                        attackDuration: 0.004,
                                                                        decayDuration: 0.01,
                                                                        sustainLevel: 0.6,
                                                                        releaseDuration: 0.1,
                                                                        pitchBend: 0,
                                                                        vibratoDepth: 0,
                                                                        vibratoRate: 0)
        self.mainMixer.connect(input: self.pianoOut)
        self.mainMixer.connect(input: self.drumBank)
        self.mainMixer.connect(input: self.beatPlayer)
        self.mainMixer.connect(input: self.eyeSide)
        self.mainMixer.connect(input: self.smileSound)
        self.mainMixer.connect(input: self.leftEye)
        self.mainMixer.connect(input: self.rightEye)
        
        self.mainWah = AKPitchShifter(self.mainMixer, shift: 0, windowSize: 1_024, crossfade: 512)
        
        
        
        AudioKit.output = self.mainWah
        AudioKit.output = self.baseSynthFilter
        do {
            try AudioKit.start()
        } catch {
            print(error)
        }
        
        // applying oscillators' default amplitude
        self.pianoOut.volume = self.currentAmplitude * 0.88
        self.beatPlayer.volume = 0.0
        self.baseSynth.volume = self.currentAmplitude * 0.8
        self.eyeSide.volume = self.currentAmplitude * 0.25
        self.smileSound.volume = self.currentAmplitude * 0.18
        self.leftEye.volume = self.currentAmplitude * 0.25
        self.rightEye.volume = self.currentAmplitude * 0.18

        // starting the oscillators
        self.beatPlayer.play()
        self.baseSynth.play()
        self.smileSound.play()
        self.leftEye.play()
        self.rightEye.play()
        
        mainMixer.start()
        
    }

    
    func fadeOut() -> Void {
        
    }
   
    
    func isChangedLower(threshold: Float, value: Float, changed: Bool) -> Bool {
        if (value < threshold) {
            if (changed == false) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
    func isChangedHigher(threshold: Float, value: Float, changed: Bool) -> Bool {
        if (value > threshold) {
            if (changed == false) {
                return true
            } else {
                return false
            }
        }
        return false
    }
    
}
