//
// This Source Code Form is subject to the terms of the Mozilla Public
// License, v. 2.0. If a copy of the MPL was not distributed with this
// file, You can obtain one at http://mozilla.org/MPL/2.0/.
//
// TextGraphic.swift
// Milestones
//
// Copyright (c) 2016 Altay Cebe
//


import Foundation
import Cocoa

class TextGraphic :Graphic,NSTextStorageDelegate {

    override dynamic var bounds :NSRect {
        didSet {
            updateTextView()
        }
    }

    struct Constants {
        private static var layoutmanager :NSLayoutManager?

        static var sharedLayoutmanager  :NSLayoutManager? {
            if (layoutmanager == nil){
                layoutmanager = NSLayoutManager()
                let textContainer = NSTextContainer(size:NSMakeSize(1.0e7, 1.0e7))
                textContainer.widthTracksTextView = false
                textContainer.heightTracksTextView = false
                layoutmanager!.addTextContainer(textContainer)
            }
            return layoutmanager
        }
    }

    private let textStorage = NSTextStorage() //NSTextStorage(string:"Dies ist ein Test.")

    override init() {
        super.init()
        fillColor = NSColor(red: 1.0, green: 1.0, blue: 1.0, alpha: 1.0)
        textStorage.delegate = self
        setHeightToMatchContents()
    }

    //MARK: Text Layout
    // See https://developer.apple.com/library/mac/documentation/TextFonts/Conceptual/CocoaTextArchitecture/TextSystemArchitecture/ArchitectureOverview.html#//apple_ref/doc/uid/TP40009459-CH7-CJBJHGAG


    func updateTextView(){
        let layoutManagers = textStorage.layoutManagers
        for index in 0..<layoutManagers.count {
            let aLayoutManager = layoutManagers[index]
            aLayoutManager.firstTextView?.frame = bounds
        }
    }

    // Figure out how big this graphic would have to be to show all of its contents. -glyphRangeForTextContainer: forces layout.
    func naturalSize() -> NSSize {

        //An NSLayoutManager object coordinates the layout and display of characters held in an NSTextStorage object. I
        let layoutManager = TextGraphic.Constants.sharedLayoutmanager

        //The NSTextContainer class defines a region where text is laid out. An NSLayoutManager uses NSTextContainer to determine where to break lines, lay out portions of text, and so on.
        let textContainer = layoutManager?.textContainers[0]
        textContainer?.containerSize = NSMakeSize(bounds.size.width, 1.0e7)

        //The NSTextStorage class defines the fundamental storage mechanism of TextKit.
        //A text storage object notifies its layout managers of changes to its characters or attributes, which lets the layout managers redisplay the text as needed.
        textStorage.addLayoutManager(layoutManager!)
        layoutManager?.glyphRange(for: textContainer!)
        let naturalSize = layoutManager!.usedRect(for: textContainer!).size
        textStorage.removeLayoutManager(layoutManager!)
        return naturalSize
    }

    @objc func setHeightToMatchContents(){
        let naturalSize = self.naturalSize()
        bounds = NSMakeRect(bounds.origin.x, bounds.origin.y, bounds.size.width, naturalSize.height)
    }


    //MARK: Editing
    func newEditingViewWithSuperviewBounds(_ superviewBounds :NSRect) -> NSTextView{

        let textContainer = NSTextContainer(containerSize: NSSize(width: bounds.size.width, height: 1.0e7))
        let textView = NSTextView(frame: bounds, textContainer: textContainer)

        let layoutManager = NSLayoutManager()
        layoutManager.addTextContainer(textContainer)
        textStorage.addLayoutManager(layoutManager)


        textView.setSelectedRange(NSMakeRange(0, textStorage.length))
        textView.minSize = NSMakeSize(bounds.size.width, 0.0)
        textView.maxSize = NSMakeSize(bounds.size.width, superviewBounds.size.height - bounds.origin.y)
        textView.isVerticallyResizable = true

        //Debug
        textView.drawsBackground = true
        textView.backgroundColor = NSColor(red: 0.0, green: 1.0, blue: 0.0, alpha: 1.0)

        return textView
    }

    func finalizeEditing(_ editingView :NSView) {

        if let textView = editingView as? NSTextView, let layoutManager = textView.layoutManager {
            textStorage.removeLayoutManager(layoutManager)
        }
    }

    //MARK: NSTextStorageDelegate
    override func textStorageDidProcessEditing(_ notification: Notification){
        self.perform(#selector(setHeightToMatchContents), with: self, afterDelay: 0.0)
    }


    //MARK: Drawing
    override func drawContentsInView(_ aView: NSView) {

        //Draw the fill color
        fillColor.set()
        bounds.fill()

        //Only draw the text if there is actually a text
        if (textStorage.length > 0)
        {
            // Get a layout manager, size its text container, and use it to draw text. -glyphRangeForTextContainer: forces layout and tells us how much of text fits in the container.
            let textContainer = TextGraphic.Constants.sharedLayoutmanager?.textContainers[0]
            textContainer?.containerSize = bounds.size
            textStorage.addLayoutManager(TextGraphic.Constants.sharedLayoutmanager!)
            let glyphRange = TextGraphic.Constants.sharedLayoutmanager?.glyphRange(for: textContainer!)
            if ((glyphRange?.length)! > 0) {
                TextGraphic.Constants.sharedLayoutmanager?.drawBackground(forGlyphRange: glyphRange!, at: bounds.origin)
                TextGraphic.Constants.sharedLayoutmanager?.drawGlyphs(forGlyphRange: glyphRange!, at: bounds.origin)
            }
        //Disabled: caues a build error on Xcode 8 Beta > 5     textStorage.removeLayoutManager(TextGraphic.Constants.layoutmanager!)

        }
    }
}
