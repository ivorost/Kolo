//
//  AppKit.TextField.swift
//  Kolo
//
//  Created by Ivan Kh on 11.01.2022.
//

import Cocoa


class PaddedTextFieldCell: NSTextFieldCell {

    @IBInspectable var paddingTop: CGFloat = 0
    @IBInspectable var paddingLeft: CGFloat = 0

    override func drawingRect(forBounds rect: NSRect) -> NSRect {
        let rectInset = NSMakeRect(rect.origin.x + paddingLeft,
                                   rect.origin.y + paddingTop,
                                   rect.size.width - paddingLeft,
                                   rect.size.height - paddingTop)
        
        return super.drawingRect(forBounds: rectInset)
    }
}
