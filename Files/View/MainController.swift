//
//  ViewController.swift
//  Files
//
//  Created by Vladimir Abdrakhmanov on 7/17/18.
//  Copyright © 2018 Vladimir Abdrakhmanov. All rights reserved.
//

import Cocoa
import RxSwift
import RxCocoa

protocol MainViewProtocol: class {
    func reloadTableView()
    func infoAction(_ file: File)
}

class MainController: NSViewController {

    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var deleteButton: NSButton!
    @IBOutlet weak var infoButton: NSButton!
    @IBOutlet weak var goBackButton: NSButton!

    lazy var viewModel: MainVMProtocol = {
        let vm = MainVM(view: self)
        return vm
    }()

    private let disposeBag = DisposeBag()

    override func viewDidLoad() {
        super.viewDidLoad()

        viewModel.isFileSelected.bind(to: deleteButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.isFileSelected.bind(to: infoButton.rx.isEnabled).disposed(by: disposeBag)
        viewModel.isCanGoBack.bind(to: goBackButton.rx.isEnabled).disposed(by: disposeBag)

        viewModel.title.asObservable()
            .subscribe(onNext: { [weak self] title in
                self?.view.window?.title = title
            })
            .disposed(by: disposeBag)

    }


    // MARK: - Actions
    @IBAction func goBackAction(_ sender: Any) {
        viewModel.goBack()
    }
    
    @IBAction func infoAction(_ sender: Any) {
        viewModel.infoAction()
    }

    @IBAction func deleteAction(_ sender: Any) {
        viewModel.deleteSelectedFile()
    }

    @IBAction func doubleTapAction(_ sender: Any) {
        if tableView.selectedRow < 0 { return }
        viewModel.doubleTapAt(tableView.selectedRow)
    }

    @IBAction func selectFilesAction(_ sender: Any) {
        guard let window = view.window else { return }
        let panel = NSOpenPanel()
        panel.canChooseDirectories = true
        panel.beginSheetModal(for: window) { [weak self] result in
            if result.rawValue == NSApplication.ModalResponse.OK.rawValue {
                self?.viewModel.contentsOf(panel.urls[0])
            }
        }
    }
}

extension MainController: MainViewProtocol {

    func reloadTableView() {
        tableView.reloadData()
        tableView.scrollRowToVisible(0)
    }

    func infoAction(_ file: File) {
        let vc = InfoController(nibName: NSNib.Name(rawValue: "InfoController"), bundle: nil) 
        vc.file = file
        presentViewControllerAsSheet(vc)
    }

}

extension MainController: NSTableViewDataSource {
    func numberOfRows(in tableView: NSTableView) -> Int {
        return viewModel.files.value.count
    }
}

extension MainController: NSTableViewDelegate {

    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        guard let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: nil) as? NSTableCellView else { return nil }
        let item = viewModel.files.value[row]
        cell.textField?.stringValue = item.name
        cell.imageView?.image = item.image
        return cell
    }

    func tableViewSelectionDidChange(_ notification: Notification) {
        if tableView.selectedRow < 0 { return }
        viewModel.selectRow(tableView.selectedRow)
    }
}


















