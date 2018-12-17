//
//  ViewController.swift
//  webviewCollectionView
//
//  Created by Jacob Bailosky on 12/11/18.
//  Copyright © 2018 Jacob Bailosky. All rights reserved.
//

import UIKit
import WebKit

class ViewController: UIViewController, UITableViewDelegate, UITableViewDataSource, UICollectionViewDelegate ,UICollectionViewDataSource, WKNavigationDelegate, WKScriptMessageHandler, UITextFieldDelegate {

    @IBOutlet weak var mainMenuView: UIView!
    @IBOutlet weak var mainTableView: UITableView!
    @IBOutlet weak var collectionView: UICollectionView!
    
    @IBOutlet weak var websiteSelectedMenuView: UIView!
    @IBOutlet weak var websiteSelectedView: UIView!
    @IBOutlet weak var selectedWebView: WKWebView!
    
    @IBOutlet weak var findView: UIView!
    @IBOutlet weak var findTextField: UITextField!
    @IBOutlet weak var resultsLabel: UILabel!
    
   
    @IBAction func findPreviousButton(_ sender: Any) {
    }
    @IBAction func findNextButton(_ sender: Any) {
    }
    @IBAction func findCancelButton(_ sender: Any) {
        findView.isHidden = true
    }
    
    
    
    let titles = ["Spec Book", "Standard Drawings", "CMS Portal"]
    let urls = ["http://www.dot.state.oh.us/Divisions/ConstructionMgt/OnlineDocs/Specifications/2016CMS/2016_CMS_04152016_for_web_letter_size_with_SS800_Included.pdf", "http://www.dot.state.oh.us/Divisions/Engineering/Roadway/DesignStandards/roadway/Pages/StandardConstructionDrawing.aspx", "http://www.odotonline.org/cmsportal/"]

    
    override func viewDidLoad() {
        super.viewDidLoad()
        // Do any additional setup after loading the view, typically from a nib.
        
        // Formatting
        
        mainTableView.isHidden = true
        
        websiteSelectedMenuView.isHidden = true
        findView.isHidden = true
        websiteSelectedView.isHidden = true
        
    }
    
    
    @IBAction func mainSearchButton(_ sender: Any) {
        mainTableView.isHidden = false
    }
    
    
    @IBAction func mainCancelButton(_ sender: Any) {
        mainTableView.isHidden = true
    }
    
    @IBAction func backButton(_ sender: Any) {
        print("backButton selected")
        websiteSelectedMenuView.isHidden = true
        websiteSelectedView.isHidden = true
    }
    
    @IBAction func findButton(_ sender: Any) {
        findView.isHidden = false
    }

    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        return titles.count
    }
    
    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = UITableViewCell(style: UITableViewCell.CellStyle.default, reuseIdentifier: "tbCell")
        cell.textLabel?.text = titles[indexPath.row]
        
        cell.backgroundColor = UIColor.black
        cell.textLabel?.textColor = UIColor.green
        
        return cell
    }
    
    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        mainCancelButton(self)
        collectionView.scrollToItem(at: indexPath, at: UICollectionView.ScrollPosition.top, animated: true)
        tableView.deselectRow(at: indexPath, animated: true)
    }
    
    func collectionView(_ collectionView: UICollectionView, numberOfItemsInSection section: Int) -> Int {
        return titles.count
    }
    
    func collectionView(_ collectionView: UICollectionView, cellForItemAt indexPath: IndexPath) -> UICollectionViewCell {
        let cell = collectionView.dequeueReusableCell(withReuseIdentifier: "cell", for: indexPath) as! collectionViewCell
        
        cell.cellLabel.text = titles[indexPath.item];
        
        let url = URL(string: urls[indexPath.item])
        
        cell.cellWebView.load(URLRequest(url:url!))
        
        return cell
        
    }
    
    func collectionView(_ collectionView: UICollectionView, didSelectItemAt indexPath: IndexPath) {
        
        print("collectionView didSelectItemAtIndex")
        
        websiteSelectedMenuView.isHidden = false
        websiteSelectedView.isHidden = false
        
        let url = URL(string: urls[indexPath.item])
        selectedWebView.load(URLRequest(url:url!))
        //add observer to get estimated progress value
        //selectedWebView.addObserver(self, forKeyPath: "estimatedProgress", options: .new, context: nil);
        
    }
    
    private func evaluateJavascript(_ javascript: String, sourceURL: String? = nil, completion: ((_ error: String?) -> Void)? = nil) {
        print("private func evaluateJavascript")
        
        var javascript = javascript
        
        // Adding a sourceURL comment makes the javascript source visible when debugging the simulator via Safari in Mac OS
        if let sourceURL = sourceURL {
            javascript = "//# sourceURL=\(sourceURL).js\n" + javascript
        }
        
        selectedWebView.evaluateJavaScript(javascript) { _, error in
            completion?(error?.localizedDescription)
        }
    }
    
    // MARK: - WKNavigationDelegate
    
    func webView(_ webView: WKWebView, didFinish navigation: WKNavigation!) {
        // This must be valid javascript!  Critically don't forget to terminate statements with either a newline or semicolon!
        print("WKWebView, didFinish")
        
        
        let javascript =
            "var outerHTML = document.documentElement.outerHTML.toString()\n" +
                "var message = {\"type\": \"outerHTML\", \"outerHTML\": outerHTML }\n" +
        "window.webkit.messageHandlers.WebViewControllerMessageHandler.postMessage(message)\n"
        
        evaluateJavascript(javascript, sourceURL: "getOuterHMTL")
    }
    
    // MARK: - WKScriptMessageHandler
    
    func userContentController(_ userContentController: WKUserContentController, didReceive message: WKScriptMessage) {
        print("func userContentController")
        
        guard let body = message.body as? [String: Any] else {
            print("could not convert message body to dictionary: \(message.body)")
            return
        }
        
        guard let type = body["type"] as? String else {
            print("could not convert body[\"type\"] to string: \(body)")
            return
        }
        
        switch type {
        case "outerHTML":
            guard let outerHTML = body["outerHTML"] as? String else {
                print("could not convert body[\"outerHTML\"] to string: \(body)")
                return
            }
            print("outerHTML is \(outerHTML)")
        default:
            print("unknown message type \(type)")
            return
        }
    }

    
//    override func observeValue(forKeyPath keyPath: String?, of object: Any?, change: [NSKeyValueChangeKey : Any]?, context: UnsafeMutableRawPointer?) {
//        if keyPath == "estimatedProgress" {
//            print(selectedWebView.estimatedProgress);
//            if selectedWebView.estimatedProgress == 1 {
//                print("webView didLoad");
//
//                if let path = Bundle.main.path(forResource: "UIWebViewSearch", ofType: "js"),
//                    let jsString = try? String(contentsOfFile: path, encoding: .utf8) {
//                    print(jsString)
//
//                    //selectedWebView.evaluateJavaScript(<#T##javaScriptString: String##String#>, completionHandler: <#T##((Any?, Error?) -> Void)?##((Any?, Error?) -> Void)?##(Any?, Error?) -> Void#>)
//
//                    selectedWebView.evaluateJavaScript("document.innerText") { (result, error) in
//                        if error != nil {
//                            print("check 1 =", result as Any)
//                        }
//
//                    }
//
//                    selectedWebView.evaluateJavaScript(jsString) { (result, error) in
//                            if error != nil {
//                                print("check 2 =", result!)
//                            }
//                    }
//
//                } // end if
//            }
//        }
//    }
    
}

