//
//  Settings.swift
//  Kolo
//
//  Created by Ivan Kh on 28.12.2021.
//

import Foundation

fileprivate extension URL {
    static let appSettings = settings.appendingPathComponent("app.xml")
}


public class Settings {
    public typealias Key = String

    public init() {}
    
    open func readSetting<T>(_ forKey: Key) -> T? {
        let plistContents = NSDictionary(contentsOf: .appSettings)
        return plistContents?[forKey] as? T
    }
    
    open func writeSetting(_ key: Key, _ val: Any?) {
        let plistContents = NSMutableDictionary(contentsOf: .appSettings) ?? NSMutableDictionary()
                
        plistContents[key] = val
        plistContents.write(to: .appSettings, atomically: true)
    }
}


public extension Settings {
    func readSetting(_ forKey: Key) -> URL? {
        guard
            let base64: String = readSetting(forKey),
            let data = Data(base64Encoded: base64)
        else { return nil }
        
        var isStale = false
        return try? URL(resolvingBookmarkData: data, bookmarkDataIsStale: &isStale)
    }
    
    func writeSetting(_ key: Key, _ val: URL?) {
        writeSetting(key, try? val?.bookmarkData().base64EncodedString())

    }
}
