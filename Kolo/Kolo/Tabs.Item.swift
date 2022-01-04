//
//  Tabs.Item.swift
//  Kolo
//
//  Created by Ivan Kh on 30.12.2021.
//

import AppKit


fileprivate extension String {
    static let defaultTitle = "Start page"
}


class TabsItem : NSCollectionViewItem {
    var navigate: ((String) -> Void)?

    @IBOutlet private var box: NSBox!
    @IBOutlet private var label: NSTextField!
    @IBOutlet private var input: NSTextField!

    override func prepareForReuse() {
        super.prepareForReuse()
        input.isHidden = true
        input.stringValue = ""
    }
    
    var url: URL? {
        didSet {
            label.stringValue = url?.host ?? .defaultTitle
            input.stringValue = url?.absoluteString ?? ""
        }
    }
    
    override var isSelected: Bool {
        didSet {
            let beginInput = input.isHidden && isSelected && input.stringValue == ""
            
            label.isHidden = isSelected
            input.isHidden = !isSelected

            if beginInput {
                DispatchQueue.main.async {
                    self.input.window?.makeFirstResponder(self.input)
                }
            }
            
            box.fillColor = isSelected
            ? .koloTabSelected
            : .koloTabUnselected
        }
    }
    
    @IBAction @objc func addressBarAction(_ sender: NSTextField) {
        navigate?(sender.stringValue)
    }
}
