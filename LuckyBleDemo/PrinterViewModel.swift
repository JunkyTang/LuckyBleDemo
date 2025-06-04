//
//  PrinterViewModel.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import Foundation
import Combine
import LuckyPropertyWrapper
import LuckyBLE


class PrinterViewModel {
    
    var printer: Printer
    
    @CurrentValueSubjectProperty
    var funcList: [PrinterFunc]
    
    init(printer: Printer) {
        self.printer = printer
        self.funcList = []
        parseFunc()
    }
    
    
    
    
}

extension PrinterViewModel {
    
    func parseFunc() {
        funcList = PrinterFunc.baseFunc
    }
}


enum PrinterFunc {
    case getName
    case getSN
    case getMac
    case getModel
    case getBattery
    case getState
    case getFireware
    case getStandbyTime
    case setStandbyTime
    case getDensity
    case setDensity
    case setPaper
    case enable
    case wakeup
    case disable
    case enterPaper
    case outPaper
    case walkPaper
    case location
    
    case print
    
    static let baseFunc: [PrinterFunc] = [
        .getName, .getSN, .getMac, .getModel, .getBattery, .getState, .getFireware, .getStandbyTime, .setStandbyTime, .getDensity, .setDensity, .setPaper, .enable, .wakeup, .disable, .enterPaper, .outPaper, .walkPaper, .location, .print
    ]
    
    var displayName: String {
        var name = "some"
        switch self {
        case .getName:
            name = "get name"
        case .getSN:
            name = "get sn"
        case .getMac:
            name = "get mac"
        case .getModel:
            name = "get model"
        case .getBattery:
            name = "get battery"
        case .getState:
            name = "get state"
        case .getFireware:
            name = "get fireware"
        case .getStandbyTime:
            name = "get standby time"
        case .setStandbyTime:
            name = "set standby time"
        case .getDensity:
            name = "get density"
        case .setDensity:
            name = "set density"
        case .setPaper:
            name = "set paper"
        case .enable:
            name = "enable"
        case .wakeup:
            name = "wake up"
        case .disable:
            name = "disable"
        case .enterPaper:
            name = "enter paper"
        case .outPaper:
            name = "out paper"
        case .walkPaper:
            name = "walk paper"
        case .location:
            name = "location"
        case .print:
            name = "Print"
        }
        return name
    }
    
    func resole(printer: Printer) async throws {
        
        guard let printer = printer as? BaseFunc else { return }
        
        switch self {
        case .getName:
            _ = try await printer.getName()
        case .getSN:
            _ = try await printer.getSN()
        case .getMac:
            _ = try await printer.getMac()
        case .getModel:
            _ = try await printer.getModel()
        case .getBattery:
            _ = try await printer.getBattery()
        case .getState:
            _ = try await printer.getState()
        case .getFireware:
            _ = try await printer.getFirmware()
        case .getStandbyTime:
            _ = try await printer.getStandbyTime()
        case .setStandbyTime:
            _ = try await printer.set(standbyTime: 0x20)
        case .getDensity:
            _ = try await printer.getDensity()
        case .setDensity:
            _ = try await printer.set(density: 0x01)
        case .setPaper:
            _ = try await printer.set(paper: 0x20)
        case .enable:
            _ = try await printer.enable()
        case .wakeup:
            _ = try await printer.wakeup()
        case .disable:
            _ = try await printer.disable()
        case .enterPaper:
            _ = try await printer.enterPaper()
        case .outPaper:
            _ = try await printer.outPaper()
        case .walkPaper:
            _ = try await printer.walkPaper(long: 0x50)
        case .location:
            _ = try await printer.location()
        case .print:
            break
        }
    }
    
}
