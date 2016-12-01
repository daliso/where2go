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
    var session: URLSession
    
    override init() {
        session = URLSession.shared
        super.init()
    }
    
    static let sharedInstance = FoursquareAPIClient()
    
    func taskForGETMethod(_ method: String, parameters: NSDictionary?, baseUrl: String?, dataOffSet: Int?, headers: NSDictionary?, completionHandler: @escaping (_ result: AnyObject?, _ error: NSError?) -> Void) -> URLSessionDataTask? {
        
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
        let url = URL(string: urlString)!
        let request = NSMutableURLRequest(url: url)
        
        if let headers = headers {
            for (key, value) in headers {
                request.addValue("\(value)", forHTTPHeaderField: "\(key)")
            }
        }
        
        // Setup the data task
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            let newData = data!.subdata(with: NSMakeRange(offSet, data!.count - offSet)) /* subset response data! */
            
            if let error = downloadError {
                let newError = FoursquareAPIClient.errorForData(newData, response: response, error: error)
                completionHandler(result: nil, error: newError)
            } else {
                FoursquareAPIClient.parseJSONWithCompletionHandler(newData, completionHandler: completionHandler)
            }
        }) 
        
        // start the task
        task.resume()
        
        return task
    }
    
    func taskForImage(_ filePath: String, completionHandler: @escaping (_ imageData: Data?, _ error: String?) ->  Void) -> URLSessionTask {
        
        let url = URL(string: filePath)!
        
        let request = URLRequest(url: url)
        
        let task = session.dataTask(with: request, completionHandler: {data, response, downloadError in
            
            if let error = downloadError {
                completionHandler(nil, error.description)
            } else {
                completionHandler(data, nil)
            }
        }) 
        
        task.resume()
        
        return task
    }
    
    /* Helper function: Given a dictionary of parameters, convert to a string for a url */
    class func escapedParameters(_ parameters: NSDictionary) -> String {
        
        var urlVars = [String]()
        
        for (key, value) in parameters {
            
            /* Make sure that it is a string value */
            let stringValue = "\(value)"
            
            /* Escape it */
            let escapedValue = stringValue.addingPercentEncoding(withAllowedCharacters: CharacterSet.urlQueryAllowed)
            
            /* Append it */
            urlVars += ["\(key)" + "=" + "\(escapedValue!)"]
            
        }
        
        return (!urlVars.isEmpty ? "?" : "") + urlVars.joined(separator: "&")
    }
    
    /* Helper: Given raw JSON, return a usable Foundation object */
    class func parseJSONWithCompletionHandler(_ data: Data, completionHandler: (_ result: AnyObject?, _ error: NSError?) -> Void) {
        
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data, options: JSONSerialization.ReadingOptions.allowFragments)
            completionHandler(parsedResult as AnyObject?, nil)
        }
        catch  {
            let info = ["Description" : "Something went wrong while parsing the JSON"]
            completionHandler(nil, NSError(domain: "ParsingError", code: 0, userInfo: info))
        }
        
    }
    
    /* Helper: Given a response with error, see if a status_message is returned, otherwise return the previous error */
    class func errorForData(_ data: Data?, response: URLResponse?, error: NSError) -> NSError {
        
        var theError = error
        
        do {
            let parsedResult = try JSONSerialization.jsonObject(with: data!, options: JSONSerialization.ReadingOptions.allowFragments) as? [String : AnyObject]
            
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
    
}
