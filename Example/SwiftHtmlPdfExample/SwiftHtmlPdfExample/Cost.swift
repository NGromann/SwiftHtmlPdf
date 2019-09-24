//
//  Cost.swift
//  SwiftHtmlPdfExample
//
//  Created by Niklas Gromann on 23.09.19.
//  Copyright © 2019 example. All rights reserved.
//

import Foundation
import SwiftHtmlPdf

// MARK: - Cost

class Cost {
    var title: String
    var amount: Double
    var paidAmount: Double
    
    init(_ title: String, amount: Double, paidAmount: Double) {
        self.title = title
        self.amount = amount
        self.paidAmount = paidAmount
    }
}
    
extension Cost: PDFComposerDelegate {
    func valueForParameter(parameter: String, index: Int) -> String {
        switch parameter {
        case "Name":
            return title
        case "Amount":
            return CurrencyFormatter.string(from: amount as NSNumber) ?? ""
        case "Paid":
            return CurrencyFormatter.string(from: paidAmount as NSNumber) ?? ""
        default:
            print("Unhandled PDF Key \(parameter) in Cost")
            return parameter
        }
    }
    
    func itemsForParameter(parameter: String, index: Int) -> [PDFComposerDelegate] {
        return []
    }
}

// MARK: - CostGroup

//class CostGroup {
//    
//    var costs: [Cost]
//    
//    init (_ costs: [Cost]) {
//        self.costs = costs
//    }
//}
//
//extension CostGroup: PDFComposerDelegate {
//    func valueForParameter(parameter: String, index: Int) -> String {
//        return ""
//    }
//    
//    func itemsForParameter(parameter: String, index: Int) -> [PDFComposerDelegate] {
//        return costs
//    }
//}
