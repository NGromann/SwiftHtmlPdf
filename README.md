# SwiftHtmlPdf

Generate HTML and PDF documents by using template html files and filling them with your data.

This library allows you to generate HTML and PDF using HTML template files. Try out our [example project!](/Example)

## Installation

You can install SwiftHtmlPdf using Cocoa Pods.

Specify SwiftHtmlPdf into your project's `Podfile`:

```ruby
source 'https://github.com/CocoaPods/Specs.git'
platform :ios, '12.0'
use_frameworks!

pod 'SwiftHtmlPdf'
```

Then run the following command:

```bash
$ pod install
```

## Usage

1. Import the library:
```swift
import SwiftHtmlPdf
```

2. Create a html template resource and save it in your project:
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
