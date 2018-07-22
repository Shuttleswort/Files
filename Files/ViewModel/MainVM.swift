//
//  MainVM.swift
//  Files
//
//  Created by Vladimir Abdrakhmanov on 7/22/18.
//  Copyright © 2018 Vladimir Abdrakhmanov. All rights reserved.
//

import Foundation
import RxCocoa
import RxSwift
import CryptoSwift

protocol MainVMProtocol {
    var view: MainViewProtocol? { get }
    var files: BehaviorRelay<[File]> { get }
    var isFileSelected: BehaviorRelay<Bool> { get }
    var isCanGoBack: BehaviorRelay<Bool> { get }
    var title: BehaviorRelay<String> { get }

    func contentsOf(_ url: URL)
    func selectRow(_ row: Int)
    func infoAction()
    func deleteSelectedFile()
    func doubleTapAt(_ index: Int)
    func goBack()
}



class MainVM: MainVMProtocol {

    weak var view: MainViewProtocol?

    let files = BehaviorRelay<[File]>(value: [])
    let selectedFile = BehaviorRelay<File?>(value: nil)
    let selectedFolder = BehaviorRelay<URL?>(value: nil)
    let isFileSelected = BehaviorRelay<Bool>(value: false)
    let isCanGoBack = BehaviorRelay<Bool>(value: false)
    let title = BehaviorRelay<String>(value: "Files")

    private let disposeBag = DisposeBag()

    init(view: MainViewProtocol) {
        self.view = view


        files.asObservable()
            .subscribeOn(MainScheduler.asyncInstance)
            .subscribe(onNext: { files in
                view.reloadTableView()
        })
        .disposed(by: disposeBag)

        selectedFile.asObservable()
            .map { file -> Bool in
                return file != nil
            }
            .bind(to: isFileSelected)
        .disposed(by: disposeBag)


        selectedFile.asObservable()
            .map { file -> String in
                return file?.path.path ?? "Files"
            }
            .bind(to: title)
            .disposed(by: disposeBag)

    }


    // MARK: - MainVMProtocol
    func goBack() {
        if selectedFolder.value?.path == "/" { return }
        guard let previousFolderPath = selectedFolder.value?.deletingLastPathComponent() else { return }
        isFileSelected.accept(false)
        contentsOf(previousFolderPath)
    }

    func doubleTapAt(_ index: Int) {
        guard files.value.indices.contains(index) == true else  { return }
        let file = files.value[index]
        guard file.path.hasDirectoryPath == true else { return }

        if file.path.hasDirectoryPath {
            isCanGoBack.accept(true)
        } else {
            isCanGoBack.accept(false)
        }
        isFileSelected.accept(false)
        contentsOf(file.path)
    }


    func deleteSelectedFile() {
        guard let file = selectedFile.value else { return }
        let newArray = files.value.filter { $0 != file }

        do {
            try FileManager.default.removeItem(at: file.path)
            files.accept(newArray)
            selectedFile.accept(nil)

        } catch {
            fatalError("Failed delete file")
        }

    }

    func selectRow(_ row: Int) {
        selectedFile.accept(files.value[row])
    }

    func infoAction() {
        guard let file = selectedFile.value else { return }
        view?.infoAction(file)
    }


    func contentsOf(_ url: URL) {
        let fileManager = FileManager.default
        do {
            let contents = try fileManager.contentsOfDirectory(atPath: url.path)
            let urls = contents.map { return url.appendingPathComponent($0) }

            files.accept(urls.compactMap { parseContentOf($0) })
            selectedFolder.accept(url)

        } catch {
            guard let file = parseContentOf(url) else { fatalError("no file") }
            files.accept([file])
            selectedFolder.accept(url)
        }

    }


    private func parseContentOf(_ url: URL) -> File? {
        let fileManager = FileManager.default
        do {
            let attributes = try fileManager.attributesOfItem(atPath: url.path)
            let file = File(name: url.lastPathComponent, path: url)
            file.image = NSWorkspace.shared.icon(forFile: url.path)

            for (key, value) in attributes {
                switch key {
                case .creationDate: file.creationDate = "\(value)"
                case .size: file.size = "\(value)"
                case .type: file.type = "\(value)"
                default: break
                }
            }
            return file

        } catch {
            return nil
        }
    }

}




