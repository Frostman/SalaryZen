//
//  TodayViewController.swift
//  SalaryZenToday
//
//  Created by Sergey Lukjanov on 11/01/15.
//  Copyright (c) 2015 Sergey Lukjanov. All rights reserved.
//

import UIKit
import NotificationCenter
import SalaryZenKit

class TodayViewController: UIViewController, NCWidgetProviding {
    
    @IBOutlet weak var mainLabel: UILabel!
    
    func update(handler: ((NCUpdateResult) -> Void)? = nil) {
        SalaryZenKit.fetchRatesInfo {
            info in
            if self.mainLabel?.text != info {
                self.mainLabel?.text = info
                if let handler = handler {
                    handler(NCUpdateResult.NewData)
                }
            }
            return
        }
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        update()
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
    func widgetPerformUpdateWithCompletionHandler(completionHandler: ((NCUpdateResult) -> Void)!) {
        // Perform any setup necessary in order to update the view.
        
        // If an error is encountered, use NCUpdateResult.Failed
        // If there's no update required, use NCUpdateResult.NoData
        // If there's an update, use NCUpdateResult.NewData

        update(completionHandler)
    }
    
}

