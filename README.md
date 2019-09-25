# SwiftHtmlPdf

Generate HTML and PDF documents by using template html files and filling them with your data.

This library allows you to generate HTML and PDF using HTML template files. Try out our [example project!](/Example)

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

### Create a html template resource and save it in your project:
```html
<!DOCTYPE html>
<html>
	<head>
		<meta http-equiv="Content-Type" content="text/html; charset=utf-8" />
        <meta content="text/html; charset=utf-8" http-equiv="content-type">
		...
		</style>
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

Note the following HTML tags
* ```<item name="MyListItem"/>```
  * This is a reference to the *MyListItem* region.
* ```<region name="MyListItem">...</region>```
  * This is a blueprint for an instance of *MyListItem*
* ```<field name="Name"/>```
  * This is a field that will be replaced by a variable
  
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
            print("Unhandled PDF Key \(parameter) in Cost")
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
* resourceName is the file name of the [template html](#Create-a-html-template-resource-and-save-it-in-your-project)
* delegate is the View Controller (the root object)
