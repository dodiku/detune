## 👨‍🎤 detune: A TrueDepth Music Experience for iOS

detune uses Apple's ARKit and the TrueDepth camera (currently available only on iPhone X) to trigger music events.

This app is the second part of the serious of works about body motion sensing and deep learning by [Or Fleisher](https://github.com/juniorxsound) and [Dror Ayalon](https://github.com/dodiku).
Many thanks to [Djordje Jovic](https://github.com/DZoki019), who collaborated with us on this project.

![detune app for ios](media/detune_gif.gif)

#### Installation
To build the project:
1. [Make sure you have CocoaPods installed on your machine](https://guides.cocoapods.org/using/getting-started.html).
1. Clone this repo:
```bash
$ git clone https://github.com/dodiku/detune.git
```
1. Go to the repo directory and install the Pods:
```bash
$ pods install
```
1. Open the project using the workspace file: ``Face_Music.xcworkspace``.  
Don't use the regular .xcodeproj file, because the CocoaPods won't be imported.

#### ARFaceAnchor
We mapped [all available face anchors](https://developer.apple.com/documentation/arkit/arfaceanchor) on ARKit. You can find this list on the Xcode project:
```
    "browDown_L" = "0.3815315";
    "browDown_R" = "0.2073889";
    browInnerUp = "0.1224418";
    "browOuterUp_L" = "0.008707054";
    "browOuterUp_R" = "0.008803191";
    cheekPuff = "0.125112";
    "cheekSquint_L" = "0.05781135";
    "cheekSquint_R" = "0.04599116";
    "eyeBlink_L" = "0.3445343";
    "eyeBlink_R" = "0.3127538";
    "eyeLookDown_L" = "0.5816696";
    "eyeLookDown_R" = "0.5852559";
    "eyeLookIn_L" = "0.2213968";
    "eyeLookIn_R" = "0.006743086";
    "eyeLookOut_L" = 0;
    "eyeLookOut_R" = "0.1171228";
    "eyeLookUp_L" = 0;
    "eyeLookUp_R" = 0;
    "eyeSquint_L" = "0.08445973";
    "eyeSquint_R" = "0.08384438";
    "eyeWide_L" = 0;
    "eyeWide_R" = 0;
    jawForward = "0.01445009";
    jawLeft = 0;
    jawOpen = "0.0157577";
    jawRight = "0.1080877";
    mouthClose = "0.009313466";
    "mouthDimple_L" = "0.2224835";
    "mouthDimple_R" = "0.1474445";
    "mouthFrown_L" = "0.04537645";
    "mouthFrown_R" = "0.005555572";
    mouthFunnel = "0.08351783";
    mouthLeft = 0;
    "mouthLowerDown_L" = "0.03919506";
    "mouthLowerDown_R" = "0.0418412";
    "mouthPress_L" = "0.3729359";
    "mouthPress_R" = "0.266792";
    mouthPucker = "0.1735668";
    mouthRight = "0.03223318";
    mouthRollLower = "0.0900835";
    mouthRollUpper = "0.03778011";
    mouthShrugLower = "0.2469705";
    mouthShrugUpper = "0.1147914";
    "mouthSmile_L" = 0;
    "mouthSmile_R" = "0.00791786";
    "mouthStretch_L" = "0.09616662";
    "mouthStretch_R" = "0.08395615";
    "mouthUpperUp_L" = "0.1006967";
    "mouthUpperUp_R" = "0.09581342";
    "noseSneer_L" = "0.08572538";
    "noseSneer_R" = "0.06606565";
```

### Thanks
- Many thanks to the [AudioKit](https://github.com/AudioKit/AudioKit) guys, who supported us along the way and helped us overcome many obstacles.
- Many thanks to [Roi Lev](https://github.com/roilev) who helped us with hardware hacking.
