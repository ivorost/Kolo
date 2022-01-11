//
//  Plugin.swift
//  Kolo
//
//  Created by Ivan Kh on 24.12.2021.
//

import Foundation


fileprivate extension String {
    static let manifestFileName = "manifest.json"
}


fileprivate struct PluginManifest {
    let htmlPath: String
}

extension PluginManifest : Decodable {
    private enum RootCodingKeys: String, CodingKey {
        case browser_action
    }

    private enum BrowserActionCodingKeys: String, CodingKey {
        case default_popup
    }

    public init(from decoder: Decoder) throws {
        let root = try decoder.container(keyedBy: RootCodingKeys.self)
        let browserAction = try root.nestedContainer(keyedBy: BrowserActionCodingKeys.self,
                                                     forKey: .browser_action)
        self.htmlPath = try browserAction.decode(String.self, forKey: .default_popup)
    }

}


extension Plugin {
    enum Error : Swift.Error {
        case badHtmlPath
    }
}


class Plugin {
    let url: URL
    let htmlURL: URL
    
    init(_ url: URL) throws {
        let manifestURL = url.appendingPathComponent(.manifestFileName)
        let manifest = try JSONDecoder().decode(PluginManifest.self, from: try Data(contentsOf: manifestURL))
        
        self.url = url
        
        guard let htmlURL = URL(string: manifest.htmlPath, relativeTo: url) else {
            throw Error.badHtmlPath
        }
        
        self.htmlURL = htmlURL
    }
}


extension Plugin {
    static func install(xpi src: URL, name: String) throws -> Plugin {
        let url = URL(plugin: name)
        
        if FileManager.default.fileExists(atPath: url.path) {
            try FileManager.default.removeItem(at: url)
        }
        
        try FileManager.default.unzipItem(at: src, to: url)
                
        return try Plugin(url)
    }
    
    static func download(src: URL, callback: @escaping (Plugin?, Swift.Error?) -> Void) {
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
