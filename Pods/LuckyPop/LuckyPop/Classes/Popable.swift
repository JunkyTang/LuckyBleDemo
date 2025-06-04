//
//  PopAble.swift
//  LuckyPop
//
//  Created by junky on 2024/5/25.
//

import UIKit


public let popMaskViewTag: Int = Int.max - 100

public protocol Popable: UIView {
    
    var popMaskView: UIView? { get }
    
    func popViewWillShow(in spView: UIView)
    
    func popViewDidShow(in spView: UIView, compelete:@escaping () -> Void)

    func popViewWillHide(in spView: UIView, compelete:@escaping () -> Void)
    
    func popViewDidHide(in spView: UIView)
    
    func showPopView(in view: UIView?)
    
    func hide(compelete:((Self) -> Void)?)
}

public extension Popable {
    
    
    
    var popMaskView: UIView? {
        let mask = PopMaskView()
        mask.funcForClick = { [weak self] in
            guard let weakself = self else { return }
            weakself.hide(compelete: nil)
        }
        return mask
    }
    
    func popViewWillShow(in spView: UIView) {
        snp.makeConstraints { make in
            make.left.top.width.equalTo(spView)
        }
    }
    
    func popViewDidShow(in spView: UIView, compelete:@escaping () -> Void) { compelete() }

    func popViewWillHide(in spView: UIView, compelete:@escaping () -> Void) { compelete() }
    
    func popViewDidHide(in spView: UIView) {}
    
    
    func showPopView(in view: UIView?) {
        
        var container: UIView = UIView()
        if view == nil {
            if let window = UIApplication.shared.delegate?.window,
               let window = window
            {
                container = window
            }
        }else{
            container = view!
        }
        
        if let mask = popMaskView {
            mask.tag = popMaskViewTag
            container.addSubview(mask)
            mask.snp.makeConstraints { make in
                make.edges.equalTo(0)
            }
            container = mask
        }
        
        container.addSubview(self)
        popViewWillShow(in: container)
        container.layoutIfNeeded()
        popViewDidShow(in: container) {
            
        }
        
    }
    
    func hide(compelete:((Self) -> Void)?) {
        
        guard let spView = superview else {
            compelete?(self)
            return
        }
        popViewWillHide(in: spView) { [weak self] in
            guard let weakself = self else { return }
            weakself.removeFromSuperview()
            if let mask = spView.viewWithTag(popMaskViewTag) {
                mask.removeFromSuperview()
            }
            compelete?(weakself)
            weakself.popViewDidHide(in: spView)
        }
        
    }
    
}
