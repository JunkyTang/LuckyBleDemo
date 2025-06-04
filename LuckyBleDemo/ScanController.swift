//
//  ScanController.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/12.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import LuckyIB
import Combine
import LuckyBLE

class ScanController: UIViewController {

    private var cancellables: Set<AnyCancellable> = []
    deinit {
        cancellables.forEach{ $0.cancel() }
    }
    
    
    @IBOutlet weak var filterBtn: UIButton!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBOutlet weak var textFld: IBTextField!
    
    
    @IBOutlet weak var inputBar: UIStackView!
    
    
    @IBAction func actionForScan(_ sender: Any) {
        vm.scan()
    }
    
    
    @IBAction func actionForFilter(_ sender: Any) {
        vm.editing = true
    }
    
    @IBAction func actionForHide(_ sender: Any) {
        let name = textFld.text ?? ""
        vm.change(filterName: name)
        vm.editing = false
    }
    
    
    
    var vm: ScanViewModel
    
    init(vm: ScanViewModel) {
        self.vm = vm
        super.init(nibName: "ScanController", bundle: Bundle(for: ScanController.self))
    }
    
    convenience init() {
        self.init(vm: ScanViewModel())
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    
    override func viewDidLoad() {
        super.viewDidLoad()

        setupUI()
        bindVM()
    }

    func setupUI() {
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
        tableView.delegate = self
        tableView.dataSource = self
    }
    
    func bindVM() {
        
        vm.$editing.receive(on: DispatchQueue.main).sink { [weak self] editing in
            guard let weakself = self else { return }
            weakself.inputBar.isHidden = !editing
            if editing {
                weakself.textFld.text = weakself.vm.filterName
                weakself.textFld.becomeFirstResponder()
            }else{
                weakself.textFld.resignFirstResponder()
            }
        }.store(in: &cancellables)
        
        vm.$list.receive(on: DispatchQueue.main).sink { [weak self] list in
            guard let weakself = self else { return }
            weakself.tableView.reloadData()
        }.store(in: &cancellables)
    }
    

}

extension ScanController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.list.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let model = vm.list[indexPath.row]
        cell.textLabel?.text = (model.0.name ?? "") + "  \(model.2)"
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = vm.list[indexPath.row]

        Task {
            do {
                let printer = try await AppContext.shared.manager.connect(peripheral: model.0, timeout: 3)
                AppContext.shared.printer = printer
//                printer.service?.mtu = 10000
//                printer.service?.credit = 255
                log.print("\(type(of: printer))")
                DispatchQueue.main.async {
                    let vc = PrinterController(printer: printer)
                    self.navigationController?.pushViewController(vc, animated: true)
                }
            } catch  {
                log.print(error.localizedDescription)
            }

        }
        
        

        
    }
}

