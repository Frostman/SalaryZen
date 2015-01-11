//
//  ViewController.swift
//  SalaryZen
//
//  Created by Sergey Lukjanov on 11/01/15.
//  Copyright (c) 2015 Sergey Lukjanov. All rights reserved.
//

import UIKit

import SalaryZenKit

class ViewController: UIViewController {
    
    @IBOutlet weak var infoLabel: UILabel!
    
    override func viewDidLoad() {
        super.viewDidLoad()
        
        let usd = CurrencyExchangeInfo(currency: Currency.USD) {
            info in
            let nonCashBuyRate = info.nonCashBuyRate?.format() ?? "No Data"
            let nonCashSellRate = info.nonCashSellRate?.format() ?? "No Data"
            let cbRate = info.cbRate?.format() ?? "No Data"
            let coef = ((info.cbRate ?? 0.0) / 36.93).format()

            self.infoLabel?.text = "$ \(nonCashBuyRate) / \(nonCashSellRate)   cb: \(cbRate) (\(coef))"
            return
        }
        
        currencyDataFetcher.updateRates(currencyExchangeInfos: [usd]) {
            _ in
        }
    }
    
    override func didReceiveMemoryWarning() {
        super.didReceiveMemoryWarning()
        // Dispose of any resources that can be recreated.
    }
    
}