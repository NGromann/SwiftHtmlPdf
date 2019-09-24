//
//  PDFController.swift
//  EinfachHausbau
//
//  Created by Niklas Gromann Privat on 27.12.18.
//  Copyright © 2018 Einfach Hausbau. All rights reserved.
//

import Foundation
import UIKit
import SafariServices

public class PDFComposer {
    static public func renderHtml(templateResource: String, delegate: PDFComposerDelegate) -> String? {
        guard let path = Bundle.main.path(forResource: templateResource, ofType: "html") else {
            return nil
        }
        do {
            var template = try String(contentsOfFile: path)
            
            let regions = parseRegionsInTemplate(&template)
            
            return parseRegion(template, delegate: delegate, regions: regions)
        }
        catch {
            return nil
        }
    }
    
    private static func parseRegion(_ region: String, delegate: PDFComposerDelegate, regions: [String: String], index: Int = 0) -> String {
        var result = replaceValuesOfTemplate(region, delegate: delegate, index: index)
        result = replaceItemsInTemplate(result, delegate: delegate, regions: regions, index: index)
        return result
    }
    
    private static func replaceValuesOfTemplate(_ template: String, delegate: PDFComposerDelegate, index: Int) -> String {
        guard let regex = try? NSRegularExpression(pattern: "<field name=\"(.*?)\"\\/>", options: .caseInsensitive) else {
            return template
        }
        
        let str = template as NSString
        let matches = regex.matches(in: template, options: [], range: NSRange(location: 0, length: str.length)).map {
            (str.substring(with: $0.range), str.substring(with: $0.range(at: 1)))
        }
        
        var result = template
        for match in matches {
            let value = delegate.valueForParameter(parameter: match.1, index: index)
            result = result.replacingOccurrences(of: match.0, with: value, options: .literal, range: nil)
        }
        
        return result
    }
    
    private static func replaceItemsInTemplate(_ template: String, delegate: PDFComposerDelegate, regions: [String: String], index: Int) -> String {
        guard let regex = try? NSRegularExpression(pattern: "<item name=\"(.*)\"\\/>", options: .caseInsensitive) else {
            return template
        }
        
        let str = template as NSString
        let matches = regex.matches(in: template, options: [], range: NSRange(location: 0, length: str.length)).map {
            (str.substring(with: $0.range), str.substring(with: $0.range(at: 1)))
        }
        
        var result = template
        for match in matches {
            let items = delegate.itemsForParameter(parameter: match.1, index: index)
            var value = ""
            for (i, item) in items.enumerated() {
                guard let region = regions[match.1] else { continue }
                value += parseRegion(region, delegate: item, regions: regions, index: i)
            }
            result = result.replacingOccurrences(of: match.0, with: value, options: .literal, range: nil)
        }
        
        return result
    }
    
    private static func parseRegionsInTemplate(_ template: inout String) -> [String: String] {
        guard let regex = try? NSRegularExpression(pattern: "(?s)<region name=\"(.*?)\">(.*?)<\\/region>", options: .caseInsensitive) else {
            return [:]
        }
        
        let str = template as NSString
        let matches = regex.matches(in: template, options: [], range: NSRange(location: 0, length: str.length)).map {
            (str.substring(with: $0.range), str.substring(with: $0.range(at: 1)))
        }
        
        var result = [String: String]()
        
        for match in matches {
            template = template.replacingOccurrences(of: match.0, with: "", options: .literal, range: nil)
            result[match.1] = match.0
                .replacingOccurrences(of: "<region name=\"\(match.1)\">", with: "")
                .replacingOccurrences(of: "</region>", with: "")
        }
        
        return result
    }
    
    static func exportHTMLContentToPDF(HTMLContent: String, path: String? = nil) -> String {
        let printPageRenderer = CustomPrintPageRenderer()
        
        let printFormatter = UIMarkupTextPrintFormatter(markupText: HTMLContent)
        printPageRenderer.addPrintFormatter(printFormatter, startingAtPageAt: 0)
        
        let pdfData = drawPDFUsingPrintPageRenderer(printPageRenderer: printPageRenderer)
        
        let docDir = NSSearchPathForDirectoriesInDomains(.documentDirectory, .userDomainMask, true)[0]
        let pdfFilename = path ?? "\(docDir)/PDFExport.pdf"
        
        pdfData.write(toFile: pdfFilename, atomically: true)
        
        print("successfully saved pdf at: \(pdfFilename)")
        return pdfFilename
    }
    
    static func drawPDFUsingPrintPageRenderer(printPageRenderer: UIPrintPageRenderer) -> NSData {
        let data = NSMutableData()
        
        UIGraphicsBeginPDFContextToData(data, CGRect.zero, nil)
        printPageRenderer.prepare(forDrawingPages: NSMakeRange(0, printPageRenderer.numberOfPages))
        
        let bounds = UIGraphicsGetPDFContextBounds()
        
        for i in 0...(printPageRenderer.numberOfPages - 1) {
            UIGraphicsBeginPDFPage()
            printPageRenderer.drawPage(at: i, in: bounds)
        }
        
        UIGraphicsEndPDFContext();
        return data
    }
}

import WebKit

public class PDFPreview: UIViewController, WKUIDelegate {
    
    var webView: WKWebView!
    
    public var delegate: PDFComposerDelegate?
    public var resource: String?
    
    weak var displayingVC: UIViewController?
    
    private var htmlContent: String?
    
    public override func loadView() {
        super.loadView()
        
        let webConfiguration = WKWebViewConfiguration()
        webView = WKWebView(frame: .zero, configuration: webConfiguration)
        webView.uiDelegate = self
        view = webView
    }
    
    public override func viewWillAppear(_ animated: Bool) {
        super.viewWillAppear(animated)
        
        loadPreview()
        
        UIApplication.shared.statusBarStyle = .default
    }
    
    public override func viewWillDisappear(_ animated: Bool) {
        super.viewDidDisappear(animated)
        
        UIApplication.shared.statusBarStyle = .lightContent
    }
    
    private func loadPreview() {
        guard let delegate = delegate, let templateResource = resource else {
            print("could not load Preview. Delegate not set!")
            return
        }
        
        guard let htmlContent = PDFComposer.renderHtml(templateResource: templateResource, delegate: delegate) else {
            print("could not generate HTML.")
            return
        }
        
        self.htmlContent = htmlContent
        
        webView.loadHTMLString(htmlContent, baseURL: nil)
    }
    
    @IBAction func cancelButtonTapped(_ sender: Any) {
        dismiss(animated: true, completion: nil)
    }
    @IBAction func savevButtonTapped(_ sender: UIBarButtonItem) {
        guard let htmlContent = htmlContent, let displayingVC = displayingVC else {
            print("could not save.")
            return
        }
        
        let path = PDFComposer.exportHTMLContentToPDF(HTMLContent: htmlContent)
        let pdfData = NSData(contentsOfFile: path)
        let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
//        dismiss(animated: true, completion: nil)
        self.present(activityVC, animated: true, completion: nil)
        activityVC.popoverPresentationController?.barButtonItem = sender
    }
}

class CustomPrintPageRenderer: UIPrintPageRenderer {
    
    let A4PageWidth: CGFloat = 595.2
    let A4PageHeight: CGFloat = 841.8
    
    override init() {
        super.init()
        
        // Specify the frame of the A4 page.
        let pageFrame = CGRect(x: 0.0, y: 0.0, width: A4PageWidth, height: A4PageHeight)
        
        // Set the page frame.
        self.setValue(NSValue(cgRect: pageFrame), forKey: "paperRect")
        
        // Set the horizontal and vertical insets (that's optional).
//        self.setValue(NSValue(cgRect: pageFrame), forKey: "printableRect") // No Inset
        self.setValue(NSValue(cgRect: pageFrame.insetBy(dx: 10, dy: 10)), forKey: "printableRect") // Inset

    }
}

public protocol PDFComposerDelegate {
    func valueForParameter(parameter: String, index: Int) -> String
    func itemsForParameter(parameter: String, index: Int) -> [PDFComposerDelegate]
}
