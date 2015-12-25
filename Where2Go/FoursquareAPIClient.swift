//
//  FoursquareAPIClient.swift
//  Where2Go
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
    
    static let sharedInstance = FoursquareAPIClient()
    
    func taskForGETMethod(method: String, parameters: NSDictionary?, baseUrl: String?, dataOffSet: Int?, headers: NSDictionary?, completionHandler: (result: AnyObject!, error: NSError?) -> Void) -> NSURLSessionDataTask? {
        
        // Set defaults for request configuration
        var parameterString = ""
        var offSet = 0
        var base = Constants.BaseURLSecure
        
        // Overide default configuration if parameters set in method call
        if let parameters = parameters { parameterString = FoursquareAPIClient.escapedParameters(parameters) }
        if let dataOffSet = dataOffSet { offSet = dataOffSet }
        if let baseUrl = baseUrl {base = baseUrl }
        
        // Setup the request
        let urlString = base + "/\(method)" + parameterString        
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
    
    func taskForImage(filePath: String, completionHandler: (imageData: NSData?, error: String?) ->  Void) -> NSURLSessionTask {
        
        let url = NSURL(string: filePath)!
        
        let request = NSURLRequest(URL: url)
        
        let task = session.dataTaskWithRequest(request) {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(imageData: nil, error: error.description)
            } else {
                completionHandler(imageData: data, error: nil)
            }
        }
        
        task.resume()
        
        return task
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(parameters: NSDictionary) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.stringByAddingPercentEncodingWithAllowedCharacters(NSCharacterSet.URLQueryAllowedCharacterSet())
            
            /* Append it */
            urlVars += ["\(key)" + "=" + "\(escapedValue!)"]
            
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
            let info = ["Description" : "Something went wrong while parsing the JSON"]
            completionHandler(result: nil, error: NSError(domain: "ParsingError", code: 0, userInfo: info))
        }
        
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(data: NSData?, response: NSURLResponse?, error: NSError) -> NSError {
        
        var theError = error
        
        do {
            let parsedResult = try NSJSONSerialization.JSONObjectWithData(data!, options: NSJSONReadingOptions.AllowFragments) as? [String : AnyObject]
            
            if let meta = parsedResult![FoursquareAPIClient.JSONResponseKeys.StatusMessage] as? [String:AnyObject] {
                if let errorType = meta["errorType"] {
                    let errorDetail = meta["errorDetail"]
                    let errorMessage = "\(errorType) : \(errorDetail)"
                    let userInfo = [NSLocalizedDescriptionKey : errorMessage]
                    theError =  NSError(domain: "Foursquare API Error", code: 1, userInfo: userInfo)
                }
            }
            
        } catch {
            print("An error occured in errorForData: \(error)")
        }
        
        return theError
        
    }
    
    // MARK: - Shared Image Cache
    struct Caches {
        static let imageCache = ImageCache()
    }

    
}