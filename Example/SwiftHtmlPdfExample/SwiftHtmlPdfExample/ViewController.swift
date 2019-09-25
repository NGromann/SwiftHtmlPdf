//
//  ViewController.swift
//  SwiftHtmlPdfExample
//
//  Created by Niklas Gromann on 23.09.19.
//  Copyright © 2019 example. All rights reserved.
//

import UIKit
import SwiftHtmlPdf

// MARK: - Main View Controller
class ViewController: UIViewController {

    @IBOutlet weak var tableView: UITableView!
    
    var costs = [Cost("Other Frameworks", amount: 20.0, paidAmount: 20.0), Cost("SwiftHtmlPdf", amount: 0.0, paidAmount: 0.0)]
    var budget = 500.0
    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view.
        
        tableView.dataSource = self
    }
}
// MARK: - Dialogs
extension ViewController {
    @IBAction func editTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Budget", message: "Enter your Budget", preferredStyle: .alert)
               
        alert.addTextField { (textField) in
            textField.placeholder = "Budget"
            textField.text = String(self.budget)
        }

       // 3. Grab the value from the text field, and print it when the user clicks OK.
       alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard
                let budget = Double(alert?.textFields?[0].text ?? "")
            else {
                return
            }
            
            self.budget = budget
       }))

       // 4. Present the alert.
       self.present(alert, animated: true, completion: nil)
    }

    @IBAction func addTapped(_ sender: Any) {
        let alert = UIAlertController(title: "Add a Cost Entry", message: nil, preferredStyle: .alert)
        
        alert.addTextField { (textField) in
            textField.placeholder = "Title"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Cost"
        }
        alert.addTextField { (textField) in
            textField.placeholder = "Paid Amount"
        }

        // 3. Grab the value from the text field, and print it when the user clicks OK.
        alert.addAction(UIAlertAction(title: "OK", style: .default, handler: { [weak alert] (_) in
            guard
                let title = alert?.textFields?[0].text,
                let amount = Double(alert?.textFields?[1].text ?? "")
            else {
                return
            }
            let paidAmount = Double(alert?.textFields?[2].text ?? "") ?? amount
            
            self.costs.append(Cost(title, amount: amount, paidAmount: paidAmount))
            
            DispatchQueue.main.async {
                self.tableView.reloadData()
            }
        }))

        // 4. Present the alert.
        self.present(alert, animated: true, completion: nil)
    }
    
    @IBAction func shareTapped(_ sender: Any) {
        showPdfPreview()
    }
}

// MARK: - Table View

extension ViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return costs.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: "Cost Cell", for: indexPath)
        let cost = costs[indexPath.item]
        cell.textLabel?.text = cost.title
        
        cell.detailTextLabel?.text = CurrencyFormatter.string(from: cost.amount as NSNumber)
        cell.detailTextLabel?.textColor = cost.paidAmount >= cost.amount ? UIColor.gray : UIColor.label
        return cell
    }
}

// MARK: - SwiftHtmlPdf Implementation
extension ViewController: PDFComposerDelegate {
    func showPdfPreview() {
        let preview = PDFPreview()
        
        do {
            try preview.loadPreviewFromHtmlTemplateResource(templateResource: "planbuildpro-baukosten-template", delegate: self)
        
            present(preview, animated: true, completion: nil)
        } catch {
            print("Could not open pdf preview")
        }
    }
    
    func valueForParameter(parameter: String, index: Int) -> String {
        switch parameter {
        case "Budget":
            return CurrencyFormatter.string(from: self.budget as NSNumber) ?? ""
        case "CostSum":
            return CurrencyFormatter.string(from: self.costSum as NSNumber) ?? ""
        case "PaidSum":
            return CurrencyFormatter.string(from: self.paidSum as NSNumber) ?? ""
        case "CostDifference":
            return CurrencyFormatter.string(from: self.costDifference as NSNumber) ?? ""
        case "PaidDifference":
            return CurrencyFormatter.string(from: self.paidDifference as NSNumber) ?? ""
        case "Date":
            return Date().toString(format: "dd.MM.YYYY")
        default:
            print("Unhandled PDF Key \(parameter) in ViewController")
            return parameter
        }
    }
    
    func itemsForParameter(parameter: String, index: Int) -> [PDFComposerDelegate] {
        return costs
    }
    
}

// MARK: - CurrencyFormatter
class CurrencyFormatter: NumberFormatter {
    private static var instance: CurrencyFormatter = {
       return CurrencyFormatter()
    }()
    
    override init() {
        super.init()
        
        self.locale = .current
        self.numberStyle = .currency
    }
    
    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }
    
    static func string(from: NSNumber) -> String? {
        return instance.string(from: from as NSNumber)
    }
}

// MARK: - DateFormatter
extension Date
{
    func toString(format: String) -> String
    {
        let dateFormatter = DateFormatter()
        dateFormatter.dateFormat = format
        return dateFormatter.string(from: self)
    }

}

// MARK: - View Helpers
extension ViewController {
    var costSum: Double {
        return costs.map{$0.amount}.reduce(0, +)
    }
    
    var paidSum: Double {
        return costs.map{$0.paidAmount}.reduce(0, +)
    }
    
    var costDifference: Double {
        return budget - costSum
    }
    
    var paidDifference: Double {
        return budget - paidSum
    }
}
