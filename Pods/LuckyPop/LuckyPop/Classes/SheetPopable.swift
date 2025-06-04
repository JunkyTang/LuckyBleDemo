//
//  PopAbleSheet.swift
//  LuckyPop
//
//  Created by junky on 2024/6/8.
//

import Foundation
import SnapKit


public protocol SheetPopable: Popable {}

public extension SheetPopable {
    
    func popViewWillShow(in spView: UIView) {
        snp.makeConstraints { make in
            make.left.right.equalTo(spView)
            make.top.equalTo(spView.snp.bottom)
        }
    }
    
    func popViewDidShow(in spView: UIView, compelete: @escaping () -> Void) {
        
        UIView.animate(withDuration: 0.2) {
            self.transform = CGAffineTransformMakeTranslation(0, -self.bounds.size.height)
        } completion: { _ in
            compelete()
        }
    }
    
    func popViewWillHide(in spView: UIView, compelete: @escaping () -> Void) {
        UIView.animate(withDuration: 0.2) {
            self.transform = .identity
        } completion: { _ in
            compelete()
        }
    }
    
}

