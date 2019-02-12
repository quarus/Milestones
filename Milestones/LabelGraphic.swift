//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// LabelGraphic.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//

import Foundation
import Cocoa

class LabelGraphic: Graphic{

    //The NSTextStorage class defines the fundamental storage mechanism of TextKit.
    //A text storage object notifies its layout managers of changes to its characters or attributes, which lets the layout managers redisplay the text as needed.
    private let textStorage = NSTextStorage()

    //An NSLayoutManager object coordinates the layout and display of characters held in an NSTextStorage object.
    private let layoutManager = NSLayoutManager()

    //The NSTextContainer class defines a region where text is laid out.
    //An NSLayoutManager uses NSTextContainer to determine where to break lines, lay out portions of text, and so on.
    private let textContainer :NSTextContainer

    var textAlignment :NSTextAlignment = .center
    var font :NSFont = NSFont(name: "Helvetica", size: 14)!
    var text :String = " " {
        didSet {
            sizeToFit()
        }
    }

    override dynamic var bounds :NSRect {
        didSet {
            textContainer.size = bounds.size
        }
    }



    // Figure out how big this graphic would have to be to show all of its contents. -glyphRangeForTextContainer: forces layout.
    func naturalSize() -> NSSize {

        update()

        //The NSTextContainer class defines a region where text is laid out. An NSLayoutManager uses NSTextContainer to determine where to break lines, lay out portions of text, and so on.
        textContainer.containerSize = NSMakeSize(bounds.size.width, 1.0e7)

        //The NSTextStorage class defines the fundamental storage mechanism of TextKit.
        //A text storage object notifies its layout managers of changes to its characters or attributes, which lets the layout managers redisplay the text as needed.
        textStorage.addLayoutManager(layoutManager)
        layoutManager.glyphRange(for: textContainer)
        let naturalSize = layoutManager.usedRect(for: textContainer).size
        textStorage.removeLayoutManager(layoutManager)
        return naturalSize
    }

    private func update(){
        let style = NSMutableParagraphStyle()
        style.alignment = textAlignment

        let attributes :[NSAttributedStringKey:Any] = [
            .paragraphStyle : style,
            .font: font
        ]
        setAttributedString(string: NSMutableAttributedString(string: text, attributes: attributes))
    }

    //MARK: Initializer
    override init() {
        textContainer = NSTextContainer(size:NSMakeSize(1.0e7, 1.0e7))
        super.init()

        textContainer.widthTracksTextView = false
        textContainer.heightTracksTextView = false
        layoutManager.addTextContainer(textContainer)

    }

    convenience init(attributedString :NSMutableAttributedString) {
        self.init()
        setAttributedString(string: attributedString)
    }


    //MARK: Drawing
    override func drawContentsInView(_ aView: NSView) {

        update()

        if (textStorage.length > 0)
        {
            textContainer.containerSize = NSMakeSize(bounds.size.width, 1.0e7)
            textStorage.addLayoutManager(layoutManager)

            let glyphRange = layoutManager.glyphRange(for: textContainer)
            if isDrawingFill {
                fillColor.set()
                bounds.fill()
                layoutManager.drawBackground(forGlyphRange: glyphRange, at: bounds.origin)
            }
            layoutManager.drawGlyphs(forGlyphRange: glyphRange, at: bounds.origin)
            textStorage.removeLayoutManager(layoutManager)

        }
    }

    func sizeToFit (){
        let size = naturalSize()
        bounds = NSRect(x: bounds.origin.x, y: bounds.origin.y, width: bounds.size.width, height: size.height)
    }

    private func setAttributedString(string :NSMutableAttributedString){

        textStorage.setAttributedString(string)
    }
}
