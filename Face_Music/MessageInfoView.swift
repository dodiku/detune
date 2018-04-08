//
//  MessageInfoView.swift
//  Face_Music
//
//  Created by Djordje Jovic on 3/18/18.
//  Copyright © 2017 Or Fleisher. All rights reserved.
//

import UIKit

class MessageInfoView: UIView
{
    static let sharedInstance = MessageInfoView()
    
    //// UI
    private let textLabel = UILabel()
    
    //// Layout
    private var viewInvisibleConstraint: NSLayoutConstraint?
    private var viewVisibleConstraint: NSLayoutConstraint?
    
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
            self.viewVisibleConstraint = self.topAnchor.constraint(equalTo: view.topAnchor)
            self.viewInvisibleConstraint = self.bottomAnchor.constraint(equalTo: view.topAnchor, constant:-10)
            self.viewInvisibleConstraint?.isActive = true
            self.leftAnchor.constraint(equalTo: view.leftAnchor).isActive = true
            self.rightAnchor.constraint(equalTo: view.rightAnchor).isActive = true
        }
        self.backgroundColor = .black
//        self.layer.shadowColor = UIColor.black.cgColor
//        self.layer.shadowRadius = 3
//        self.layer.shadowOffset = CGSize.init(width: 0, height: 3)
//        self.layer.shadowOpacity = 1
        
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
        let paragraphStyle = NSMutableParagraphStyle()
        paragraphStyle.lineSpacing = 12
        let attrString = NSMutableAttributedString(string: "We’re sorry, detune is supported only on phones with TrueDepth Camera 🤕.")
        attrString.addAttribute(.paragraphStyle, value:paragraphStyle, range:NSMakeRange(0, attrString.length))
        self.textLabel.attributedText = attrString
        
        (UIApplication.shared.delegate as! AppDelegate).window2?.rootViewController?.view.layoutIfNeeded()
    }
    
    func present() -> Void {
        
        UIView.animate(withDuration: 1, animations: {
            self.viewInvisibleConstraint?.isActive = false
            self.viewVisibleConstraint?.isActive = true
            (UIApplication.shared.delegate as! AppDelegate).window2?.rootViewController?.view.layoutIfNeeded()
//            DispatchQueue.main.asyncAfter(deadline: .now() + 5, execute: {
//                MessageInfoView.sharedInstance.dismiss()
//            })
            
        })
    }
    
    func dismiss() -> Void {
        UIView.animate(withDuration: 1, animations: {
            self.viewVisibleConstraint?.isActive = false
            self.viewInvisibleConstraint?.isActive = true
            
            (UIApplication.shared.delegate as! AppDelegate).window2?.rootViewController?.view.layoutIfNeeded()
        })
    }
}

