//
//  ActionViewController.swift
//  ActionExtension
//
//  Created by Robert Berry on 6/26/18.
//  Copyright © 2018 Robert Berry. All rights reserved.
//

import UIKit
import MobileCoreServices

class ActionViewController: UIViewController {

    // MARK: Properties
    
    @IBOutlet weak var textView: UITextView!
    
    // Enum provides different languages that the text can be translated into. 
    
    enum Language: String {
       
        case spanish = "es"
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
    
        // Get the item[s] we're handling from the extension context.
        
        // For example, look for text and place it into a text view.
        
        // Replace this with something appropriate for the type[s] your extension supports.
        
        var textFound = false
        
        for item: Any in self.extensionContext!.inputItems {
            
            let inputItem = item as! NSExtensionItem
            
            for provider: Any in inputItem.attachments! {
                
                let itemProvider = provider as! NSItemProvider
                
                // Iterates over the attachments sent by the host app, and looks for an attachment that conforms to the kUTTypePlainText type.
                
                if itemProvider.hasItemConformingToTypeIdentifier(kUTTypePlainText as String) {
                    
                    // Fetch content of the text attachment.
                    
                    itemProvider.loadItem(forTypeIdentifier: kUTTypePlainText as String, options: nil, completionHandler: { (text, error) in
                        
                        // After the text has been fetched, it is displayed in the text view.
                        
                        if let text = text as? String {
                            
                            OperationQueue.main.addOperation {
                                
                                // Implement function to translate text into another language.
                                
                                self.translateTextIntoSpecifiedLanguage(text: text, lang: Language.spanish, textView: self.textView)
                            }
                        }
                    })
                    
                    textFound = true
                    
                    break
                }
            }
            
            if (textFound) {
                
                // We only handle one snippet of text, so stop looking for more.
                
                break
            }
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }

    @IBAction func done() {
        // Return any edited content to the host app.
       
        // This template doesn't do anything, so we just echo the passed in items.
       
        self.extensionContext!.completeRequest(returningItems: self.extensionContext!.inputItems, completionHandler: nil)
    }
    
    // MARK: Helper Methods
    
    // Method to convert text view text into another language.
    
    func translateTextIntoSpecifiedLanguage(text: String, lang: Language, textView: UITextView) {
        
        // Provides the raw value from the enum of the language to translate the text into.
        
        let languageToTranslateInto = lang.rawValue
        
        // Provides the URL that will make the translation request.
        
        let urlText  = "https://api-platform.systran.net/translation/text/translate?key=e1c5251c-4b1c-4808-846f-9fbd8e60a00e&source=auto&target=\(languageToTranslateInto)&input=\(text)"
       
        let urlEncodedEndPoint = urlText.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
        
        // Guard statement checks that the URL is the one that was previously specified, and provides for error handling if the URL is not correct.
        
        guard let url = URL(string: urlEncodedEndPoint!) else {
            
            print("The URL is incorrect.")
            
            textView.text = "There has been an error processing your translation request."
           
            return
        }

        // Create URL Session
        
        URLSession.shared.dataTask(with: url) { (data, response, error) in
            
            DispatchQueue.main.async {
                
                guard error == nil else {
                    
                    print(error!)
                    
                    textView.text = "An error has occured, please try your request again."
                    
                    return
                }
                
                guard let data = data else { return }
                
                do {
                   
                    guard let resultNSDict = try JSONSerialization.jsonObject(with: data, options: []) as? NSDictionary else {
                       
                        print("An error occured while trying to read the JSON.")
                       
                        textView.text = "An error has occured, please try your request again."
                        
                        return
                    }
                   
                    if let output = resultNSDict.value(forKeyPath: "outputs.output") as? [String] {
                        
                        // Returns the first element of the collection as text for the text view.
                        
                        textView.text = "Spanish Text: " + output.first!
                    
                    } else if let output = resultNSDict.value(forKeyPath: "outputs.output") as? String {
                        
                        // // Returns the string as text for the text view.
                        
                        textView.text = "SSpanish Text: " + output
                    }
                    
                } catch {
                   
                    print("Unable to retrieve data from the systran database.")
                    
                    textView.text = "An error has occured, please try your request again."
                   
                    return
                }
            }
        }.resume()
        
    }
}
