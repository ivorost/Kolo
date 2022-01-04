//
//  WebKit.WKScriptMessage.swift
//  Kolo
//
//  Created by Ivan Kh on 28.12.2021.
//

import WebKit

extension WKScriptMessage {
    var params: [String : Any] {
        return body as? [String : Any] ?? [:]
    }
}
