//
//  HTTPRequest.swift
//  duress
//
//  Created by Cirrena on 7/1/15.
//  Copyright (c) 2015 Cirrena Pty Ltd. All rights reserved.
//

import UIKit

typealias successCompletionBlock = (result : CirrenaModelData)->Void
typealias failedCompletionBlock = (result : AnyObject?) -> Void

enum HTTPBodyType{
    case JSON(body : [NSObject : AnyObject])
    case HTTP(body : [NSObject : AnyObject])
}

protocol URLProtocol {
    typealias AbstractType
    func getURLPath()->AbstractType
}

struct URLModule<T> : URLProtocol {
    private let _url : () -> T
    
    init<P : URLProtocol where P.AbstractType == T>(_ dep : P){
        _url = dep.getURLPath
    }
    
    func getURLPath() -> T {
        return _url()
    }
}


class HTTPRequest : NSObject , NSURLSessionDelegate{
    var mySession : NSURLSession!
    
    private static let timeOutInterval : NSTimeInterval = 30.0
    private static let allowCellularAccess = true
    
    
    private init(session : NSURLSession!){
        mySession = session
    }
    convenience override init(){
        let theSession = NSURLSession(configuration: NSURLSessionConfiguration.defaultSessionConfiguration())
        self.init(session : theSession)
    }
    
    private func makeRequest(urlRequest urlRequest : NSMutableURLRequest!,
        successCompletionHandler : successCompletionBlock,
        failedCompletionHandler : failedCompletionBlock,
        returnData : CirrenaModelData.Type!,
        returnParameters : [String : AnyObject]?){

        let myTask : NSURLSessionDataTask =  mySession.dataTaskWithRequest(urlRequest, completionHandler: {(myData : NSData?, myResponse :  NSURLResponse?, myError : NSError?) -> Void in
            if let returnedData = myData{
                dispatch_async(dispatch_get_main_queue(), {
                    //let newStr = NSString(data: returnedData, encoding: NSUTF8StringEncoding)
                    do {
                        let jsonObject : AnyObject?  = try NSJSONSerialization.JSONObjectWithData(returnedData, options: NSJSONReadingOptions.MutableContainers)
                        
                        if let jsonDictionary  = jsonObject as? [String : AnyObject] {
                            let instance = returnData.init(dictionary: jsonDictionary)
                            if let parameters = returnParameters{
                                instance.returnParams = parameters
                            }
                            
                            successCompletionHandler(result: instance)
                        }else{
                            //JSON is empty
                            
                        }
                    } catch let parseError as NSError {
                        //error
                        //Flurry.logError("HTTPRequestError", message: "failedCompletionHandler", error: parseError)
                        failedCompletionHandler(result : nil)
                        
                    } catch {
                        fatalError()
                    }
                })
            }
            
        })
        myTask.resume()
    }
    deinit{
        print("\(self) deinit")
        print("\(self.mySession) deinit")
        
        self.mySession.finishTasksAndInvalidate()
        
    }
    
    
    // MARK:
    // MARK: Create Service
    // MARK:
    class func send(httpMethod : String="POST")
        (returnParameters :  [String : AnyObject]?,
        urlRequest : NSMutableURLRequest!,
        returnData : CirrenaModelData.Type!,successCompletionHandler :
        successCompletionBlock , failedCompletionHandler : failedCompletionBlock){
            
        let myService : HTTPRequest  =  HTTPRequest()
        urlRequest.HTTPMethod = httpMethod
            
        myService.makeRequest(urlRequest: urlRequest,
            successCompletionHandler: successCompletionHandler,
            failedCompletionHandler: failedCompletionHandler,
            returnData: returnData,
            returnParameters: returnParameters)
    }
    
    
    static var Post = HTTPRequest.send()
    static var Get = HTTPRequest.send("GET")
    
    // MARK:
    // MARK: Create Request
    // MARK:
    


    
    class func configRequestWithURL<T : URLProtocol>(type : T, httpHeaders : NSDictionary? ,
        httpBody : HTTPBodyType)->NSMutableURLRequest{
            
        type.getURLPath()
            
        let myURL = NSURL(string: "s")!
            
        let urlRequest = NSMutableURLRequest(URL: myURL)
        
        urlRequest.timeoutInterval = timeOutInterval
        urlRequest.allowsCellularAccess = allowCellularAccess
        

        if let myHeaders = httpHeaders {
            for (key , value) in myHeaders {
                print("\(key) \(value)")
                urlRequest.setValue(value as? String, forHTTPHeaderField: (key as? String)!)
            }
        }
            
        switch httpBody {
            case .JSON(let body):
                urlRequest.setValue("application/json", forHTTPHeaderField: "Accept")
                urlRequest.setValue("application/json; charset=UTF-8", forHTTPHeaderField: "Content-Type")
                urlRequest.setValue("gzip", forHTTPHeaderField:"Content-Encoding")
                urlRequest.setValue("gzip", forHTTPHeaderField:"Accept-Encoding")
            
                var myJsonError : NSError?
                
                let myJSONData : NSData?
                do {
                    myJSONData = try NSJSONSerialization.dataWithJSONObject(body, options: NSJSONWritingOptions.PrettyPrinted)
                } catch let error as NSError {
                    myJsonError = error
                    myJSONData = nil
                    print("\(myJsonError)")
                }
                urlRequest.HTTPBody = myJSONData
            
            
            case .HTTP(let body):
                var postString : String?
                for (key , value) in body {
                    print("\(key) \(value)")
                    let result : String = "\(key)=\(value)"
                    if postString == nil {
                        postString = result
                    }else{
                        postString =  postString! + "&" + result
                    }
                    
                }
                urlRequest.HTTPBody = postString?.dataUsingEncoding(NSUTF8StringEncoding, allowLossyConversion: true)
            }
        
        return urlRequest
    }
    
}