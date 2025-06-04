//
//  IBButton.swift
//  LuckyIB
//
//  Created by junky on 2024/5/25.
//

import UIKit

@IBDesignable
public class IBButton: UIButton {
    
    @IBInspectable var cornerRadius: CGFloat = 0 {
        didSet {
            layer.cornerRadius = cornerRadius
            layer.masksToBounds = cornerRadius > 0
        }
    }
    
    @IBInspectable var borderColor: UIColor = .clear {
        didSet {
            layer.borderColor = borderColor.cgColor
        }
    }
    
    @IBInspectable var borderWidth: CGFloat = 0 {
        didSet {
            layer.borderWidth = borderWidth
        }
    }
    
    @IBInspectable var shadowColor: UIColor = .clear {
        didSet {
            layer.shadowColor = shadowColor.cgColor
        }
    }
    
    @IBInspectable var shadowOffset: CGSize = .zero {
        didSet {
            layer.shadowOffset = shadowOffset
        }
    }
    
    @IBInspectable var shadowOpacity: Float = 0 {
        didSet {
            layer.shadowOpacity = shadowOpacity
        }
    }
    
    @IBInspectable var shadowRadius: CGFloat = 3 {
        didSet {
            layer.shadowRadius = shadowRadius
        }
    }
    
    
    @IBInspectable var titleColorForNormal: UIColor = .white {
        didSet {
            setTitleColor(titleColorForNormal, for: .normal)
        }
    }
    
    @IBInspectable var titleColorForSelected: UIColor = .white {
        didSet {
            setTitleColor(titleColorForSelected, for: .selected)
        }
    }
    
    @IBInspectable var titleColorForDisable: UIColor = .white {
        didSet {
            setTitleColor(titleColorForDisable, for: .disabled)
        }
    }
    
    @IBInspectable var titleForNormal: String = "" {
        didSet {
            setTitle(titleForNormal, for: .normal)
        }
    }
    
    @IBInspectable var titleForDisable: String = "" {
        didSet {
            setTitle(titleForDisable, for: .disabled)
        }
    }
    
    @IBInspectable var titleForSelected: String = "" {
        didSet {
            setTitle(titleForSelected, for: .selected)
        }
    }
    
    @IBInspectable var imageForNoraml: UIImage? {
        didSet {
            setImage(imageForNoraml, for: .normal)
        }
    }
    
    @IBInspectable var imageForSelected: UIImage? {
        didSet {
            setImage(imageForSelected, for: .selected)
        }
    }
    
    @IBInspectable var imageForDisable: UIImage? {
        didSet {
            setImage(imageForDisable, for: .disabled)
        }
    }
    
}
