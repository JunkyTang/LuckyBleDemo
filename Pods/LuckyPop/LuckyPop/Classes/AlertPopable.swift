//
//  File.swift
//  LuckyPop
//
//  Created by junky on 2024/6/8.
//

import Foundation
import SnapKit

public protocol AlertPopable: Popable {}

public extension AlertPopable {
    
    
    func popViewWillShow(in spView: UIView) {
        
        let padding: CGFloat = 40
        let maxWidth = UIScreen.main.bounds.size.width
        let alertMaxW = min(393, maxWidth) - padding * 2
        
        snp.makeConstraints { make in
            make.centerY.equalTo(spView).offset(-30)
            make.centerX.equalTo(spView)
            make.width.equalTo(alertMaxW)
        }
    }
    
    func popViewDidShow(in spView: UIView, compelete: @escaping () -> Void) {
        self.transform = CGAffineTransformMakeScale(0.2, 0.2)
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        } completion: { _ in
            compelete()
        }
    }
    
    func popViewWillHide(in spView: UIView, compelete: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransformMakeScale(0.2, 0.2)
        } completion: { _ in
            compelete()
        }
    }
        
}
