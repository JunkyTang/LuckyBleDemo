//
//  PreviewViewModel.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/28.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import LuckyPropertyWrapper
import LuckyBLE
import SDWebImage
import PhotosUI

class PreviewViewModel {
    
    var originImage: PHPickerResult?
    
    @PassthroughSubjectProperty
    var displayImage: UIImage?
    
    @CurrentValueSubjectProperty
    var paper: PaperType = .roll(50)
    
    @CurrentValueSubjectProperty
    var mode: ImageMode
    
    @CurrentValueSubjectProperty
    var copies: Int
    
    var paperList: [PaperType]
    
    init(originImage: PHPickerResult? = nil, paper: PaperType = .roll(50), mode: ImageMode = .none, copies: Int = 1) {
        self.originImage = originImage
        self.paper = paper
        self.mode = mode
        self.copies = copies
        var list: [PaperType] = []
        if let _ = AppContext.shared.printer as? RollPaperPrintable {
            list.append(.roll(50))
        }
        if let _ = AppContext.shared.printer as? LabelPaperPrintable {
            list.append(.label(50, 30))
        }
        if let _ = AppContext.shared.printer as? FoldPaperPrintable {
            list.append(.fold(210, 297))
        }
        if let _ = AppContext.shared.printer as? TattooPaperPrintable {
            list.append(.tattoo(210, 297))
        }
        self.paperList = list
    }
    
    
    
}

extension PreviewViewModel {
    
    
    func generatDisplayImage() async throws {
        guard let originImage = originImage,
              let prinableWidth = AppContext.shared.printer?.printableMaxWidth
        else { throw Exception.service(.unAvailable) }
        
        let maxWidth = CGFloat(prinableWidth)
        var target = try await originImage.loadImage()
        var scaleFilter: CILanczosScaleTransformFilter
        var drawInCanvasFilter: DrawInCanvasFilter
        let dpi = CGFloat(AppContext.shared.printer?.dpi ?? 8)
        switch paper {
        case .roll(let width):
            let targetW = min(maxWidth, width)
            scaleFilter = CILanczosScaleTransformFilter(originSize: target.size, to: targetW * dpi)
            let scale = targetW * dpi / target.size.width
            let height = floor(target.size.height * scale)
            drawInCanvasFilter = DrawInCanvasFilter(size: CGSize(width: targetW * dpi, height: height))
        case .label(let width, let height), .fold(let width, let height), .tattoo(let width, let height), .miniLabel(let height, let width):
            let targetW = min(maxWidth, width)
            var taregtH = height
            if maxWidth < width {
                taregtH = floor(maxWidth / width * height)
            }
            scaleFilter = CILanczosScaleTransformFilter(originSize: target.size, to: CGSize(width: targetW * dpi, height: taregtH * dpi))
            drawInCanvasFilter = DrawInCanvasFilter(size: CGSize(width: targetW * dpi, height: taregtH * dpi))
        }
        
        drawInCanvasFilter.alignment = .center
        target = try scaleFilter.filter(image: target)
        target = try drawInCanvasFilter.filter(image: target)
        
        print(target.pngData()?.count ?? 0)
        if mode == .binary {
            target = try DitherFilter(type: .none).filter(image: target)
        }else if mode == .dither {
            target = try DitherFilter(type: .floydSteinberg).filter(image: target)
        }
        print(target.pngData()?.count ?? 0)
        displayImage = target
    }
    
    func change(image: PHPickerResult) async throws {
        originImage = image
        try await generatDisplayImage()
    }
    
    func change(paper: PaperType) async throws {
        self.paper = paper
        try await generatDisplayImage()
    }
    
    func change(mode: ImageMode) async throws {
        self.mode = mode
        try await generatDisplayImage()
    }
}


enum PaperType {
    case roll(CGFloat)
    case label(CGFloat, CGFloat)
    case fold(CGFloat, CGFloat)
    case tattoo(CGFloat, CGFloat)
    case miniLabel(CGFloat, CGFloat)
    
    var displayName: String {
        switch self {
        case .roll(_):
            return "Roll"
        case .label(_, _):
            return "Label"
        case .fold(_, _):
            return "Fold"
        case .tattoo(_, _):
            return "Tattoo"
        case .miniLabel(_, _):
            return "Mini Label"
        }
    }
    
    var displaySize: String {
        switch self {
        case .roll(let cGFloat):
            return "\(cGFloat)mm"
        case .label(let cGFloat, let cGFloat2):
            return "\(cGFloat)*\(cGFloat2)mm"
        case .fold(let cGFloat, let cGFloat2):
            return "\(cGFloat)*\(cGFloat2)mm"
        case .tattoo(let cGFloat, let cGFloat2):
            return "\(cGFloat)*\(cGFloat2)mm"
        case .miniLabel(let cGFloat, let cGFloat2):
            return "\(cGFloat)*\(cGFloat2)mm"
        }
    }
}
extension PaperType: SinglePickerType {
    var singlePickerDisplayString: String {
        switch self {
        case .roll(_):
            return "Roll"
        case .label(_, _):
            return "Label"
        case .fold(_, _):
            return "Fold"
        case .tattoo(_, _):
            return "Tattoo"
        case .miniLabel(_, _):
            return "Mini Label"
        }
    }
}


enum ImageMode: CaseIterable, SinglePickerType {
    case none
    case binary
    case dither
    
    var singlePickerDisplayString: String {
        switch self {
        case .none:
            return "None"
        case .binary:
            return "Binary"
        case .dither:
            return "Dither"
        }
    }
}


extension Int: SinglePickerType {
    var singlePickerDisplayString: String {
        return "\(self)"
    }
}

extension CGFloat: SinglePickerType {
    var singlePickerDisplayString: String {
        return "\(self)"
    }
}

extension CGSize: SinglePickerType {
    var singlePickerDisplayString: String {
        return "\(self.width)*\(self.height)"
    }
}
