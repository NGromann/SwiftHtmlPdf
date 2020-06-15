<img align="left" width="120" height="120" src="Resources/Icon.png" alt="Resume application project app icon">

# SwiftHtmlPdf

<p align="left">
<a href="https://cocoapods.org/pods/SwiftHtmlPdf"><img src="https://img.shields.io/cocoapods/v/SwiftHtmlPdf" alt="CocoaPods compatible" /></a>
<img src="https://img.shields.io/badge/platform-iOS-blue.svg?style=flat" alt="Platform iOS" />
<a href="https://developer.apple.com/swift"><img src="https://img.shields.io/badge/swift5-compatible-4BC51D.svg?style=flat" alt="Swift 5 compatible" /></a>
<a href="https://github.com/NGromann/SwiftHtmlPdf/blob/master/LICENSE"><img src="http://img.shields.io/badge/license-MIT-blue.svg?style=flat" alt="License: MIT" /></a>
</p>


Generate HTML and PDF documents by using template html files and filling them with your data.

This library allows you to generate HTML and PDF using HTML template files. Try out our [example project!](/Example/SwiftHtmlPdfExample)

## Requirements

* IOS 10 +

## Installation

You can install SwiftHtmlPdf using Cocoa Pods.

Add SwiftHtmlPdf into your project's `Podfile`:

```ruby
target 'MyApp' do
  pod 'SwiftHtmlPdf', '~> 1.0'
end
```

Then run the following command:

```bash
$ pod install
```

## Usage

### Workflow

SwiftHtmlPdf works in 3 layers.

##### [HTML](#Create-a-html-template-resource-and-save-it-in-your-project)
You create a template HTML document that will then be filled with your data from the Swift code. 
We defined 3 new HTML tags, that can be used to fill your HTML document with all kinds of data structures.

##### [Swift](#Fill-the-template-with-data)
Using a `PDFComposerDelegate` you can map your swift classes to the HTML Template.

##### [PDF](#Show-a-Preview-Dialog-in-your-app)
The created HTML document can be transformed into a PDF file. You can save and show the PDF in your app or display an `UIActivityViewController` so the user can send it around.

### Create a html template resource and save it in your project
```html
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        	<meta content="text/html; charset=utf-8" http-equiv="content-type">
	</head>
	<body>
        <h1>PDF Example</h1>
        <ul>
            <item name="MyListItem"/>
        </ul>
	</body>
</html>

<region name="MyListItem">
    <li>
        <field name="Name"/>
    </li>
</region>
```

SwiftHtmlPdf adds 3 HTML Tags for templating:

#### Regions
Syntax: 
```html
<region name="{name}">...</region>
```

Regions are templates for classes in Swift. Regions should be defined at the beginning or end of the HTML Template. 

#### Items
Syntax: 
```html
<item name="{name}"/>
```

Items are references to regions. When defining a Item in your template, SwiftHtmlPdf will call `itemsForParameter(parameter: String, index: Int)` of the current `PDFComposerDelegate`. The function should return a list of `PDFComposerDelegate` to instantiate at the given position. SwiftHtmlPdf then tries to find and create a copy of the region. Item tags can also be placed in Regions.

#### Fields
Syntax:
```html
<field name="{name}"/>
```

Using fields you can output text into the html document. Fields can also be placed in Regions. When a field is found in your template, SwiftHtmlPdf will call `valueForParameter(parameter: String, index: Int) -> String` of the current `PDFComposerDelegate`. `parameter` is the name if the field.
  
### Fill the template with data
First create your model and implement ```PDFComposerDelegate```
```swift
import SwiftHtmlPdf
...
class MyListItem: PDFComposerDelegate {
    var name: String
    
    init(_ name: String) {
    	self.name = name
    }
    
    func valueForParameter(parameter: String, index: Int) -> String {
        switch parameter {
        case "Name":
            return name
        default:
            print("Unhandled PDF Key \(parameter) in MyListItem")
            return parameter
        }
    }
    
    func itemsForParameter(parameter: String, index: Int) -> [PDFComposerDelegate] {
        return []
    }
}
```

Now implement the delegate in your root object. In this case, the root object is the ViewController.
```swift
extension ViewController: PDFComposerDelegate {
    var myListItems = [MyListItem("Hello"), MyListItem("World")]
    
    func valueForParameter(parameter: String, index: Int) -> String {
    	return ""
    }
    
    func itemsForParameter(parameter: String, index: Int) -> [PDFComposerDelegate] {
        return myListItems
    }
```

Note the following delegate functions:
* ```valueForParameter(parameter: String, index: Int)```
	* This function is called for every ```<field name="{parameter}"/>``` in your template
* ```func itemsForParameter(parameter: String, index: Int) -> [PDFComposerDelegate]```
	* The function is called for every ```<item name="{parameter}"/>``` in the current region of the template
	* Return an array of child objects that will handle the region.
	* For every returned object, a new region will be instantiated: ```<region name="{parameter}">...</region>```

### Show a Preview Dialog in your app
```swift
func showPdfPreview() {
        let preview = PDFPreviewController.instantiate()
        
        do {
	    let resourceName = "planbuildpro-baukosten-template"
	    let delegate = self
            try preview.loadPreviewFromHtmlTemplateResource(templateResource: resourceName, delegate: delegate)

            present(preview, animated: true, completion: nil)
        } catch {
            print("Could not open pdf preview")
        }
    }
```
* resourceName is the file name of the [template html](#Create-a-html-template-resource-and-save-it-in-your-project). Do not include the suffix (.html)
* delegate is the View Controller (the root object)

### Parsing templates without the Preview Dialog
To parse the html template without the preview dialog, you can the following function:
```swift
let htmlContent = PDFComposer.renderHtmlFromResource(templateResource: templateResource, delegate: delegate)
```
This function works similar to the preview dialog but returns parsed html.

Next up you can transform the html content into a PDF:
```swift
let pdfData = PDFComposer.exportHTMLContentToPDF(HTMLContent: htmlContent)
```

Alternatively you can use the following function to create a pdf file:
```swift
let pdfData = PDFComposer.exportHTMLContentToPDFFile(HTMLContent: htmlContent, path: path)
```

Now you can share the pdf using a ```UIActivityViewController```:
```swift
let activityVC = UIActivityViewController(activityItems: [pdfData], applicationActivities: nil)
        
self.present(activityVC, animated: true, completion: nil)
```

## FAQ
#### Can I use CSS in the HTML Templates?
Yes you can! But only using inline css. External references do not work.

#### Does this framework work with Catalyst?
We are currently investigating a bug where PDF generation causes a crash. However, the HTML generation works fine.
