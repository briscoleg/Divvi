//
//  DayAxisValueFormatter.swift
//  Balance
//
//  Created by Bo on 9/23/20.
//  Copyright © 2020 Bo. All rights reserved.
//

import Foundation
import Charts

public class DayAxisValueFormatter: NSObject, IAxisValueFormatter {
    weak var chart: BarLineChartViewBase?
    let months = ["Jan", "Feb", "Mar",
                  "Apr", "May", "Jun",
                  "Jul", "Aug", "Sep",
                  "Oct", "Nov", "Dec"]
    
    init(chart: BarLineChartViewBase) {
        self.chart = chart
    }
    
    public func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        let days = Int(value)
        let year = determineYear(forDays: days)
        let month = determineMonth(forDayOfYear: days)
        
        let monthName = months[month % months.count]
        let yearName = "\(year)"
        
        if let chart = chart,
            chart.visibleXRange > 30 * 6 {
            return monthName + yearName
        } else {
            let dayOfMonth = determineDayOfMonth(forDays: days, month: month + 12 * (year - 2016))
            var appendix: String
            
            switch dayOfMonth {
            case 1, 21, 31: appendix = "st"
            case 2, 22: appendix = "nd"
            case 3, 23: appendix = "rd"
            default: appendix = "th"
            }
            
            return dayOfMonth == 0 ? "" : String(format: "%d\(appendix) \(monthName)", dayOfMonth)
        }
    }
    
    private func days(forMonth month: Int, year: Int) -> Int {
        // month is 0-based
        switch month {
        case 1:
            var is29Feb = false
            if year < 1582 {
                is29Feb = (year < 1 ? year + 1 : year) % 4 == 0
            } else if year > 1582 {
                is29Feb = year % 4 == 0 && (year % 100 != 0 || year % 400 == 0)
            }
            
            return is29Feb ? 29 : 28
            
        case 3, 5, 8, 10:
            return 30
            
        default:
            return 31
        }
    }
    
    private func determineMonth(forDayOfYear dayOfYear: Int) -> Int {
        var month = -1
        var days = 0
        
        while days < dayOfYear {
            month += 1
            if month >= 12 {
                month = 0
            }
            
            let year = determineYear(forDays: days)
            days += self.days(forMonth: month, year: year)
        }
        
        return max(month, 0)
    }
    
    private func determineDayOfMonth(forDays days: Int, month: Int) -> Int {
        var count = 0
        var daysForMonth = 0
        
        while count < month {
            let year = determineYear(forDays: days)
            daysForMonth += self.days(forMonth: count % 12, year: year)
            count += 1
        }
        
        return days - daysForMonth
    }
    
    private func determineYear(forDays days: Int) -> Int {
        switch days {
        case ...366: return 2016
        case 367...730: return 2017
        case 731...1094: return 2018
        case 1095...1458: return 2019
        default: return 2020
        }
    }
}

class ChartXAxisFormatter: NSObject {
    fileprivate var dateFormatter: DateFormatter?
    fileprivate var referenceTimeInterval: TimeInterval?

    convenience init(referenceTimeInterval: TimeInterval, dateFormatter: DateFormatter) {
        self.init()
        self.referenceTimeInterval = referenceTimeInterval
        self.dateFormatter = dateFormatter
    }
}


extension ChartXAxisFormatter: IAxisValueFormatter {

    func stringForValue(_ value: Double, axis: AxisBase?) -> String {
        guard let dateFormatter = dateFormatter,
        let referenceTimeInterval = referenceTimeInterval
        else {
            return ""
        }

        let date = Date(timeIntervalSince1970: value * 3600 * 24 + referenceTimeInterval)
        return dateFormatter.string(from: date)
    }

}

class ChartValueFormatter: NSObject, IValueFormatter {
    fileprivate var numberFormatter: NumberFormatter?

    convenience init(numberFormatter: NumberFormatter) {
        self.init()
        self.numberFormatter = numberFormatter
    }

    func stringForValue(_ value: Double, entry: ChartDataEntry, dataSetIndex: Int, viewPortHandler: ViewPortHandler?) -> String {
        guard let numberFormatter = numberFormatter
            else {
                return ""
        }
        return numberFormatter.string(for: value)!
    }
}
