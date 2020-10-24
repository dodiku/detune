//
//  SynthController.swift
//  Face_Music
//
//  Copyright © 2017 Or Fleisher and Dror Ayalon (NYU, ITP). All rights reserved.
//

import Foundation
import AudioKit

class SynthController{

    // Players
    var beatPlayer : AKAudioPlayer
    
    var rightEyePlayer : AKAudioPlayer
    var leftEye : AKAudioPlayer
    
    var eyeSidePlayer : AKAudioPlayer
    var smileSoundPlayer : AKAudioPlayer
    
    var baseSynthPlayer : AKAudioPlayer
    var baseSynthFilter : AKLowPassFilter
 
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
    var pianoEnv = AKTremolo()
    var pianoVerb = AKReverb2()
    var pianoDly = AKDelay()
    var pianoOut = AKMixer()
    let phrygianDispostion: [Int] = [ 60, 62, 64, 65, 67, 69, 70 ]
    
    var currentAmplitude = 0.4
    
    var noteSet = 0
    
    var mainMixer = AKMixer()
    var mainWah = AKPitchShifter()
    
    
    // status change params
    var setRightBlinkChanged = false
    var setLeftBlinkChanged = false
    var setLookDownChanged = false
    var setLookOutChanged = false
    var setNoseChanged = false
    var setSmileSoundChange = false
    var setBeatChange = false
    
    
    init(){
        
        beatPlayer = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/beat_05.wav"), looping: false, lazyBuffering: false, completionHandler: nil)
        beatPlayer.endTime = beatPlayer.duration - 0.042
        
        eyeSidePlayer = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/Zoom2.wav"), looping: false, lazyBuffering: true, completionHandler: nil)
        
        rightEyePlayer = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/Blip 004.wav"), looping: false, lazyBuffering: true, completionHandler: nil)
        
        leftEye = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/Effect 002.wav"), looping: false, lazyBuffering: true, completionHandler: nil)
        
        
        baseSynthPlayer = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/base_synth.wav"), looping: true, lazyBuffering: false, completionHandler: nil)
        baseSynthFilter = AKLowPassFilter(baseSynthPlayer, cutoffFrequency: 6000, resonance: 0)
        
        smileSoundPlayer = try! AKAudioPlayer(file: AKAudioFile(readFileName: "Samples/Award.wav"), looping: false, lazyBuffering: false, completionHandler: nil)
      
        
        // INSTRUMENTS !!!!
        pianoEnv = AKTremolo(pianoNote)
        pianoVerb = AKReverb2(pianoEnv)
        pianoVerb.dryWetMix = 0.6
        pianoDly = AKDelay(pianoVerb)
        pianoDly.time = 0.1
        pianoDly.feedback = 0.9
        pianoDly.dryWetMix = 0.7
        pianoOut = AKMixer(pianoDly)
        
        //Drum bleeps and beeps
        drumBank = AKOscillatorBank(waveform: AKTable(.sine),
                                    attackDuration: 0.004,
                                    decayDuration: 0.01,
                                    sustainLevel: 0.6,
                                    releaseDuration: 0.1,
                                    pitchBend: 0,
                                    vibratoDepth: 0,
                                    vibratoRate: 0)
        mainMixer.connect(input: pianoOut)
        mainMixer.connect(input: drumBank)
        mainMixer.connect(input: beatPlayer)
        mainMixer.connect(input: eyeSidePlayer)
        mainMixer.connect(input: smileSoundPlayer)
        mainMixer.connect(input: leftEye)
        mainMixer.connect(input: rightEyePlayer)
        
        mainWah = AKPitchShifter(mainMixer, shift: 0, windowSize: 1_024, crossfade: 512)
        
        
        AudioKit.output = AKMixer(mainWah, baseSynthFilter)
        do {
            try AudioKit.start()
        } catch {
            print(error)
        }
        
        // applying oscillators' default amplitude
        pianoOut.volume = currentAmplitude * 0.88
        beatPlayer.volume = 0.0
        baseSynthPlayer.volume = currentAmplitude * 0.8
        eyeSidePlayer.volume = currentAmplitude * 0.25
        smileSoundPlayer.volume = currentAmplitude * 0.18
        leftEye.volume = currentAmplitude * 0.25
        rightEyePlayer.volume = currentAmplitude * 0.18

        
        // starting the oscillators
        beatPlayer.play()
        baseSynthPlayer.play()
        smileSoundPlayer.play()
        leftEye.play()
        rightEyePlayer.play()
    }

    
    func fadeOut() -> Void {
        
    }
   
    
    func isChangedLower(threshold: Float, value: Float, changed: Bool) -> Bool {
        if (value < threshold) {
            return !changed
        }
        return false
    }
    
    func isChangedHigher(threshold: Float, value: Float, changed: Bool) -> Bool {
        if (value > threshold) {
            return !changed
        }
        return false
    }
    
}
