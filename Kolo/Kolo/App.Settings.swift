//
//  Settings.swift
//  Kolo
//
//  Created by Ivan Kh on 28.12.2021.
//

import Foundation


fileprivate extension Settings.Key {
    static let lastVisitedURL: Settings.Key = "last_visited_url"
}


extension Settings {
    static let shared = Settings()
}


extension Settings {
    public var lastVisitedURL: URL? {
        get { return readSetting(.lastVisitedURL) }
        set { writeSetting(.lastVisitedURL, newValue) }
    }
}
