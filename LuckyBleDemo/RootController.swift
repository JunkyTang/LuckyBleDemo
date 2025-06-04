//
//  RootController.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import LuckyBLE
import LuckyLogger

class RootController: UIViewController {

    @IBOutlet weak var textView: UITextView!
    
    @IBOutlet weak var continerView: UIView!
    
    var navigationVC: UINavigationController = UINavigationController(rootViewController: ScanController())
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindVM()
    }
    
    func setupUI() {
        
        addChild(navigationVC)
        continerView.addSubview(navigationVC.view)
        navigationVC.view.frame = continerView.bounds
        navigationVC.didMove(toParent: self)
        navigationVC.isNavigationBarHidden = true
    }

    func bindVM() {
        log.logHandler = { log in
            let formatter = DateFormatter()
            formatter.dateFormat = "HH:mm:ss"
            let timeString = formatter.string(from: Date())
            let txt = "[\(timeString)] " + log
            
            DispatchQueue.main.async { [weak self] in
                guard let weakself = self else { return }
                weakself.textView.text = weakself.textView.text.appending(txt)
                weakself.textView.scrollRangeToVisible(NSMakeRange(weakself.textView.text.count - 1, 1))
            }

        }
    }
}
