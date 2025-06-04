//
//  PopMaskView.swift
//  LuckyPop
//
//  Created by junky on 2024/10/30.
//

import UIKit

class PopMaskView: UIButton {
    
    override init(frame: CGRect) {
        super.init(frame: frame)
        backgroundColor = UIColor.init(white: 0, alpha: 0.3)
        addTarget(self, action: #selector(actionForClick), for: .touchUpInside)
    }
    
    @objc func actionForClick() {
        funcForClick()
    }
    
    var funcForClick: () -> Void = {}
    
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
}
