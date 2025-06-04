//
//  AppContext.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import Combine
import LuckyPropertyWrapper
import CoreBluetooth
import LuckyBLE
import SafeContinuation
import Photos
import PhotosUI

class AppContext {
    
    static var shared = AppContext()
    
    
    private var cancellables: Set<AnyCancellable> = []
    deinit {
        cancellables.forEach{ $0.cancel() }
    }
    
    var manager: BLEManager
    
    @CurrentValueSubjectProperty
    var peripherial: CBPeripheral?
    
    @CurrentValueSubjectProperty
    var printer: Printer?

    
    
    private init(manager: BLEManager = BLEManager(), peripherial: CBPeripheral? = nil, printer: Printer? = nil) {
        self.manager = manager
        self.peripherial = peripherial
        self.printer = printer
        bindEvent()
    }
    
    
    var pickerContinuation: SafeContinuation<[PHPickerResult]>?
}

extension AppContext {
    
    
    func bindEvent() {
        
        manager.$peripheral.sink { [weak self] per in
            guard let weakself = self else { return }
            weakself.peripherial = per
        }.store(in: &cancellables)
        
        
    }
    
    
}
extension AppContext: PHPickerViewControllerDelegate {
    
    func getRootVC() -> UIViewController? {
        guard let window = UIApplication.shared.delegate?.window,
              let root = window?.rootViewController
        else { return nil }
        return root
    }
    
    @MainActor
    func pickImage(max: Int) async throws -> [PHPickerResult] {
        let res = try await withTimeout(seconds: 100) { (continuation: SafeContinuation<[PHPickerResult]>) in
            var config = PHPickerConfiguration(photoLibrary: .shared())
            config.selectionLimit = max
            config.filter = .images
            let vc = PHPickerViewController(configuration: config)
            vc.delegate = self
            guard let root = self.getRootVC() else {
                await continuation.resume(throwing: Exception.service(.unAvailable))
                return
            }
            root.present(vc, animated: true)
            self.pickerContinuation = continuation
        }
        return res
    }
    
    func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
        picker.dismiss(animated: true)
        Task {
            await pickerContinuation?.resume(returning: results)
        }
    }
    
}


extension PHPickerResult {
    
    
    func loadImage() async throws -> UIImage {
        
        guard let assetId = assetIdentifier,
              let asset = PHAsset.fetchAssets(withLocalIdentifiers: [assetId], options: nil).firstObject
        else {
            throw Exception.service(.unAvailable)
        }
        
        let options = PHImageRequestOptions()
        options.isNetworkAccessAllowed = true // 支持iCloud图片
        options.deliveryMode = .highQualityFormat
        options.isSynchronous = false // 保持异步
        options.version = .current
        
        let res = try await withTimeout(seconds: 3) { (continuation: SafeContinuation<UIImage>) in
            PHImageManager.default().requestImage(for: asset, targetSize: CGSize(width: asset.pixelWidth, height: asset.pixelHeight), contentMode: .aspectFill, options: options) { image, info in
                guard let image = image else {
                    Task{ await continuation.resume(throwing: Exception.service(.unAvailable)) }
                    return
                }
                Task { await continuation.resume(returning: image) }
            }
        }
        return res
    }
    
}
