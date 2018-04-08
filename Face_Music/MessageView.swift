//
//  MessageView.swift
//  Face_Music
//
//  Created by Djordje Jovic on 3/22/18.
//  Copyright © 2017 Or Fleisher. All rights reserved.
//

import UIKit

class MessageView: UIView
{
    static let sharedInstance = MessageView()
    
    //// UI
    private let textLabel = UILabel()
    private var isAnimating = false
    
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
        if let view = (UIApplication.shared.delegate as! AppDelegate).window2?.rootViewController?.view {
            view.addSubview(self)
            
            self.translatesAutoresizingMaskIntoConstraints = false
            self.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
            self.centerYAnchor.constraint(equalTo: view.centerYAnchor).isActive = true
            self.widthAnchor.constraint(lessThanOrEqualTo: view.widthAnchor, multiplier: 0.8).isActive = true
            
            view.addGestureRecognizer(UITapGestureRecognizer.init(target: self, action: #selector(viewTapped)))
        }
        self.isUserInteractionEnabled = false
        self.backgroundColor = .black
        self.layer.shadowColor = UIColor.black.cgColor
        self.layer.shadowRadius = 3
        self.layer.shadowOpacity = 1
        self.layer.cornerRadius = 10
        
        let inset : CGFloat = 30
        
        self.addSubview(self.textLabel)
        self.textLabel.translatesAutoresizingMaskIntoConstraints = false
        self.textLabel.topAnchor.constraint(equalTo: self.topAnchor, constant:inset).isActive = true
        self.textLabel.leftAnchor.constraint(equalTo: self.leftAnchor, constant:inset).isActive = true
        self.textLabel.bottomAnchor.constraint(equalTo: self.bottomAnchor, constant:-inset).isActive = true
        self.textLabel.rightAnchor.constraint(equalTo: self.rightAnchor, constant:-inset).isActive = true
        self.textLabel.textColor = .white
        self.textLabel.font = UIFont.systemFont(ofSize: 18)
        self.textLabel.numberOfLines = 0
        self.textLabel.text = "We’re sorry, detune is supported only on phones with TrueDepth Camera"
        
        self.alpha = 0
        self.isHidden = true
        (UIApplication.shared.delegate as! AppDelegate).window2?.rootViewController?.view.layoutIfNeeded()
    }
    
    @objc func viewTapped() -> Void {
        self.dismiss()
    }
    
    func present() -> Void {
        guard !isAnimating else {
            return
        }
        self.isAnimating = true
        self.isHidden = false
        UIView.animate(withDuration: 1, animations: {
            self.alpha = 1
        }) { (success) in
            self.isAnimating = false
        }
    }
    
    func dismiss() -> Void {
        guard !isAnimating else {
            return
        }
        self.isAnimating = true
        UIView.animate(withDuration: 1, animations: {
            self.alpha = 0
        }) { (success) in
            self.isHidden = true
            self.isAnimating = false
        }
    }
}


