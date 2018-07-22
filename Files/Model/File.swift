//
//  File.swift
//  Files
//
//  Created by Vladimir Abdrakhmanov on 7/22/18.
//  Copyright © 2018 Vladimir Abdrakhmanov. All rights reserved.
//

import AppKit

class File: NSObject {
    var image: NSImage?
    var name: String
    var path: URL
    var size: String?
    var type: String?
    var creationDate: String?

    var hashString: String {
        var value = self
        let data = Data(bytes: &value, count: MemoryLayout<File>.stride)
        return data.sha1().toHexString()
    }

    init(name: String, path: URL) {
        self.name = name
        self.path = path
    }

}
