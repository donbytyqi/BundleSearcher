//
//  ViewController.swift
//  BundleSearcher
//
//  Created by Don Bytyqi on 2/7/17.
//  Copyright © 2017 Don Bytyqi. All rights reserved.
//

import Cocoa

class ViewController: NSViewController, NSTableViewDelegate, NSTableViewDataSource, NSSearchFieldDelegate {
    
    @IBOutlet weak var tableView: NSTableView!
    @IBOutlet weak var search: NSSearchFieldCell!
    @IBOutlet weak var searchField: NSSearchField!
    
    var bundleID = [String]()
    var images = [NSImage]()
    var urls = [NSString]()
    var term = String()
    var cellImageView = NSImageView()
    
    override func viewDidLoad() {
        super.viewDidLoad()
        self.searchField.delegate = self
        tableView.target = self
        tableView.doubleAction = #selector(tableViewDoubleClick(_:))
    }
    
    func numberOfRows(in tableView: NSTableView) -> Int {
        return bundleID.count
    }
    
    @objc func tableViewDoubleClick(_ sender:AnyObject) {
        let row = tableView.clickedRow
        if tableView.clickedRow >= 0 {
            let pasteboard = NSPasteboard.general
            pasteboard.clearContents()
            pasteboard.writeObjects([bundleID[row] as NSPasteboardWriting])
        }
    }
    
    func getAppData(url:String) {
        let request = URLRequest(url: URL(string: url)!)
        URLSession.shared.dataTask(with: request) { (data, response, error) in
            if error != nil {
                print(error?.localizedDescription ?? String())
            } else {
                do {
                    let jsonData = try JSONSerialization.jsonObject(with: data!, options: []) as! [String : Any]
                    if let results = jsonData["results"] as? NSArray {
                        for i in 0..<results.count {
                            let app = results[i] as! [String : Any]
                            let bundleid = app["bundleId"] as! String
                            let imageResult = app["artworkUrl60"] as! String
                            let image = NSImage(byReferencing: URL(string: imageResult)!)
                            self.bundleID.append(bundleid)
                            self.images.append(image)
                        }
                        DispatchQueue.main.async {
                            self.tableView.reloadData()
                        }
                    }
                } catch let error as NSError{
                    print(error)
                }
            }
            }.resume()
    }
    
    func tableView(_ tableView: NSTableView, viewFor tableColumn: NSTableColumn?, row: Int) -> NSView? {
        let cell = tableView.makeView(withIdentifier: NSUserInterfaceItemIdentifier(rawValue: "cell"), owner: self) as! NSTableCellView
        cellImageView = cell.viewWithTag(2) as! NSImageView
        cellImageView.image = images[row]
        cell.textField?.stringValue = bundleID[row]
        return cell
    }
    
    @IBAction func searchAction(_ sender: NSSearchField) {
        self.bundleID.removeAll()
        self.images.removeAll()
        term = sender.stringValue
        let final = term.replacingOccurrences(of: " ", with: "+")
        let link = "https://itunes.apple.com/search?term=\(final)&media=software&entity=software&limit=10"
        getAppData(url: link)
    }
}
