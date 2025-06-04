//
//  ScanViewModel.swift
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

class ScanViewModel {
    
    private var cancellables: Set<AnyCancellable> = []
    deinit {
        cancellables.forEach{ $0.cancel() }
    }
    
    @CurrentValueSubjectProperty
    var list: [(CBPeripheral, [String: Any], NSNumber)]
    
    @PassthroughSubjectProperty
    var editing: Bool
    
    @UserDefaultsProperty(key: "filter", defaultValue: "")
    var filterName: String
    
    init(list: [(CBPeripheral, [String : Any], NSNumber)] = [], editing: Bool = false, filterName: String? = nil) {
        self.list = list
        self.editing = editing
        if let filterName = filterName {
            self.filterName = filterName
        }
        bind()
    }
    
    
    
    
    
}

extension ScanViewModel {
    
    func bind() {
        
        AppContext.shared.manager.$scanList.sink { [weak self] list in
            guard let weakself = self else { return }
            weakself.filterList(with: weakself.filterName, res: list)
        }.store(in: &cancellables)
        
    }
    
    func scan() {
        Task {
            await AppContext.shared.manager.scan(timeout: 3)
        }
    }
    
    func stopScan() {
        AppContext.shared.manager.stopScan()
    }
    
    func change(filterName: String) {
        self.filterName = filterName
        filterList(with: self.filterName, res: AppContext.shared.manager.scanList)
    }
    
    func connect(indexPath: IndexPath) async throws {
        let perpherial = list[indexPath.row].0
        try await AppContext.shared.manager.connect(peripheral: perpherial, timeout: 3)
    }
    
    func filterList(with name: String, res: [(CBPeripheral, [String: Any], NSNumber)]) {
        let filterNone = res.filter{ $0.0.name != "" && $0.0.name != nil }
        if name.isEmpty {
            list = filterNone.sorted(by: { $0.2.floatValue >= $1.2.floatValue })
            return
        }
        list = filterNone.filter{ $0.0.name?.contains(name) ?? false }.sorted(by: { $0.2.floatValue >= $1.2.floatValue })
    }
    
}


