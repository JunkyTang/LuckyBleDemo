//
//  PreviewController.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/28.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import LuckyCombine
import LuckyBLE

class PreviewController: UIViewController {

    
    @IBOutlet weak var imageView: UIImageView!
    
    @IBOutlet weak var paperStackView: UIStackView!
    
    @IBOutlet weak var paperValueLab: UILabel!
    
    @IBOutlet weak var sizeStackView: UIStackView!
    
    @IBOutlet weak var sizeValueLab: UILabel!
    
    @IBOutlet weak var modeStackView: UIStackView!
    
    @IBOutlet weak var modeValueLab: UILabel!
    
    @IBOutlet weak var copyStackVIew: UIStackView!
    
    @IBOutlet weak var copyValueLab: UILabel!
    
    @IBOutlet weak var printStackView: UIStackView!
    
    
    
    @IBAction func actionForBack(_ sender: Any) {
        navigationController?.popViewController(animated: true)
    }
    
    
    
    private var cancellables: Set<AnyCancellable> = []
    deinit {
        cancellables.forEach{ $0.cancel() }
    }
    var vm: PreviewViewModel
    
    init(vm: PreviewViewModel) {
        self.vm = vm
        super.init(nibName: "PreviewController", bundle: Bundle(for: PreviewController.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        // Do any additional setup after loading the view.
        setupUI()
        bindVM()
        
    }
    
    func setupUI() {
        imageView.isUserInteractionEnabled = true
        imageView.publisher(gestureRecognizer: UITapGestureRecognizer()).tryAsyncSink { [weak self] _ in
            guard let weakself = self,
                  let res = try await AppContext.shared.pickImage(max: 1).first
            else { return }
            try await weakself.vm.change(image: res)
        }.store(in: &cancellables)
        
        paperStackView.publisher(gestureRecognizer: UITapGestureRecognizer()).tryAsyncSink { [weak self] _ in
            guard let weakself = self else { return }
            guard let paper = await SinglePickerSheet.show(inView: weakself.view, list: weakself.vm.paperList, selectedObj: weakself.vm.paper) else { return }
            try await weakself.vm.change(paper: paper)
        }.store(in: &cancellables)
        
        sizeStackView.publisher(gestureRecognizer: UITapGestureRecognizer()).tryAsyncSink { [weak self] _ in
            guard let weakself = self else { return }
            
            switch weakself.vm.paper {
            case .roll(let cGFloat):
                let list: [CGFloat] = [30, 50, 70, 100, 210, 216]
                guard let size = await SinglePickerSheet.show(inView: weakself.view, list: list, selectedObj: cGFloat) else { return }
                try await weakself.vm.change(paper: .roll(size))
            case .label(let cGFloat, let cGFloat2):
                let list: [CGSize] = [CGSize(width: 50, height: 15), CGSize(width: 50, height: 30), CGSize(width: 50, height: 50)]
                guard let size = await SinglePickerSheet.show(inView: weakself.view, list: list, selectedObj: CGSize(width: cGFloat, height: cGFloat2)) else { return }
                try await weakself.vm.change(paper: .label(size.width, size.height))
            case .fold(let cGFloat, let cGFloat2):
                let list: [CGSize] = [CGSize(width: 210, height: 297), CGSize(width: 216, height: 279)]
                guard let size = await SinglePickerSheet.show(inView: weakself.view, list: list, selectedObj: CGSize(width: cGFloat, height: cGFloat2)) else { return }
                try await weakself.vm.change(paper: .fold(size.width, size.height))
            case .tattoo(let cGFloat, let cGFloat2):
                let list: [CGSize] = [CGSize(width: 210, height: 297), CGSize(width: 216, height: 279)]
                guard let size = await SinglePickerSheet.show(inView: weakself.view, list: list, selectedObj: CGSize(width: cGFloat, height: cGFloat2)) else { return }
                try await weakself.vm.change(paper: .tattoo(size.width, size.height))
            case .miniLabel(let cGFloat, let cGFloat2):
                let list: [CGSize] = [CGSize(width: 30, height: 14), CGSize(width: 50, height: 14), CGSize(width: 80, height: 14)]
                guard let size = await SinglePickerSheet.show(inView: weakself.view, list: list, selectedObj: CGSize(width: cGFloat, height: cGFloat2)) else { return }
                try await weakself.vm.change(paper: .miniLabel(size.width, size.height))
            }
            
        }.store(in: &cancellables)
        
        
        modeStackView.publisher(gestureRecognizer: UITapGestureRecognizer()).tryAsyncSink { [weak self] _ in
            guard let weakself = self else { return }
            guard let mode = await SinglePickerSheet.show(inView: weakself.view, list: ImageMode.allCases, selectedObj: weakself.vm.mode) else { return }
            try await weakself.vm.change(mode: mode)
        }.store(in: &cancellables)
        
        copyStackVIew.publisher(gestureRecognizer: UITapGestureRecognizer()).tryAsyncSink { [weak self] _ in
            guard let weakself = self else { return }
            let list: [Int] = Array(1...10)
            guard let copies = await SinglePickerSheet.show(inView: weakself.view, list: list, selectedObj: weakself.vm.copies) else { return }
            weakself.vm.copies = copies
        }.store(in: &cancellables)
        
        printStackView.publisher(gestureRecognizer: UITapGestureRecognizer()).tryAsyncSink { [weak self] _ in
            guard let weakself = self,
                  let targetImage = weakself.vm.displayImage
            else { return }
            switch weakself.vm.paper {
            case .roll(_):
                guard let rollPrint = AppContext.shared.printer as? RollPaperPrintable
                else {
                    throw Exception.service(.unAvailable)
                }
                for _ in 0..<weakself.vm.copies {
                    try await rollPrint.rollPrint(image: targetImage)
                }
            case .label(_, _):
                guard let labelPrint = AppContext.shared.printer as? LabelPaperPrintable else {
                    throw Exception.service(.unAvailable)
                }
                for _ in 0..<weakself.vm.copies {
                    try await labelPrint.labelPrint(image: targetImage)
                }
            case .fold(_, _):
                guard let foldPrint = AppContext.shared.printer as? FoldPaperPrintable else {
                    throw Exception.service(.unAvailable)
                }
                for _ in 0..<weakself.vm.copies {
                    try await foldPrint.foldPrint(image: targetImage)
                }
            case .tattoo(_, _):
                guard let tattooPrint = AppContext.shared.printer as? TattooPaperPrintable else {
                    throw Exception.service(.unAvailable)
                }
                for _ in 0..<weakself.vm.copies {
                    try await tattooPrint.tattooPrint(image: targetImage)
                }
            case .miniLabel(_, _):
                guard let labelPrint = AppContext.shared.printer as? LabelPaperPrintable else {
                    throw Exception.service(.unAvailable)
                }
                for _ in 0..<weakself.vm.copies {
                    try await labelPrint.labelPrint(image: targetImage)
                }
            }
        }.store(in: &cancellables)
        
    }
    
    func bindVM() {
        
        vm.$displayImage.receive(on: DispatchQueue.main).sink { [weak self] img in
            guard let weakself = self else { return }
            weakself.imageView.image = img
        }.store(in: &cancellables)
        
        vm.$paper.receive(on: DispatchQueue.main).sink { [weak self] paper in
            guard let weakself = self else { return }
            weakself.paperValueLab.text = paper.singlePickerDisplayString
            weakself.sizeValueLab.text = paper.displaySize
        }.store(in: &cancellables)
        
        vm.$mode.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let weakself = self else { return }
            weakself.modeValueLab.text = value.singlePickerDisplayString
        }.store(in: &cancellables)

        vm.$copies.receive(on: DispatchQueue.main).sink { [weak self] value in
            guard let weakself = self else { return }
            weakself.copyValueLab.text = value.singlePickerDisplayString
            
        }.store(in: &cancellables)
        
    }
    
    

}
