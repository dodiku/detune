//
//  MessageView.swift
//  Face_Music
//
//  Created by Djordje Jovic on 4/15/18.
//  Copyright © 2017 Or Fleisher. All rights reserved.
//
import UIKit

class RecordingSessionView: UIView
{
    static let sharedInstance = RecordingSessionView()
    
    //// UI
    private var customWindow: UIWindow?
    private let textLabel = UILabel()
    
    //// Layout
    private var viewInvisibleConstraint: NSLayoutConstraint?
    private var viewVisibleConstraint: NSLayoutConstraint?
    
    //// Other
    private var timer: Timer?
    private var timerCount: TimeInterval = 0
    private var isPresented = false
    
    override init(frame: CGRect)
    {
        super.init(frame: frame)
        self.commonInit()
    }
    
    required init?(coder aDecoder: NSCoder)
    {
        super.init(coder: aDecoder)
        self.commonInit()
    }
    
    func commonInit() -> Void
    {
        self.customWindow = UIWindow.init(frame: ((UIApplication.shared.delegate as! AppDelegate).window?.frame)!)
        customWindow?.backgroundColor = .clear
        customWindow?.windowLevel = UIWindowLevelStatusBar
        customWindow?.rootViewController = UIViewController()
        customWindow?.isHidden = false
        
        self.backgroundColor = UIColor.init(red: 252 / 255.0, green: 61 / 255.0, blue: 57 / 255.0, alpha: 1.0)
        
        if let view = customWindow?.rootViewController?.view {
            view.addSubview(self)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.heightAnchor.constraint(equalToConstant: 60).isActive = true
            self.viewVisibleConstraint = self.topAnchor.constraint(equalTo: view.topAnchor)
            self.viewInvisibleConstraint = self.bottomAnchor.constraint(equalTo: view.topAnchor, constant:-10)
            self.viewInvisibleConstraint?.isActive = true
            self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
            
            
            self.addSubview(textLabel)
            textLabel.translatesAutoresizingMaskIntoConstraints = false
            textLabel.centerXAnchor.constraint(equalTo: self.centerXAnchor).isActive = true
            textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant: -5).isActive = true
            textLabel.textColor = .white
            textLabel.text = "Recording 00:00"
            
            customWindow?.rootViewController?.view.layoutIfNeeded()
        }
    }
    
    func present() -> Void {
        guard !isPresented else {
            return
        }
        isPresented = true
        
        self.timerCount = 0
        textLabel.text = "Recording 00:00"
        
        self.timer = Timer.scheduledTimer(withTimeInterval: 1.0, repeats: true, block: { (timer) in
            self.timerCount = self.timerCount + timer.timeInterval
            let minutesString = String(format: "%02d", Int(self.timerCount / 60))
            let secondsString = String(format: "%02d", Int(self.timerCount.truncatingRemainder(dividingBy: 60)))
            self.textLabel.text = "Recording \(minutesString):\(secondsString)"
        })
        
        UIView.animate(withDuration: 1, animations: {
            self.viewInvisibleConstraint?.isActive = false
            self.viewVisibleConstraint?.isActive = true
            self.customWindow?.rootViewController?.view.layoutIfNeeded()
        })
    }
    
    func dismiss() -> Void {
        guard isPresented else {
            return
        }
        isPresented = false
        
        self.timer?.invalidate()
        
        UIView.animate(withDuration: 1, animations: {
            self.viewVisibleConstraint?.isActive = false
            self.viewInvisibleConstraint?.isActive = true
            
            self.customWindow?.rootViewController?.view.layoutIfNeeded()
        })
    }
}
