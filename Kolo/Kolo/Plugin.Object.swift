//
//  Plugin.swift
//  Kolo
//
//  Created by Ivan Kh on 24.12.2021.
//

import Foundation

class Plugin {
    private let url: URL
    
    init(_ url: URL) throws {
        self.url = url
    }
}


extension Plugin {
    var htmlURL: URL {
        return url.appendingPathComponent("main.html")
    }
}


extension Plugin {
    static func install(xpi src: URL, name: String) throws -> Plugin {
        let url = URL(plugin: name)
        
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        
        try FileManager.default.unzipItem(at: src, to: url)
        
        let pluginHtmlOldURL = url.appendingPathComponent("popup/panel.html")
        let pluginHtmlNewURL = url.appendingPathComponent("main.html")

        if FileManager.default.fileExists(atPath: pluginHtmlOldURL.path) {
            try? FileManager.default.moveItem(at: pluginHtmlOldURL, to: pluginHtmlNewURL)
        }
        
        var contents = try String(contentsOf: pluginHtmlNewURL)
        
        contents = contents.replacingOccurrences(of: "src=\"/", with: "src=\"./")
        contents = contents.replacingOccurrences(of: "href=\"/", with: "href=\"./")
        try contents.write(toFile: pluginHtmlNewURL.path, atomically: true, encoding: .utf8)
        
        return try Plugin(url)
    }
    
    static func download(src: URL, callback: @escaping (Plugin?, Error?) -> Void) {
        URLSession.shared.downloadTask(with: src) { temporaryURL, response, error in
            guard let temporaryURL = temporaryURL, error == nil else {
                debugPrint("Error while downloading document from url=\(src.absoluteString): \(error.debugDescription)")
                return
            }

            do {
                let plugin = try Plugin.install(xpi: temporaryURL, name: src.lastPathComponent)
                callback(plugin, nil)
            }
            catch {
                callback(nil, error)
            }
        }.resume()
    }
}


extension Plugin {
    static func loadFirst() -> Plugin? {
        guard let first = try? FileManager.default.contentsOfDirectory(at: URL.plugins,
                                                                       includingPropertiesForKeys: [],
                                                                       options: .skipsHiddenFiles).first
        else { return nil }
        
        return try? Plugin(first)
    }
}
