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
        let usd = CurrencyExchangeInfo(currency: Currency.USD) {
            info in
            let nonCashBuyRate = info.nonCashBuyRate?.format() ?? "No Data"
            let nonCashSellRate = info.nonCashSellRate?.format() ?? "No Data"
            let cbRate = info.cbRate?.format() ?? "No Data"
            let coef = ((info.cbRate ?? 0.0) / 36.93).format() ?? "No Data"
            
            self.mainLabel?.text = "$ \(nonCashBuyRate) / \(nonCashSellRate)   cb: \(cbRate) (\(coef))"
            
            return
        }
        
        currencyDataFetcher.updateRates(currencyExchangeInfos: [usd]) {
            _ in
            if handler != nil {
                handler!(NCUpdateResult.NewData)
            }
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

