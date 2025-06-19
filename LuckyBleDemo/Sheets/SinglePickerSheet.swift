//
//  SinglePickerSheet.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/29.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import LuckyPop
import LuckyIB
import SafeContinuation

final class SinglePickerSheet: UIView {


    
    @IBAction func actionForCancel(_ sender: Any) {
        hide(compelete: nil)
    }
    
    @IBAction func actionForConfirm(_ sender: Any) {
        resObj = selectedObj
        hide(compelete: nil)
    }
    
    @IBOutlet weak var picker: UIPickerView!
    
    deinit {
        continuation?.resume(returning: resObj)
    }
    
    override func awakeFromNib() {
        super.awakeFromNib()
        picker.delegate = self
        picker.dataSource = self
    }
    
    var list: [SinglePickerType] = []
    var selectedObj: SinglePickerType?
    
    var resObj: SinglePickerType?
    var continuation: CheckedContinuation<SinglePickerType?, Never>?
    
    func reload() {
        picker.reloadAllComponents()
        let index = list.firstIndex(where: { $0.singlePickerDisplayString == selectedObj?.singlePickerDisplayString }) ?? 0
        picker.selectRow(index, inComponent: 0, animated: false)
        
    }
    

}

extension SinglePickerSheet: UIPickerViewDelegate, UIPickerViewDataSource {
    
    func numberOfComponents(in pickerView: UIPickerView) -> Int {
        return 1
    }
    
    func pickerView(_ pickerView: UIPickerView, rowHeightForComponent component: Int) -> CGFloat {
        return 40
    }
    
    func pickerView(_ pickerView: UIPickerView, numberOfRowsInComponent component: Int) -> Int {
        return list.count
    }
    
    func pickerView(_ pickerView: UIPickerView, titleForRow row: Int, forComponent component: Int) -> String? {
        let model = list[row]
        return model.singlePickerDisplayString
    }
    
    func pickerView(_ pickerView: UIPickerView, didSelectRow row: Int, inComponent component: Int) {
        let model = list[row]
        selectedObj = model
    }
}

extension SinglePickerSheet: SheetPopable, IBLoadable {
    
    static func show<T: SinglePickerType>(inView: UIView? = nil, list: [T], selectedObj: T? = nil) async -> T? {
        if list.count <= 1 {
            return nil
        }
        let res = await withCheckedContinuation { (continuation: CheckedContinuation<SinglePickerType?, Never>) in
            let sheet = SinglePickerSheet.loadFromXib()
            sheet.list = list
            sheet.selectedObj = selectedObj
            if sheet.selectedObj == nil {
                sheet.selectedObj = sheet.list.first
            }
            sheet.reload()
            sheet.continuation = continuation
            sheet.showPopView(in: inView)
        }
        return res as? T
    }
    
}

protocol SinglePickerType {
    var singlePickerDisplayString: String { get }
}
