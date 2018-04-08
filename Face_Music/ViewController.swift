//
//  ViewController.swift
//  Face_Music
//
//  Copyright © 2017 Or Fleisher and Dror Ayalon (NYU, ITP). All rights reserved.
//

import UIKit
import SceneKit
import ARKit
import AudioKit
import ReplayKit

class ViewController: UIViewController, ARSCNViewDelegate, RPPreviewViewControllerDelegate {
    ///////////////////////////
    ///////////////////////////
    ///////UI Debug////////////
    let productionMode = true
    ///////////////////////////
    
    var recordButton : RecordButton!
    
    //States
    var hasFace : Bool = false;
    var eyeWasClosed : Bool = false;
    var eyeIsClosed : Bool = false;
    
    //Feature treshholds
    var blinkTresh : Float = 0.8
    
    //Singleton to manage the synth
    var soundManger : SynthController!
    
    @IBOutlet var sceneView: ARSCNView!
    
    
    override open var shouldAutorotate: Bool {
        return false
    }

    @IBOutlet weak var debugView: UIView!
    let logoImageView = UIImageView()
    
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        debugView.isHidden = productionMode
        
        guard (ARFaceTrackingConfiguration.isSupported) else {
            MessageInfoView.sharedInstance.present()
            //            MessageView.sharedInstance.present()
            return
        }
        
        soundManger = SynthController()
        
        
        // Set the view's delegate
        sceneView.delegate = self
        
        // Show statistics such as fps and timing information
        sceneView.showsStatistics = false
        
        // Create a new scene
        let scene = SCNScene()
        
        //Assign the scene to the self.sceneView
        sceneView.scene = scene
        
        
        //Make the debug transperent on the camera feed
        debugView.backgroundColor = UIColor.clear
        debugView.isOpaque = false
        
        //A poor man's AKSequncer!
        self.soundManger.beatPlayer.completionHandler = ({
            print("loop dubious!")
            if self.soundManger.mainMixer.isPlaying {
                self.soundManger.beatPlayer.play()
            }
        })
        
        self.setupUI()
    }
    
    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        // Face tracking session
        self.resetTracking()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)
        
        // Pause the view's session
        sceneView.session.pause()
    }
    
    func setupUI() -> Void {
        
        let window = (UIApplication.shared.delegate as! AppDelegate).window2
        
        self.recordButton = RecordButton()
        window?.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.bottomAnchor.constraint(equalTo: window!.layoutMarginsGuide.bottomAnchor, constant: -20).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: window!.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        recordButton.addTarget(self, action: #selector(toggleRecording(_:)), for: .touchUpInside)
        
        self.view.addSubview(self.logoImageView)
        self.logoImageView.translatesAutoresizingMaskIntoConstraints = false
        self.logoImageView.image = UIImage.init(named: "watermark")
        self.logoImageView.contentMode = .scaleAspectFit
        self.logoImageView.leftAnchor.constraint(equalTo: self.view.leftAnchor, constant: 16).isActive = true
        self.logoImageView.bottomAnchor.constraint(equalTo: self.view.bottomAnchor, constant: -16).isActive = true
        self.logoImageView.rightAnchor.constraint(lessThanOrEqualTo: self.view.centerXAnchor, constant: -50).isActive = true
        self.logoImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        self.logoImageView.heightAnchor.constraint(equalTo: self.logoImageView.widthAnchor).isActive = true
        self.logoImageView.isHidden = true
    }
    
    //MARK:- Gestures
    
    @IBAction func StartRecord(_ sender: UIButton) {
        self.startRecording()
    }
    
    @IBAction func StopRecording(_ sender: UIButton) {
        self.stopRecording()
    }
    @IBAction func SliderMoved(_ sender: UISlider) {
        let tag : Int = sender.tag
        let value : Float = sender.value
        
        self.debugSlider(_tag: tag, _value: value)
    }
    
    @IBAction func ButtonPressed(_ sender: UIButton) {
        let tag : Int = sender.tag
        self.debugButton(_tag: tag)
    }
    
    @objc func toggleRecording(_ button : RecordButton) -> Void {
        if button.isRecording {
            button.isRecording = false
            self.startRecording()
        } else {
            self.stopRecording()
        }
    }
    
    @objc func startRecording() {
        let recorder = RPScreenRecorder.shared()
        print("RECORDING")
        recorder.startRecording{ [unowned self] (error) in
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    self.recordButton.isRecording = true
                    self.logoImageView.isHidden = false
                }
            }
        }
    }
    
    @objc func stopRecording() {
        self.logoImageView.isHidden = true
        let recorder = RPScreenRecorder.shared()
        print("STOPPING")
        recorder.stopRecording { [unowned self] (previewController, error) in
            (UIApplication.shared.delegate as! AppDelegate).window2?.isHidden = true
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            }
            if let unwrappedPreviewController = previewController {
                do {
                    try AudioKit.stop()
                } catch {
                    print(error)
                }
                
                self.soundManger.mainMixer.stop()
                unwrappedPreviewController.previewControllerDelegate = self
                unwrappedPreviewController.title = "detune"
                self.present(unwrappedPreviewController, animated: true)
            }
        }
    }
    
    //MARK: - RPPreviewViewControllerDelegate
    
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
        (UIApplication.shared.delegate as! AppDelegate).window2?.isHidden = false
        
        do {
            try AudioKit.start()
        } catch {
            print(error)
        }
        soundManger = SynthController()
        self.soundManger.beatPlayer.completionHandler = ({
            print("loop dubious!")
            if self.soundManger.mainMixer.isPlaying {
                self.soundManger.beatPlayer.play()
            }
        })
    }
    
    //MARK: -
    
    
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {
        
        //Try and find face features
        guard let faceAnchor = anchor as? ARFaceAnchor else{
            
            //If we had a face, now we lost it
            if(hasFace){ hasFace = false }
            
            return
            
        }
        
        //If we didn't have a face but now we do
        if (!hasFace){
            hasFace = true
            self.resetTracking()
        }
        
        // GETTING ALL THE VALUES
        
        let jawOpen = faceAnchor.blendShapes[.jawOpen] as! Double
        let mouthFunnel = faceAnchor.blendShapes[.mouthFunnel] as! Float
        let leftEyeBlink = faceAnchor.blendShapes[.eyeBlinkLeft] as? Float
        let rightEyeBlink = faceAnchor.blendShapes[.eyeBlinkRight] as? Float
        let eyeLookUp_L = faceAnchor.blendShapes[.eyeLookUpLeft] as! Float
        let eyeLookUp_R = faceAnchor.blendShapes[.eyeLookUpRight] as! Float
        let eyeLookDown_L = faceAnchor.blendShapes[.eyeLookDownLeft] as! Float
        let eyeLookDown_R = faceAnchor.blendShapes[.eyeLookDownRight] as! Float
        let eyeLookOut_L = faceAnchor.blendShapes[.eyeLookOutLeft] as! Float
        let eyeLookOut_R = faceAnchor.blendShapes[.eyeLookOutRight] as! Float
        let noseSneerLeft = faceAnchor.blendShapes[.noseSneerLeft] as! Float
        let noseSneerRight = faceAnchor.blendShapes[.noseSneerLeft] as! Float
        let browInnerUp = faceAnchor.blendShapes[.browInnerUp] as! Float
        let mouthStretchRight = faceAnchor.blendShapes[.mouthStretchRight] as! Float
        let mouthStretchLeft = faceAnchor.blendShapes[.mouthStretchLeft] as! Float
        let mouthDimpleRight = faceAnchor.blendShapes[.mouthDimpleRight] as! Float
        let mouthDimpleLeft = faceAnchor.blendShapes[.mouthDimpleLeft] as! Float
        let mouthFrownRight = faceAnchor.blendShapes[.mouthFrownRight] as! Float
        let mouthFrownLeft = faceAnchor.blendShapes[.mouthFrownLeft] as! Float
        let mouthSmileRight = faceAnchor.blendShapes[.mouthSmileRight] as! Float
        let mouthSmileLeft = faceAnchor.blendShapes[.mouthSmileLeft] as! Float
        
        
        
        // blink right
        if(leftEyeBlink! > blinkTresh){
            let blinkRightChange = self.soundManger.isChangedHigher(threshold: blinkTresh, value: leftEyeBlink!, changed: self.soundManger.setRightBlinkChanged)
            if (blinkRightChange == true) {
                self.soundManger.leftEye.play()
                self.soundManger.setRightBlinkChanged = true
            }
        } else {
            self.soundManger.setRightBlinkChanged = false
        }
        
        // blink left
        if(rightEyeBlink! > blinkTresh){
            let blinkLeftChange = self.soundManger.isChangedHigher(threshold: blinkTresh, value: leftEyeBlink!, changed: self.soundManger.setLeftBlinkChanged)
            if (blinkLeftChange == true) {
                self.soundManger.leftEye.play()
                self.soundManger.setLeftBlinkChanged = true
            }
        } else {
            self.soundManger.setLeftBlinkChanged = false
        }
        
        // blinking 2 eyes
        if(rightEyeBlink! > blinkTresh && leftEyeBlink! > blinkTresh) {
            let beatChange = self.soundManger.isChangedHigher(threshold: blinkTresh, value: rightEyeBlink!, changed: self.soundManger.setBeatChange)
            if (beatChange == true) {
                if (self.soundManger.beatPlayer.volume == 0.0) {
                    self.soundManger.beatPlayer.volume = self.soundManger.currentAmplitude * 0.5
                } else {
//                    self.soundManger.beatPlayer.volume = 0.0
                }
                self.soundManger.setLeftBlinkChanged = true
            }
        } else {
            self.soundManger.setLeftBlinkChanged = false
        }
        
        // eyeLookUp_L || eyeLookUp_R
        if(eyeLookUp_L > 0.4 || eyeLookUp_R > 0.4){
            // 🙀
            var newNote: Double = self.soundManger.pianoNote.frequency
            while (newNote == self.soundManger.pianoNote.frequency) {
                newNote = self.soundManger.phrygianDispostion.randomElement().midiNoteToFrequency()
            }
            self.soundManger.pianoNote.trigger(frequency: newNote)
        }
        
        // -----> synth issue •••••
        // eyeLookDown_L || eyeLookDown_R
        if(eyeLookDown_L > 0.65 || eyeLookDown_R > 0.65){
            self.soundManger.drumBank.play(noteNumber: 68, velocity: 70)
            self.soundManger.drumBank.play(noteNumber: 64, velocity: 115)
        } else {
            self.soundManger.drumBank.stop(noteNumber: 68)
            self.soundManger.drumBank.stop(noteNumber: 64)
        }
        
        
        // -----> synth issue •••••
        // loop out
        if(eyeLookOut_L > 0.55 || eyeLookOut_R > 0.55){
            let lookOutChange = self.soundManger.isChangedHigher(threshold: 0.55, value: eyeLookOut_L, changed: self.soundManger.setLookOutChanged)
            if (lookOutChange == true) {
                self.soundManger.eyeSide.play()
                self.soundManger.setLookOutChanged = true
            }
        } else {
            self.soundManger.setLookOutChanged = false
        }
        
        
        
        // nose sneer
        // -----> this is weird and not consistent •••••
        if (noseSneerRight > 0.4 || noseSneerLeft > 0.4) {
            let noseChange = self.soundManger.isChangedHigher(threshold: 0.55, value: eyeLookOut_L, changed: self.soundManger.setNoseChanged)
            if (noseChange == true) {
                self.soundManger.mainWah.shift = Double(2)
                self.soundManger.setNoseChanged = true
            }
            } else {
                self.soundManger.setNoseChanged = false
        }
        

        // jawOpen
        self.soundManger.baseSynthFilter.cutoffFrequency = jawOpen*6000.0+100.0
        self.soundManger.baseSynthFilter.resonance = jawOpen*5
        
        
        // mouthFunnel
        // 🙀
        
        // mouth movement
        if (mouthSmileLeft > 0.7 && mouthSmileRight > 0.7) {
            let smileChange = self.soundManger.isChangedHigher(threshold: 0.55, value: mouthSmileRight, changed: self.soundManger.setSmileSoundChange)
            if (smileChange == true) {
                self.soundManger.smileSound.play()
                self.soundManger.setSmileSoundChange = true
            }
        } else {
            self.soundManger.setSmileSoundChange = false
        }
        
        
        
        // brows
        // 🙀
        
    }
    
    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user
        
    }
    func handleFaceData(){
        
        
    }

    
    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay
        
    }
    
    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required
        
    }
    
    func setupFaceNodeContent(){
    
    
    }
    
}

////////////////////////////////////
/////////////Utilities//////////////
////////////////////////////////////

// Reset the tracking on face lost
extension ViewController {
    
    func resetTracking(){
        
        print("Starting a new session")
        
        //New configuration for face tracking
        guard ARFaceTrackingConfiguration.isSupported else {
            //TODO: Add some sort of fallback screen (we only support iOS 11+ on iPhone X
            let configuration = ARWorldTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            self.sceneView.session.run(configuration)
            return
            
        }
        
        //If the guard didn't fail start an ARFaceSession
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        self.sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }
    
    func debugSlider(_tag: Int, _value: Float){
        if(_tag == 0){
            // 🙀
            
        } else if(_tag == 5) {
            // 🙀
            
        } else if(_tag == 2){
            // 🙀
            
        } else if(_tag == 1){
            // 🙀
            
        } else if(_tag == 3){
            
            if(_value > 0.8){
                self.soundManger.mainWah.shift = Double(2)
            } else {
                self.soundManger.mainWah.shift = 0.0
            }
            
        } else if (_tag == 6){
            // 🙀
            
            
        } else if (_tag == 7) {
            // 🙀
            
        } else if (_tag == 8) {
            if(_value > 0.4){
                var newNote: Double = self.soundManger.pianoNote.frequency
                while (newNote == self.soundManger.pianoNote.frequency) {
                    newNote = self.soundManger.phrygianDispostion.randomElement().midiNoteToFrequency()
                }
                self.soundManger.pianoNote.trigger(frequency: newNote)
            }
        } else if (_tag == 9) {
            if(_value > 0.55){
                let lookOutChanged = self.soundManger.isChangedHigher(threshold: 0.55, value: _value, changed: self.soundManger.setLookOutChanged)
                if (lookOutChanged == true) {
                    self.soundManger.drumBank.play(noteNumber: 68, velocity: 70)
                    self.soundManger.drumBank.play(noteNumber: 64, velocity: 115)
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {
                        timer in
                        self.soundManger.drumBank.stop(noteNumber: 68)
                        self.soundManger.drumBank.stop(noteNumber: 64)
                    })
                    self.soundManger.setLookOutChanged = true
                }
            } else {
                self.soundManger.setLookOutChanged = false
            }
        }
        
    }
    
    func debugButton(_tag: Int){
        if(_tag == 0){ // ---> this button was deleted :\
            // 🙀
            
        } else if(_tag == 1){ // ---> this button was deleted :\
            var newNote: Double = self.soundManger.pianoNote.frequency
            while (newNote == self.soundManger.pianoNote.frequency) {
                newNote = self.soundManger.phrygianDispostion.randomElement().midiNoteToFrequency()
            }
            self.soundManger.pianoNote.trigger(frequency: newNote)
            
        } else if(_tag == 2){ // ---> this button was deleted :\
            // 🙀
            
        } else if(_tag == 3){ // ---> this button was deleted :\
            self.soundManger.drumBank.play(noteNumber: 68, velocity: 70)
            self.soundManger.drumBank.play(noteNumber: 64, velocity: 115)
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: {
                timer in
                self.soundManger.drumBank.stop(noteNumber: 68)
                self.soundManger.drumBank.stop(noteNumber: 64)
            })
        } else if (_tag == 10) {
            if (self.soundManger.beatPlayer.isStarted == true) {
                self.soundManger.beatPlayer.stop()
            } else {
                self.soundManger.beatPlayer.start()
            }
        }
        
    }
        
    
}
