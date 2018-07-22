//
//  InfoController.swift
//  Files
//
//  Created by Vladimir Abdrakhmanov on 7/22/18.
//  Copyright © 2018 Vladimir Abdrakhmanov. All rights reserved.
//

import Cocoa

class InfoController: NSViewController {

    @IBOutlet weak var nameLabel: NSTextField!
    @IBOutlet weak var sizeLabel: NSTextField!
    @IBOutlet weak var dateLabel: NSTextField!
    @IBOutlet weak var hashLabel: NSTextField!

    var file: File!

    override func viewDidLoad() {
        super.viewDidLoad()

        nameLabel.stringValue = file.name ?? ""
        sizeLabel.stringValue = file.size ?? ""
        dateLabel.stringValue = file.creationDate ?? ""
        hashLabel.stringValue = file.hashString

    }

}
