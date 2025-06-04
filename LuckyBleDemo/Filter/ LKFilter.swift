//
//   LKFilter.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/28.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import CoreImage
import CoreImage.CIFilterBuiltins
import LuckyBLE
import Accelerate.vImage

protocol FilterType {
    func filter(image: UIImage) throws -> UIImage
}

protocol LKFilter {
    var ciFilter: CIFilter? { get }
}
extension LKFilter {
    func filter(image: UIImage) throws -> UIImage {
        
        guard let ciImage = CIImage(image: image),
            let filter = ciFilter else { throw Exception.service(.unAvailable) }
        filter.setValue(ciImage, forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else { throw Exception.service(.unAvailable) }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { throw Exception.service(.unAvailable) }
        return UIImage(cgImage: cgImage)
    }
}
protocol LKGroupFilter: FilterType {
    
    var filter: [FilterType] { get }
    func filter(image: UIImage) throws -> UIImage
}
extension LKGroupFilter {
    func filter(image: UIImage) throws -> UIImage {
        return try filter.reduce(image, { try $1.filter(image: $0) })
    }
}

struct CILanczosScaleTransformFilter: LKFilter {
    
    var scale: Float = 1
    
    var ciFilter: CIFilter? {
        guard let filter = CIFilter(name: "CILanczosScaleTransform") else { return nil }
        filter.setValue(scale, forKey: kCIInputScaleKey)
        filter.setValue(1.0, forKey: kCIInputAspectRatioKey)
        return filter
    }
    
    init(originSize: CGSize, to size: CGSize) {
        let scaleW = Float(size.width / originSize.width)
        let scaleH = Float(size.height / originSize.height)
        self.scale = min(scaleW, scaleH)
    }
    
    init(originSize: CGSize, to width: CGFloat) {
        let scaleW = Float(width / originSize.width)
        self.scale = scaleW
    }
    
}


struct CIAffineTransformFilter: LKFilter {
    
    var transform: CGAffineTransform
    
    var ciFilter: CIFilter? {
        guard let filter = CIFilter(name: "CIAffineTransform") else { return nil }
        filter.setValue(transform, forKey: kCIInputTransformKey)
        return filter
    }
    
    
    init(originSize: CGSize, to size: CGSize) {
        let scaleW = size.width / originSize.width
        let scaleH = size.height / originSize.height
        let scale = min(scaleW, scaleH)
        self.transform = CGAffineTransformMakeScale(scale, scale)
    }
    
    init(originSize: CGSize, to width: CGFloat) {
        let scaleW = width / originSize.width
        self.transform = CGAffineTransformMakeScale(scaleW, scaleW)
    }
}

struct DrawInCanvasFilter: LKFilter {
    
    enum ImageAlignment {
        case left
        case center
        case right
    }
    
    var size: CGSize
    
    var alignment: ImageAlignment
    
    var ciFilter: CIFilter? {
        let filter = CIFilter.sourceOverCompositing()
        
        let whiteBackground = CIImage(color: CIColor.white)
                .cropped(to: CGRect(origin: .zero, size: size))
        filter.backgroundImage = whiteBackground
        return filter
    }
    
    init(size: CGSize, alignment: ImageAlignment = .center) {
        self.size = size
        self.alignment = alignment
    }
    
    
    func filter(image: UIImage) throws -> UIImage {
        
        guard let ciImage = CIImage(image: image),
            let filter = ciFilter else { throw Exception.service(.unAvailable) }
        
        // 计算偏移
        let imageExtent = ciImage.extent
        var offsetX: CGFloat = 0
        switch alignment {
        case .left:
            offsetX = 0
        case .center:
            offsetX = (size.width - imageExtent.width) / 2.0
        case .right:
            offsetX = size.width - imageExtent.width
        }

        // 应用 transform
        let translatedImage = ciImage.transformed(by: .init(translationX: offsetX, y: 0))
        
        filter.setValue(translatedImage
                        , forKey: kCIInputImageKey)
        
        guard let outputImage = filter.outputImage else { throw Exception.service(.unAvailable) }
        let context = CIContext()
        guard let cgImage = context.createCGImage(outputImage, from: outputImage.extent) else { throw Exception.service(.unAvailable) }
        return UIImage(cgImage: cgImage)
    }
    
}





struct GrayFilter: FilterType {
    
    
    func filter(image: UIImage) throws -> UIImage {
        guard let cgImage = image.cgImage else {
            throw Exception.service(.unAvailable)
        }
        
        guard let sourceFormat = vImage_CGImageFormat(cgImage: cgImage) else {
            throw Exception.service(.unAvailable)
        }
        
        guard let destinationFormat = vImage_CGImageFormat(bitsPerComponent: 8, bitsPerPixel: 8, colorSpace: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)) else {
            throw Exception.service(.unAvailable)
        }
        
        let rgb2grayConverter = try vImageConverter.make(sourceFormat: sourceFormat, destinationFormat: destinationFormat)
        let sourceBuffer = try vImage_Buffer(cgImage: cgImage)
        var destinationBuffer = try vImage_Buffer(width: Int(sourceBuffer.width), height: Int(sourceBuffer.height), bitsPerPixel: destinationFormat.bitsPerPixel)
        defer {
            sourceBuffer.free()
            destinationBuffer.free()
        }
        
        try rgb2grayConverter.convert(source: sourceBuffer, destination: &destinationBuffer)
        let res = try destinationBuffer.createCGImage(format: destinationFormat)
        return UIImage(cgImage: res)

    }
}

struct DitherFilter: FilterType {
    
    public enum DitherType {
        case none
        case orderedGaussian
        case orderedUniform
        case floydSteinberg
        case atkinson
        
        var dither: Int32 {
            switch self {
                case .none:
                    return Int32(kvImageConvert_DitherNone)
                case .orderedGaussian:
                    return Int32(kvImageConvert_DitherOrdered | kvImageConvert_OrderedGaussianBlue)
                case .orderedUniform:
                    return Int32(kvImageConvert_DitherOrdered | kvImageConvert_OrderedUniformBlue)
                case .floydSteinberg:
                    return Int32(kvImageConvert_DitherFloydSteinberg)
                case .atkinson:
                    return Int32(kvImageConvert_DitherAtkinson)
            }
        }
    }
    
    
    var type: DitherType = .none
    
    
    func filter(image: UIImage) throws -> UIImage {
        
        let gray = try GrayFilter().filter(image: image)
        
        guard let cgImage = gray.cgImage else {
            throw Exception.service(.unAvailable)
        }
        
        var sourceBuffer = try vImage_Buffer(cgImage: cgImage)
        
        guard let destinationFormat = vImage_CGImageFormat(bitsPerComponent: 1, bitsPerPixel: 1, colorSpace: CGColorSpaceCreateDeviceGray(), bitmapInfo: CGBitmapInfo(rawValue: CGImageAlphaInfo.none.rawValue)) else {
            throw Exception.service(.unAvailable)
        }
        var destinationBuffer = try vImage_Buffer(width: Int(sourceBuffer.width), height: Int(sourceBuffer.height), bitsPerPixel: 1)
        
        defer {
            sourceBuffer.free()
            destinationBuffer.free()
        }
        
        
        let err = vImageConvert_Planar8toPlanar1(&sourceBuffer, &destinationBuffer, nil, type.dither, vImage_Flags(kvImageNoFlags))
        if err != kvImageNoError {
            throw Exception.service(.unAvailable)
        }
        
        let res = try destinationBuffer.createCGImage(format: destinationFormat)
        
        let destination = UIImage(cgImage: res, scale: image.scale, orientation: image.imageOrientation)
        return destination
    }
    
}
