//
//  FEDataModel.swift
//  FestEvents
//
//  Created by Kartum Infotech on 4/20/17.
//  Copyright © 2017 Sunil Zalavadiya. All rights reserved.
//

import Foundation
import UIKit

class UserDataList {
    
    init() {}
    
    var map: Map!
    
    var arrUserData = [UserData]()
    
    init(data: [[String: AnyObject]]) {
        
        for dictDishCategory in data {
            arrUserData.append(UserData(data: dictDishCategory))
        }
    }
    
    class UserData {
        
        init() {}
        
        var map: Map!
        
        var id = ""
        var profile_pic_url = ""
        var full_name = ""
        var email = ""
        var profile_pic = ""
        var phone = ""
        var address = ""
        var dob = ""
        var gender = ""
        var designation = ""
        var salary = ""
        var created_at = ""
        
        
        init(data: [String: AnyObject]) {
            map = Map(data: data)
            id = map.value("id") ?? ""
            profile_pic_url = map.value("profile_pic_url") ?? ""
            full_name = map.value("full_name") ?? ""
            email = map.value("email") ?? ""
            profile_pic = map.value("profile_pic") ?? ""
            phone = map.value("phone") ?? ""
            address = map.value("address") ?? ""
            dob = map.value("dob") ?? ""
            gender = map.value("gender") ?? ""
            designation = map.value("designation") ?? ""
            salary = map.value("salary") ?? ""
            created_at = map.value("created_at") ?? ""
            
        }
    }
}



class Map {
    
    init() {}
    
    var data: [String: AnyObject]?
    
    init(data: [String: AnyObject]) {
        self.data = data
    }
    
    func value<T>(_ forKey: String, transformDate: (format: String , timeZone: String)? = nil, isMilliseconds: Bool = false) -> T? {
        
        let strValue = data?[forKey] as? String ?? data?[forKey]?.stringValue ?? ""
        
        if T.self == String.self || T.self == Optional<String>.self || T.self == Optional<String>.self {
            return strValue as? T
        }
        
        if T.self == Int.self || T.self == Optional<Int>.self || T.self == Optional<Int>.self {
            if let value = data?[forKey] as? NSNumber { return value.intValue as? T }
            return (strValue as NSString).integerValue as? T
        }
        else if T.self == Date.self || T.self == Optional<Date>.self || T.self == Optional<Date>.self {
            if isNumber(str: strValue)
            {
                return convertDateFrom(timeInterval: (strValue as NSString).doubleValue, isMilliseconds: isMilliseconds) as? T
            }
            
            return getDateFromString(dateStr: strValue, formate: (transformDate?.format)!, timeZone: (transformDate?.timeZone)!) as? T
        }
        else if T.self == Double.self || T.self == Optional<Double>.self || T.self == Optional<Double>.self {
            return data?[forKey]?.doubleValue as? T
        }
        else if T.self == Float.self || T.self == Optional<Float>.self || T.self == Optional<Float>.self {
            return data?[forKey]?.floatValue as? T
        }
        else if T.self == Bool.self  || T.self == Optional<Bool>.self || T.self == Optional<Bool>.self {
            return data?[forKey]?.boolValue as? T
        }
        else if T.self == URL.self  || T.self == Optional<URL>.self || T.self == Optional<URL>.self {
            return URL(string: strValue) as? T
        }
        else if T.self == [AnyObject].self || T.self == Optional<[AnyObject]>.self || T.self == Optional<[AnyObject]>.self {
            return data?[forKey] as? T
        }
        else if T.self == [String: AnyObject].self || T.self == Optional<[String: AnyObject]>.self || T.self == Optional<[String: AnyObject]>.self {
            return data?[forKey] as? T
        }
        
        return nil
    }
    
    private func convertDateFrom(timeInterval: Double, isMilliseconds: Bool = false) -> Date {
        let seconds = isMilliseconds ? (timeInterval / 1000) : timeInterval
        return Date(timeIntervalSince1970: TimeInterval(seconds))
    }
    
    private func getDateFromString(dateStr: String, formate: String, timeZone: String) -> Date? {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: timeZone)
        dateFormatter.dateFormat = formate
        
        return dateFormatter.date(from: dateStr)
    }
    
    private func getStringFromDate(date: Date,formate: String, timeZone: String) -> String {
        let dateFormatter = DateFormatter()
        dateFormatter.timeZone = TimeZone(abbreviation: timeZone)
        dateFormatter.dateFormat = formate
        
        return dateFormatter.string(from: date)
    }
    
    private func isNumber(str: String) -> Bool {
        let numberCharacters = NSCharacterSet.decimalDigits.inverted
        return !str.isEmpty && str.rangeOfCharacter(from: numberCharacters) == nil
    }
}










