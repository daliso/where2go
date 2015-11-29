//
//  UdacityAPIClient.swift
//  On The Map Udacity
//
//  Created by Daliso Zuze on 17/08/2015.
//  Copyright (c) 2015 Daliso Zuze. All rights reserved.
//

import Foundation

class FoursquareAPIClient : NSObject {
    
    /* Shared session */
    var session: NSURLSession
    
    override init() {
        session = NSURLSession.sharedSession()
        super.init()
    }
    
    func taskForGETMethod(method: String, parameters: [String : AnyObject]?, baseUrl: String?, dataOffSet: Int?, headers: NSDictionary?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Set defaults for request configuration
        var parameterString = ""
        var offSet = 0
        var base = Constants.BaseURLSecure
        
        // Overide default configuration if parameters set in method call
        if let parameters = parameters { parameterString = FoursquareAPIClient.escapedParameters(parameters) }
        if let dataOffSet = dataOffSet { offSet = dataOffSet }
        if let baseUrl = baseUrl {base = baseUrl }
        
        // Setup the request
        let urlString = base + method + parameterString
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue("\(value)", forHTTPHeaderField: "\(key)")
            }
        }
        
        // Setup the data task
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            let newData = data!.subdataWithRange(NSMakeRange(offSet, data!.length - offSet)) /* subset response data! */
            
            if let error = downloadError {
                let newError = FoursquareAPIClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                FoursquareAPIClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        // start the task
        task.resume()
        
        return task
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: [String : AnyObject]) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += [key + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joinWithSeparator("&")
    }
    
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(data: NSData, completionHandler: (result: AnyObject!, error: NSError?) -> Void) {
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data, options: NSJSONReadingOptions.AllowFragments)
            completionHandler(result: parsedResult, error: nil)
        }
        catch  {
            completionHandler(result: nil, error: NSError(domain: "a", code: 0, userInfo: nil)) // come back and fix this
        }
        
    }
    
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        var theError = NSError(domain: "a", code: 0, userInfo: nil)
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject]
            
            if let errorMessage = parsedResult![FoursquareAPIClient.JSONResponseKeys.StatusMessage] as? String {
                
                let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                
                theError =  NSError(domain: "Udacity API Error", code: 1, userInfo: userInfo)
            }
            
        } catch {
            
            
        }
        
        return theError
        
    }
    
    /*

    // MARK: - GET
    func taskForGETMethod(method: String, parameters: [String : AnyObject]?, baseUrl: String?, dataOffSet: Int?, headers: NSDictionary?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Set defaults for request configuration
        var parameterString = ""
        var offSet = 0
        _ = NSDictionary()
        var base = Constants.BaseURLSecure
        
        // Overide default configuration if parameters set in method call
        if let parameters = parameters { parameterString = UdacityAPIClient.escapedParameters(parameters) }
        if let dataOffSet = dataOffSet { offSet = dataOffSet }
        if let baseUrl = baseUrl {base = baseUrl }
        
        // Setup the request
        let urlString = base + method + parameterString
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue("\(value)", forHTTPHeaderField: "\(key)")
            }
        }
        
        // Setup the data task
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            let newData = data!.subdataWithRange(NSMakeRange(offSet, data!.length - offSet)) /* subset response data! */
            
            if let error = downloadError {
                _ = UdacityAPIClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                UdacityAPIClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        // start the task
        task.resume()
        
        return task
    }
    
    
    
    // MARK: - POST
    func taskForPOSTMethod(method: String, parameters: [String : AnyObject]?, baseUrl: String?, dataOffSet: Int?, headers: NSDictionary?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Set defaults for request configuration
        var parameterString = ""
        var offSet = 0
        _ = NSDictionary()
        var base = Constants.BaseURLSecure
        
        // Overide default configuration if parameters set in method call
        if let parameters = parameters { parameterString = UdacityAPIClient.escapedParameters(parameters) }
        if let dataOffSet = dataOffSet { offSet = dataOffSet }
        if let baseUrl = baseUrl {base = baseUrl }
        
        let urlString = base + method + parameterString
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "POST"
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue("\(value)", forHTTPHeaderField: "\(key)")
            }
        }
        
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions(rawValue: 0))
        }
        catch{
            
        }
        
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            let newData = data!.subdataWithRange(NSMakeRange(offSet, data!.length - offSet))
            
            if let error = downloadError {
                _ = UdacityAPIClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                UdacityAPIClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
    // MARK: - Delete
    func taskForDELETEMethod(method: String, parameters: [String : AnyObject]?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        var parameterString = ""
        
        if let parameters = parameters {
            parameterString = UdacityAPIClient.escapedParameters(parameters)
        }
        
        let urlString = Constants.BaseURLSecure + method + parameterString
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "DELETE"
        request.addValue("application/json", forHTTPHeaderField: "Accept")

        var xsrfCookie: NSHTTPCookie? = nil
        let sharedCookieStorage = NSHTTPCookieStorage.sharedHTTPCookieStorage()
        for cookie in sharedCookieStorage.cookies! {
            if cookie.name == "XSRF-TOKEN" { xsrfCookie = cookie }
        }
        if let xsrfCookie = xsrfCookie {
            request.setValue(xsrfCookie.value, forHTTPHeaderField: "X-XSRF-TOKEN")
        }

        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            let newData = data!.subdataWithRange(NSMakeRange(5, data!.length - 5)) /* subset response data! */
            
            if let error = downloadError {
                _ = UdacityAPIClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                UdacityAPIClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        task.resume()
        
        return task
    }
    
    
    // MARK: - PUT
    func taskForPUTMethod(method: String, parameters: [String : AnyObject]?, baseUrl: String?, dataOffSet: Int?, headers: NSDictionary?, jsonBody: [String:AnyObject], completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask {
        
        // Set defaults for request configuration
        var parameterString = ""
        var offSet = 0
        var base = Constants.BaseURLSecure
        
        // Overide default configuration if parameters set in method call
        if let parameters = parameters { parameterString = UdacityAPIClient.escapedParameters(parameters) }
        if let dataOffSet = dataOffSet { offSet = dataOffSet }
        if let baseUrl = baseUrl {base = baseUrl }
        
        // Setup the request
        let urlString = base + method + parameterString
        let url = NSURL(string: urlString)!
        let request = NSMutableURLRequest(URL: url)
        request.HTTPMethod = "PUT"
        if let headers = headers {
            for (key, value) in headers {
                request.addValue("\(value)", forHTTPHeaderField: "\(key)")
            }
        }
        
        do {
            try request.HTTPBody = NSJSONSerialization.dataWithJSONObject(jsonBody, options: NSJSONWritingOptions(rawValue: 0))
        }
        catch {}
        
        // Setup the data task
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            let newData = data!.subdataWithRange(NSMakeRange(offSet, data!.length - offSet)) /* subset response data! */
            
            if let error = downloadError {
                _ = UdacityAPIClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: downloadError)
            } else {
                UdacityAPIClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }
        
        // start the task
        task.resume()
        
        return task
    }
    
    // MARK: - Helpers
    
    /* Helper: Substitute the key for the value that is contained within the method name */
    class func subtituteKeyInMethod(method: String, key: String, value: String) -> String? {
        if method.rangeOfString("{\(key)}") != nil {
            return method.stringByReplacingOccurrencesOfString("{\(key)}", withString: value)
        } else {
            return nil
        }
    }

    // MARK: - Shared Instance
    
    class func sharedInstance() -> UdacityAPIClient {
        
        struct Singleton {
            static var sharedInstance = UdacityAPIClient()
        }
        
        return Singleton.sharedInstance
    }

    */
    
}