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


public enum Bank: String {
    case Alfa = "Alfa"
    case Cbr = "CBR"

    public static let all = [Alfa, Cbr]

    public var title: String {
        get { return self.rawValue }
    }

    public var name: String {
        get { return self.rawValue.lowercaseString }
    }
}


public enum Currency: String {
    case USD = "USD"
    case EUR = "EUR"
    case CHF = "CHF"
    case GBP = "GBP"
    
    public static let all = [USD, EUR, CHF, GBP]
    
    public var title: String {
        get { return self.rawValue }
    }

    public var name: String {
        get { return self.rawValue.lowercaseString }
    }
}

public enum DataType: String {
    case Current = "Current"
    case Historic = "Hitoric"

    public static let all = [Current, Historic]

    public var title: String {
        get { return self.rawValue }
    }

    public var name: String {
        get { return self.rawValue.lowercaseString }
    }
}

public enum ExchangeType: String {
    case Sell = "Sell"
    case Buy = "Buy"
    case Rate = "Rate"

    public static let all = [Sell, Buy, Rate]

    public var title: String {
        get { return self.rawValue }
    }

    public var name: String {
        get { return self.rawValue.lowercaseString }
    }
}

public typealias CurrencyExchangeRate = Double

public extension CurrencyExchangeRate {
    func format() -> String {
        return NSString(format: "%.2f", self)
    }
}

public class CurrencyRates {
    private let rates = [String: Double]()
    private let historic = [String: [NSDate: Double]]()

    public var aggregatedAtTimestamp: NSTimeInterval {
        get { return self.rates["aggregated_at"]! }
    }

    public init(json: JSON) {
        for (key: String, subJson: JSON) in json.dictionaryValue {
            if let rate = subJson.double {
                self.rates[key] = rate
            } else if let historic = subJson.dictionary {
                if key.rangeOfString("historic") == nil {
                    // error
                }
                if self.historic[key] == nil {
                    self.historic[key] = [NSDate: Double]()
                }
                for (date: String, rateJson: JSON) in subJson {
                    if let rate = rateJson.double {
                        // TBD Replace NSDate() with date parsing
                        self.historic[key]![NSDate()] = rate
                    } else {
                        // error
                    }
                }
            } else {
                // error!
            }
        }
    }

    public func getRate(bank: Bank, currency: Currency = Currency.USD,
        dataType: DataType = DataType.Current, exchangeType: ExchangeType = ExchangeType.Rate)
        -> CurrencyExchangeRate? {
            let key = "\(bank.name)_\(currency.name)_\(dataType.name)_\(exchangeType.name)"
            return self.rates[key]
    }

    public func getCurrentCbrUsdRate() -> CurrencyExchangeRate? {
        return self.getRate(Bank.Cbr, currency: Currency.USD, dataType: DataType.Current,
            exchangeType: ExchangeType.Rate)
    }

    public func getCurrentAlfaUsdRate(exchangeType: ExchangeType) -> CurrencyExchangeRate? {
        return self.getRate(Bank.Alfa, currency: Currency.USD, dataType: DataType.Current,
            exchangeType: exchangeType)
    }

    public func getCurrentAlfaUsdRates() -> (sell: CurrencyExchangeRate?,
        buy: CurrencyExchangeRate?) {
            return (self.getCurrentAlfaUsdRate(ExchangeType.Sell),
                self.getCurrentAlfaUsdRate(ExchangeType.Buy))
    }
}


public class CurrencyRatesFetcher {
    private let cache = NSCache()
    private var cacheFor: NSTimeInterval = 10 * 60 // 10 minutes

    public init() {
        self.cache.name = "CurrencyRatesFetcherCache"
    }

    public func setConf(cacheFor: NSTimeInterval? = nil) {
        if let cacheFor = cacheFor {
            self.cacheFor = cacheFor
        }
    }

    public func fetch(handler: (CurrencyRates) -> Void) {
        let (cachedRates, outdated) = self.fetchFromCache()
        if let cachedRates = cachedRates {
            handler(cachedRates)
        }
        if outdated {
            fetchFromServer {
                (rates, error) in
                // if error retry?
                if let rates = rates {
                    handler(rates)
                }
            }
        }
    }

    private func fetchFromCache() -> (rates: CurrencyRates?, outdated: Bool) {
        if let data = self.cache.objectForKey("data") as? CurrencyRates {
            let now = NSDate().timeIntervalSince1970
            let outdated = now - data.aggregatedAtTimestamp > self.cacheFor
            return (data, outdated)
        }
        return (nil, true)
    }

    private func fetchFromServer(handler: (rates: CurrencyRates?, error: Bool) -> Void) {
        let url = "http://f.slukjanov.name/salaryzen/datav2.json"

        Alamofire.request(.GET, url).responseSwiftyJSON {
            (request, response, json, error) in
            if json != nil && error == nil {
                let rates = CurrencyRates(json: json)
                self.cache.setObject(rates, forKey: "data")
                handler(rates: rates, error: false)
            } else {
                handler(rates: nil, error: true)
            }
        }
    }
}

public let fetcher = CurrencyRatesFetcher()

public func fetchRatesInfo(handler: (info: String) -> Void) {
    fetcher.fetch {
        rates in
        let cbrRate = rates.getCurrentCbrUsdRate() ?? 0.0
        let (alfaSellOpt, alfaBuyOpt) = rates.getCurrentAlfaUsdRates()
        let alfaSell = alfaSellOpt ?? 0.0
        let alfaBuy = alfaBuyOpt ?? 0.0
        let coef = cbrRate / 36.93
        handler(info: "$ \(alfaBuy.format()) / \(alfaSell.format())   "
            + "cb: \(cbrRate.format()) (\(coef.format()))")
    }
}