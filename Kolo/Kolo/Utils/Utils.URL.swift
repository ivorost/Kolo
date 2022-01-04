//
//  URL.swift
//  Kolo
//
//  Created by Ivan Kh on 24.12.2021.
//

import Foundation

extension URL {
    init(plugin name: String) {
        self.init(fileURLWithPath: URL.plugins.appendingPathComponent(name).path)
    }
}


public extension URL {
    static let plugins = library.appendingPathComponent("Plugins")
    static let library = FileManager.default.urls(for: .libraryDirectory, in: .userDomainMask)[0]
    static let documents = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask)[0]
    static let logs = documents.appendingPathComponent("Logs")
    static let settings = library.appendingPathComponent("Settings")
}


extension URL {
    var isTopSiteButtonURL: Bool {
        return path.hasSuffix("top_sites_button-1.5-fx.xpi")
    }
}
