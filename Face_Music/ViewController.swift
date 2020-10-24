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

    var recordButton: RecordButton!

    //States
    var hasFace: Bool = false
    var eyeWasClosed: Bool = false
    var eyeIsClosed: Bool = false

    //Feature treshholds
    var blinkTresh: Float = 0.8

    //Singleton to manage the synth
    var soundManger: SynthController!

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
        soundManger.beatPlayer.completionHandler = ({ [unowned self] in
            print("loop dubious!")
            
            if self.soundManger.mainMixer.isPlaying {
                self.soundManger.beatPlayer.play()
            }
        })

        setupUI()
    }

    override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)

        // Face tracking session
        resetTracking()
    }

    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        // Pause the view's session
        sceneView.session.pause()
    }

    func setupUI() -> Void {

        let window = (UIApplication.shared.delegate as! AppDelegate).window2

        recordButton = RecordButton()
        window?.addSubview(recordButton)
        recordButton.translatesAutoresizingMaskIntoConstraints = false
        recordButton.bottomAnchor.constraint(equalTo: window!.layoutMarginsGuide.bottomAnchor, constant: -20).isActive = true
        recordButton.centerXAnchor.constraint(equalTo: window!.centerXAnchor).isActive = true
        recordButton.widthAnchor.constraint(equalToConstant: 60).isActive = true
        recordButton.heightAnchor.constraint(equalToConstant: 60).isActive = true
        recordButton.addTarget(self, action: #selector(toggleRecording(_:)), for: .touchUpInside)

        view.addSubview(logoImageView)
        logoImageView.translatesAutoresizingMaskIntoConstraints = false
        logoImageView.image = UIImage.init(named: "watermark")
        logoImageView.contentMode = .scaleAspectFit
        logoImageView.leftAnchor.constraint(equalTo: view.leftAnchor, constant: 16).isActive = true
        logoImageView.bottomAnchor.constraint(equalTo: view.bottomAnchor, constant: -16).isActive = true
        logoImageView.rightAnchor.constraint(lessThanOrEqualTo: view.centerXAnchor, constant: -50).isActive = true
        logoImageView.widthAnchor.constraint(equalToConstant: 80).isActive = true
        logoImageView.heightAnchor.constraint(equalTo: logoImageView.widthAnchor).isActive = true
        logoImageView.isHidden = true
    }
}

//MARK:- Gestures
extension ViewController {
        
    @IBAction func StartRecord(_ sender: UIButton) {
        startRecording()
    }

    @IBAction func StopRecording(_ sender: UIButton) {
        stopRecording()
    }
    @IBAction func SliderMoved(_ sender: UISlider) {
        let tag: Int = sender.tag
        let value: Float = sender.value

        debugSlider(_tag: tag, _value: value)
    }

    @IBAction func ButtonPressed(_ sender: UIButton) {
        let tag: Int = sender.tag
        debugButton(_tag: tag)
    }

    @objc func toggleRecording(_ button: RecordButton) -> Void {
        if button.isRecording {
            button.isRecording = false
            startRecording()
        } else {
            stopRecording()
        }
    }

    @objc func startRecording() {
        print("RECORDING")
        RPScreenRecorder.shared().startRecording { [weak self] (error) in
            guard let self = self else { return }
            
            if let unwrappedError = error {
                print(unwrappedError.localizedDescription)
            } else {
                DispatchQueue.main.async {
                    RecordingSessionView.sharedInstance.present()
                }

                DispatchQueue.main.async {
                    self.recordButton.isRecording = true
                    self.logoImageView.isHidden = false
                }
            }
        }
    }

    @objc func stopRecording() {
        logoImageView.isHidden = true
        print("STOPPING")
        RPScreenRecorder.shared().stopRecording { [unowned self] (previewController, error) in
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
                DispatchQueue.main.async {
                    RecordingSessionView.sharedInstance.dismiss()
                }
                unwrappedPreviewController.previewControllerDelegate = self
                unwrappedPreviewController.title = "detune"
                self.present(unwrappedPreviewController, animated: true)
            }
        }
    }
}

//MARK:- RPPreviewViewControllerDelegate
extension ViewController {
        
    func previewControllerDidFinish(_ previewController: RPPreviewViewController) {
        dismiss(animated: true)
        
        (UIApplication.shared.delegate as! AppDelegate).window2?.isHidden = false

        soundManger = SynthController()
        soundManger.beatPlayer.completionHandler = ({ [unowned self] in
            print("loop dubious!")
            if self.soundManger.mainMixer.isPlaying {
                self.soundManger.beatPlayer.play()
            }
        })
    }
}

//MARK:- SCNSceneRendererDelegate
extension ViewController {
    func renderer(_ renderer: SCNSceneRenderer, didUpdate node: SCNNode, for anchor: ARAnchor) {

        //Try and find face features
        guard let faceAnchor = anchor as? ARFaceAnchor else {

            //If we had a face, now we lost it
            if hasFace { hasFace = false }

            return

        }

        //If we didn't have a face but now we do
        if !hasFace {
            hasFace = true
            resetTracking()
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
        if leftEyeBlink! > blinkTresh {
            let blinkRightChange = soundManger.isChangedHigher(threshold: blinkTresh, value: leftEyeBlink!, changed: soundManger.setRightBlinkChanged)
            if (blinkRightChange == true) {
                soundManger.leftEye.play()
                soundManger.setRightBlinkChanged = true
            }
        } else {
            soundManger.setRightBlinkChanged = false
        }

        // blink left
        if rightEyeBlink! > blinkTresh {
            let blinkLeftChange = soundManger.isChangedHigher(threshold: blinkTresh, value: leftEyeBlink!, changed: soundManger.setLeftBlinkChanged)
            if (blinkLeftChange == true) {
                soundManger.leftEye.play()
                soundManger.setLeftBlinkChanged = true
            }
        } else {
            soundManger.setLeftBlinkChanged = false
        }

        // blinking 2 eyes
        if rightEyeBlink! > blinkTresh && leftEyeBlink! > blinkTresh {
            let beatChange = soundManger.isChangedHigher(threshold: blinkTresh, value: rightEyeBlink!, changed: soundManger.setBeatChange)
            if (beatChange == true) {
                if (soundManger.beatPlayer.volume == 0.0) {
                    soundManger.beatPlayer.volume = soundManger.currentAmplitude * 0.5
                } else {
//                    soundManger.beatPlayer.volume = 0.0
                }
                soundManger.setLeftBlinkChanged = true
            }
        } else {
            soundManger.setLeftBlinkChanged = false
        }

        // eyeLookUp_L || eyeLookUp_R
        if eyeLookUp_L > 0.4 || eyeLookUp_R > 0.4 {
            // 🙀
            var newNote: Double = soundManger.pianoNote.frequency
            while (newNote == soundManger.pianoNote.frequency) {
                newNote = soundManger.phrygianDispostion.randomElement()!.midiNoteToFrequency()
            }
            soundManger.pianoNote.trigger(frequency: newNote)
        }

        // -----> synth issue •••••
        // eyeLookDown_L || eyeLookDown_R
        if eyeLookDown_L > 0.65 || eyeLookDown_R > 0.65 {
            soundManger.drumBank.play(noteNumber: 68, velocity: 70)
            soundManger.drumBank.play(noteNumber: 64, velocity: 115)
        } else {
            soundManger.drumBank.stop(noteNumber: 68)
            soundManger.drumBank.stop(noteNumber: 64)
        }


        // -----> synth issue •••••
        // loop out
        if eyeLookOut_L > 0.55 || eyeLookOut_R > 0.55 {
            let lookOutChange = soundManger.isChangedHigher(threshold: 0.55, value: eyeLookOut_L, changed: soundManger.setLookOutChanged)
            if (lookOutChange == true) {
                soundManger.eyeSidePlayer.play()
                soundManger.setLookOutChanged = true
            }
        } else {
            soundManger.setLookOutChanged = false
        }



        // nose sneer
        // -----> this is weird and not consistent •••••
        if noseSneerRight > 0.4 || noseSneerLeft > 0.4 {
            let noseChange = soundManger.isChangedHigher(threshold: 0.55, value: eyeLookOut_L, changed: soundManger.setNoseChanged)
            if (noseChange == true) {
                soundManger.mainWah.shift = Double(2)
                soundManger.setNoseChanged = true
            }
        } else {
            soundManger.setNoseChanged = false
        }


        // jawOpen
        soundManger.baseSynthFilter.cutoffFrequency = jawOpen * 6000.0 + 100.0
        soundManger.baseSynthFilter.resonance = jawOpen * 5


        // mouthFunnel
        // 🙀

        // mouth movement
        if mouthSmileLeft > 0.7 && mouthSmileRight > 0.7 {
            let smileChange = soundManger.isChangedHigher(threshold: 0.55, value: mouthSmileRight, changed: soundManger.setSmileSoundChange)
            if (smileChange == true) {
                soundManger.smileSoundPlayer.play()
                soundManger.setSmileSoundChange = true
            }
        } else {
            soundManger.setSmileSoundChange = false
        }



        // brows
        // 🙀

    }

    func session(_ session: ARSession, didFailWithError error: Error) {
        // Present an error message to the user

    }


    func sessionWasInterrupted(_ session: ARSession) {
        // Inform the user that the session has been interrupted, for example, by presenting an overlay

    }

    func sessionInterruptionEnded(_ session: ARSession) {
        // Reset tracking and/or remove existing anchors if consistent tracking is required

    }

}

////////////////////////////////////
/////////////Utilities//////////////
////////////////////////////////////

// Reset the tracking on face lost
//MARK:-
extension ViewController {

    func resetTracking() {

        print("Starting a new session")

        //New configuration for face tracking
        guard ARFaceTrackingConfiguration.isSupported else {
            //TODO: Add some sort of fallback screen (we only support iOS 11+ on iPhone X
            let configuration = ARWorldTrackingConfiguration()
            configuration.isLightEstimationEnabled = true
            sceneView.session.run(configuration)
            return

        }

        //If the guard didn't fail start an ARFaceSession
        let configuration = ARFaceTrackingConfiguration()
        configuration.isLightEstimationEnabled = true
        sceneView.session.run(configuration, options: [.resetTracking, .removeExistingAnchors])
    }

    func debugSlider(_tag: Int, _value: Float) {
        if(_tag == 0) {
            // 🙀

        } else if(_tag == 5) {
            // 🙀

        } else if(_tag == 2) {
            // 🙀

        } else if(_tag == 1) {
            // 🙀

        } else if(_tag == 3) {

            if(_value > 0.8) {
                soundManger.mainWah.shift = Double(2)
            } else {
                soundManger.mainWah.shift = 0.0
            }

        } else if (_tag == 6) {
            // 🙀


        } else if (_tag == 7) {
            // 🙀

        } else if (_tag == 8) {
            if(_value > 0.4) {
                var newNote: Double = soundManger.pianoNote.frequency
                while (newNote == soundManger.pianoNote.frequency) {
                    newNote = soundManger.phrygianDispostion.randomElement()!.midiNoteToFrequency()
                }
                soundManger.pianoNote.trigger(frequency: newNote)
            }
        } else if (_tag == 9) {
            if(_value > 0.55) {
                let lookOutChanged = soundManger.isChangedHigher(threshold: 0.55, value: _value, changed: soundManger.setLookOutChanged)
                if (lookOutChanged == true) {
                    soundManger.drumBank.play(noteNumber: 68, velocity: 70)
                    soundManger.drumBank.play(noteNumber: 64, velocity: 115)
                    Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [weak self] timer in
                        self?.soundManger.drumBank.stop(noteNumber: 68)
                        self?.soundManger.drumBank.stop(noteNumber: 64)
                    })
                    soundManger.setLookOutChanged = true
                }
            } else {
                soundManger.setLookOutChanged = false
            }
        }

    }

    func debugButton(_tag: Int) {
        if(_tag == 0) { // ---> this button was deleted :\
            // 🙀

        } else if(_tag == 1) { // ---> this button was deleted :\
            var newNote: Double = soundManger.pianoNote.frequency
            while (newNote == soundManger.pianoNote.frequency) {
                newNote = soundManger.phrygianDispostion.randomElement()!.midiNoteToFrequency()
            }
            soundManger.pianoNote.trigger(frequency: newNote)

        } else if(_tag == 2) { // ---> this button was deleted :\
            // 🙀

        } else if(_tag == 3) { // ---> this button was deleted :\
            soundManger.drumBank.play(noteNumber: 68, velocity: 70)
            soundManger.drumBank.play(noteNumber: 64, velocity: 115)
            Timer.scheduledTimer(withTimeInterval: 0.1, repeats: false, block: { [weak self] timer in
                self?.soundManger.drumBank.stop(noteNumber: 68)
                self?.soundManger.drumBank.stop(noteNumber: 64)
            })
        } else if (_tag == 10) {
            if (soundManger.beatPlayer.isStarted == true) {
                soundManger.beatPlayer.stop()
            } else {
                soundManger.beatPlayer.start()
            }
        }

    }


}
