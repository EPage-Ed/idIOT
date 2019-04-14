//
//  BeaconView.swift
//  idIOT
//
//  Created by Edward Arenberg on 4/13/19.
//  Copyright © 2019 Edward Arenberg. All rights reserved.
//

import UIKit



extension UIView {
    public class func instantiateViewFromNib<T>(_ nibName: String, inBundle bundle: Bundle = Bundle.main) -> T? {
        if let objects = bundle.loadNibNamed(nibName, owner: nil) {
            for object in objects {
                if let object = object as? T {
                    return object
                }
            }
        }
        return nil
    }
}


/*
protocol XibDesignable : class {}

extension XibDesignable where Self : UIView {
    
    static func instantiateFromXib() -> Self {
        
        let dynamicMetatype = Self.self
        let bundle = Bundle(for: dynamicMetatype)
        let nib = UINib(nibName: "\(dynamicMetatype)", bundle: bundle)
        
        guard let view = nib.instantiate(withOwner: nil, options: nil).first as? Self else {
            
            fatalError("Could not load view from nib file.")
        }
        return view
    }
}

extension UIView : XibDesignable {}
*/




// MARK: - Protocol Declaration

public protocol InterfaceBuilderInstantiable {
    /// The UINib that contains the view
    ///
    /// Defaults to the swift class name if not implemented
    static var associatedNib : UINib { get }
}

// MARK: - Default Implementation

extension InterfaceBuilderInstantiable {
    /// Creates a new instance from the associated Xib
    ///
    /// - Returns: A new instance of this object loaded from xib
    static func instantiateFromInterfaceBuilder() -> Self {
        return associatedNib.instantiate(withOwner:nil, options: nil)[0] as! Self
    }
    
    static var associatedNib : UINib {
        let name = String(describing: self)
        return UINib(nibName: name, bundle: Bundle.main)
    }
}






class EmbeddedBeaconView : BeaconView {
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let v = (UIView.instantiateViewFromNib("BeaconView") as BeaconView?)!
        v.translatesAutoresizingMaskIntoConstraints = false
        return v as Any
    }
}

class BeaconView: UIView { // }, InterfaceBuilderInstantiable {
    
    @IBOutlet weak var w0: UIImageView!
    @IBOutlet weak var w1: UIImageView!
    @IBOutlet weak var w2: UIImageView!
    @IBOutlet weak var w3: UIImageView!

    /*
    override func awakeAfter(using aDecoder: NSCoder) -> Any? {
        let v = (UIView.instantiateViewFromNib("BeaconView") as BeaconView?)!
        v.translatesAutoresizingMaskIntoConstraints = false
        return v as Any
    }
     */
    
    enum State {
        case off, on, animate
    }
    private var animState = 0 {
        didSet {
            switch animState {
            case 0:
                w0.alpha = 1; w1.alpha = 0.2; w2.alpha = 0.2; w3.alpha = 0.2
            case 1:
                w0.alpha = 1; w1.alpha = 1; w2.alpha = 0.2; w3.alpha = 0.2
            case 2:
                w0.alpha = 1; w1.alpha = 1; w2.alpha = 1; w3.alpha = 0.2
            case 3:
                w0.alpha = 1; w1.alpha = 1; w2.alpha = 1; w3.alpha = 1
            default:
                w0.alpha = 1; w1.alpha = 1; w2.alpha = 1; w3.alpha = 1
            }
        }
    }
    
    @IBInspectable var isAnimating : Bool = false {
        didSet {
            state = isAnimating ? .animate : .on
        }
    }
    var isOn : Bool = false {
        didSet {
            isAnimating = false
            state = isOn ? .on : .off
        }
    }
    
    private var state : State = .on {
        didSet {
            switch state {
            case .on:
                animate(active: false)
                w0.alpha = 1; w1.alpha = 1; w2.alpha = 1; w3.alpha = 1
            case .off:
                animate(active: false)
                w0.alpha = 0.2; w1.alpha = 0.2; w2.alpha = 0.2; w3.alpha = 0.2
            case .animate:
                animState = 0
                animate()
            }
        }
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        translatesAutoresizingMaskIntoConstraints = false
    }
    
    deinit {
        animate(active: false)
    }
    
    private var timer : Timer?
    private func animate(active:Bool = true) {
        if !active { timer?.invalidate(); timer = nil; return }
        if timer?.isValid ?? false { return }
        timer = Timer(timeInterval: 0.2, repeats: true, block: {[weak self] timer in
            guard let this = self else { return }
            let new = this.animState + 1
            this.animState = new > 3 ? 0 : new
        })
        RunLoop.main.add(timer!, forMode: RunLoop.Mode.common)
    }
    
    /*
     // Only override draw() if you perform custom drawing.
     // An empty implementation adversely affects performance during animation.
     override func draw(_ rect: CGRect) {
     // Drawing code
     }
     */
    
}

