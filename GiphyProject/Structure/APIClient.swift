//
//  APIClient.swift
//  GiphyProject
//
//  Created by Dmitry Preobrazhenskiy on 28/06/16.
//  Copyright © 2016 Example. All rights reserved.
//

import Foundation
import Alamofire
import SwiftyJSON
import XCGLogger
import CFNetwork

let APIKey = "dc6zaTOxFJmzC"
let BaseURL = "https://api.giphy.com"
let APIVersion = "/v1"
let SearchPath = "/gifs/search"
let TrendingPath = "/gifs/trending"

public class APIClient {
    public class func search(search: String, completion:([GIF]?, NSError?) -> ()) {
        let params: [String : AnyObject] = ["api_key" : APIKey, "q" : search, "limit" : 20]
        let path = BaseURL + APIVersion + SearchPath
        
        let request = Alamofire.request(.GET, path, parameters: params)
        XCGLogger.defaultInstance().info("Made a search request \(request)")
        
        handleRequest(request, retryCount: 10, completion: completion)
    }
    
    public class func trending(completion:([GIF]?, NSError?) -> ()) {
        let params: [String : AnyObject] = ["api_key" : APIKey, "limit" : 100]
        let path = BaseURL + APIVersion + TrendingPath
        
        let request = Alamofire.request(.GET, path, parameters: params)
        XCGLogger.defaultInstance().info("Made a trending request \(request)")
        
        handleRequest(request, retryCount: 10, completion: completion)
    }
    
    private class func handleRequest(request: Request,retryCount: Int, completion: ([GIF]?, NSError?) -> ()) {
        
        // Ending the retry here
        if retryCount == 0 {
            completion(nil, nil)
            return
        }
        
        request.responseJSON() {
            response in
            
            switch response.result {
            case .Success:
                if let value = response.result.value {
                    let json = JSON(value)
                    
                    
                    let meta = json["meta"].dictionaryValue
                    let code = meta["status"]?.intValue
                    
                    if code != 200 {
                        let message = meta["msg"]?.stringValue
                        //We assume that the message is always there, we could add additional check
                        let error = NSError(domain: NSURLErrorDomain, code: NSURLErrorBadServerResponse, userInfo: [NSLocalizedDescriptionKey : message!])
                        completion(nil, error)
                    } else {
                        let items = json["data"].arrayValue
                        
                        var result = [GIF]()
                        
                        for attributes in items {
                            let gif = GIF.init(attributes: attributes)
                            result.append(gif)
                        }
                        
                        completion(result, nil)
                    }
                    
                } else {
                    completion(nil, nil)
                }
            case .Failure(let error):
                
                let code = Int32(error.code)
                
                switch code {
                case CFNetworkErrors.CFURLErrorNotConnectedToInternet.rawValue:
                    self.retryRequest(request, retryCount:retryCount, completion: completion)
                    break
                    
                case CFNetworkErrors.CFURLErrorBadServerResponse.rawValue:
                    self.retryRequest(request, retryCount: retryCount, completion: completion)
                    break
                    
                case CFNetworkErrors.CFURLErrorTimedOut.rawValue:
                    self.retryRequest(request, retryCount: retryCount, completion: completion)
                    break
                    
                default:
                    completion(nil, error)
                    break
                }
            }
        }
    }
    
    private class func retryRequest(request: Request, retryCount: Int, completion: ([GIF]?, NSError?) -> ()) {
        DelayedExecution(5) {
            let tries = retryCount - 1
            XCGLogger.defaultInstance().debug("Retrying the request \(request), tries left \(tries)")
            handleRequest(request, retryCount: tries, completion: completion)
        }
    }
    
    private class func DelayedExecution(afterSecons: NSTimeInterval, closure: () -> ()) {
        let delayTime = dispatch_time(DISPATCH_TIME_NOW, Int64(afterSecons * Double(NSEC_PER_SEC)))
        dispatch_after(delayTime, dispatch_get_main_queue(), closure)
    }
}
