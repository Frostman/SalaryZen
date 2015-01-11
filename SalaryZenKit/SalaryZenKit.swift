//
//  SalaryZenKit.swift
//  SalaryZen
//
//  Created by Sergey Lukjanov on 11/01/15.
//  Copyright (c) 2015 Sergey Lukjanov. All rights reserved.
//

import Foundation

import Alamofire
import SwiftyJSON
import AlamofireSwiftyJSON


public enum Currency: String {
    case USD = "USD"
    case EUR = "EUR"
    case CHF = "CHF"
    case GBP = "GBP"
    
    public static let all = [USD, EUR, CHF, GBP]
    
    public var title: String {
        get { return self.rawValue }
    }
}

public typealias CurrencyExchangeRate = Double

public extension CurrencyExchangeRate {
    func format() -> String {
        return NSString(format: "%.2f", self)
    }
}

public class CurrencyExchangeInfo {
    private let updateHandler: (CurrencyExchangeInfo) -> Void
    
    public let currency: Currency
    public var nonCashBuyRate: CurrencyExchangeRate? {
        didSet { if oldValue != self.nonCashBuyRate { self.updateHandler(self) } }
    }
    public var nonCashSellRate: CurrencyExchangeRate? {
        didSet { if oldValue != self.nonCashSellRate { self.updateHandler(self) } }
    }
    public var cbRate: CurrencyExchangeRate? {
        didSet { if oldValue != self.cbRate { self.updateHandler(self) } }
    }
    
    public init(currency: Currency, updateHandler: ((info: CurrencyExchangeInfo) -> Void)? = {_ in /* NOOP */}) {
        self.currency = currency
        self.updateHandler = updateHandler!
    }
}

public class SalaryZenAggregatorDataFetcher {
    public func updateRates(currencyExchangeInfos infos: [CurrencyExchangeInfo],
        handler: (error: Bool) -> Void = {_ in /* NOOP */}) {
            let url = "http://f.slukjanov.name/salaryzen/data.json"
            
            Alamofire.request(.GET, url).responseSwiftyJSON {
                (request, response, json, error) in
                if(error != nil) {
                    handler(error: true)
                } else {
                    for info in infos {
                        var rates = json["alfa-bank"][info.currency.title]["non-cash"]
                        info.nonCashBuyRate = rates["buyRate"].double
                        info.nonCashSellRate = rates["sellRate"].double
                        
                        rates = json["cb"][info.currency.title]["official"]
                        info.cbRate = rates["rate"].double
                    }
                    
                    handler(error: false)
                }
            }
    }
}

public let currencyDataFetcher = SalaryZenAggregatorDataFetcher()