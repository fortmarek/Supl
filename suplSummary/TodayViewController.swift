//
//  TodayViewController.swift
//  suplSummary
//
//  Created by Marek Fořt on 28/11/2016.
//  Copyright © 2016 Marek Fořt. All rights reserved.
//

import UIKit
import NotificationCenter

class TodayViewController: SuplTable, NCWidgetProviding {
    
        
    override func viewDidLoad() {
        super.viewDidLoad()
        
        
        tableView.allowsSelection = false
        tableView.isScrollEnabled = false
        
        self.refreshControl = refreshController
        
        dataController.delegate = self
        
        messageLabel.isHidden = true
        messageLabel.frame = CGRect(x: 0, y: 0, width: view.frame.size.width - 10, height: 110)
        messageLabel.font = UIFont().getFont(20, weight: .light)
        messageLabel.textAlignment = .center
        self.tableView.addSubview(messageLabel)
        
        let openAppGesture = UITapGestureRecognizer(target: self, action:  #selector(openMain))
        tableView.addGestureRecognizer(openAppGesture)
        
        
        //let decoded  = UserDefaults.standard.object(forKey: "suplArray") as! Data
        //guard let absolutePath = getFileURL()?.appendingPathComponent("suplArray.txt").absoluteString else {return}
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
        let path = documentsDirectory.appendingPathComponent("suplArray").path
        
        //guard let decoded = NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [[suplStruct]] else {print("FUCK");return}
        print(NSKeyedUnarchiver.unarchiveObject(withFile: path))
        print(NSKeyedUnarchiver.unarchiveObject(withFile: path) as? [[suplStruct]])
        
        
        reloadData()
        
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func openMain() {
        guard let openUrl = NSURL(string: "Supl://") else {return}
        extensionContext?.open(openUrl as URL, completionHandler: nil)
    }
    
    
    @available(iOSApplicationExtension 10.0, *)
    func widgetActiveDisplayModeDidChange(_ activeDisplayMode: NCWidgetDisplayMode, withMaximumSize maxSize: CGSize) {
        
        if (activeDisplayMode == NCWidgetDisplayMode.expanded) {
    
            guard (suplArray.count > 0) else {return}
            let height = CGFloat(suplArray[0].count * 55)
            self.preferredContentSize = CGSize(width: 0, height: height);
            self.reloadInputViews()
        }
        else {
            preferredContentSize = maxSize
        }

    }
    
    override func emptyArray() {
        tableView.separatorStyle = .none
        messageLabel.isHidden = false
        
        messageLabel.text = "Žádné změny"
        
        if #available(iOSApplicationExtension 10.0, *) {
            guard let extensionContext = self.extensionContext else {return}
            if extensionContext.widgetLargestAvailableDisplayMode == NCWidgetDisplayMode.expanded {
                extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.compact
            }
        }
        
    }
    
    func widgetPerformUpdate(completionHandler: (@escaping (NCUpdateResult) -> Void)) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData
        
        dataController.getData(completion: {
            let data = NSKeyedArchiver.archivedData(withRootObject: self.suplArray)
            //guard let url = self.getFileURL() else {return}
            
            
            guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return}
            let path = documentsDirectory.appendingPathComponent("suplArray").path
            
            print(FileManager.default.createFile(atPath: path, contents: data, attributes: [:]))
            
            print(NSKeyedArchiver.archiveRootObject(self.suplArray, toFile: path))
            do {
                //try data.write(to: path)
                //let stringSuplArray = String(bytes: data, encoding: String.Encoding.utf8)
                //try stringSuplArray?.write(to: path, atomically: true, encoding: String.Encoding.utf8)
            }
            catch {}
            
            /*
            
            if FileManager.default.fileExists(atPath: url.appendingPathComponent("suplArray.data").absoluteString) {
                print("File exists")
            } else {
                FileManager.default.createFile(atPath: url.appendingPathComponent("suplArray.data").absoluteString, contents: data, attributes: [:])
                print("File not found")
            }
            
            
            do {
                try data.write(to: url.appendingPathComponent("suplArray.data"), options: .atomic)
                print("saved")
            }
            catch {
                print("couldn't write data")
            }
            
            UserDefaults.standard.set(data, forKey: "suplArray")
            UserDefaults.standard.set(self.datesArray, forKey: "datesArray")
            
            */
            completionHandler(NCUpdateResult.newData)
        })
        
    }
    
    private func getFileURL() -> URL? {
        guard let documentsDirectory = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first else {return nil}
        
        let path = documentsDirectory.appendingPathComponent("file.txt")
        
        do {
            try "KKKK".write(to: path, atomically: true, encoding: String.Encoding.utf8)
        }
        catch {}
        
        do {
            let text = try String(contentsOf: path, encoding: String.Encoding.utf8)
            print(text)
        }
        catch {}
        
        return documentsDirectory
    }
    
    override func numberOfSections(in tableView: UITableView) -> Int {
        
        guard let firstDate = datesArray.ref(0) else {return 0}
        
        if firstDate == "Zítra" {
            self.reloadInputViews()
            messageLabel.isHidden = true

            return 1
        }
        else {
            emptyArray()
            return 0
        }
        
    }
    
    
    override func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard let suplArraySection = suplArray.ref(section)
            else {return 0}
        
        if suplArraySection.count > 2 {
            if #available(iOSApplicationExtension 10.0, *) {
                guard let extensionContext = self.extensionContext else {return 0}
                //Expanded mode not available, return only 2 cells, stay in compact mode
                
                if extensionContext.widgetLargestAvailableDisplayMode == NCWidgetDisplayMode.compact {
                    extensionContext.widgetLargestAvailableDisplayMode = NCWidgetDisplayMode.expanded
                }
            }
        }
        return suplArraySection.count
    }
    
}
