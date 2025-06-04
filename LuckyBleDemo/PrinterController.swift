//
//  PrinterController.swift
//  LuckyBLE_Example
//
//  Created by junky on 2025/5/16.
//  Copyright © 2025 CocoaPods. All rights reserved.
//

import UIKit
import Combine
import LuckyBLE



class PrinterController: UIViewController {

    private var cancellables: Set<AnyCancellable> = []
    deinit {
        cancellables.forEach{ $0.cancel() }
    }
    
    @IBOutlet weak var nameLab: UILabel!
    
    @IBOutlet weak var tableView: UITableView!
    
    @IBAction func actionForBack(_ sender: Any) {
        Task {
            do {
                try await AppContext.shared.manager.disconnect()
            } catch {
                log.print(error.localizedDescription)
            }
        }
    }
    
    
    var vm: PrinterViewModel
    
    
    convenience init(printer: Printer) {
        let vm = PrinterViewModel(printer: printer)
        self.init(vm: vm)
    }
    
    init(vm: PrinterViewModel) {
        self.vm = vm
        super.init(nibName: "PrinterController", bundle: Bundle(for: PrinterController.self))
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
        tableView.delegate = self
        tableView.dataSource = self
        tableView.register(UITableViewCell.self, forCellReuseIdentifier: "UITableViewCell")
    }
    
    func bindVM() {
        
        AppContext.shared.$peripherial.sink { [weak self] per in
            guard let weakself = self else { return }
            if per == nil {
                weakself.navigationController?.popToRootViewController(animated: true)
            }
        }.store(in: &cancellables)
        
        vm.$funcList.receive(on: DispatchQueue.main).sink { [weak self] _ in
            guard let weakself = self else { return }
            weakself.tableView.reloadData()
        }.store(in: &cancellables)
    }

}


extension PrinterController: UITableViewDelegate, UITableViewDataSource {
    
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return vm.funcList.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "UITableViewCell", for: indexPath)
        let model = vm.funcList[indexPath.row]
        cell.textLabel?.text = model.displayName
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        tableView.deselectRow(at: indexPath, animated: true)
        
        let model = vm.funcList[indexPath.row]
        if model == .print {
            let vc = PreviewController(vm: .init())
            navigationController?.pushViewController(vc, animated: true)
            return
        }
        Task {
            do {
                try await model.resole(printer: vm.printer)
            } catch {
                LuckyBLE.log.print("\(error)")
            }
        }
    }
}
