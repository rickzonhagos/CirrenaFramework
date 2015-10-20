//
//  CirrenaModelData.swift
//  CirrenaLibrary
//
//  Created by Cirrena on 19/10/2015.
//  Copyright © 2015 Cirrena. All rights reserved.
//

import UIKit


class CirrenaModelData{
    
    init() {
        
    }
    convenience required init(dictionary : [String : AnyObject]?){
        self.init()
        
    }
    
    var isSuccessful : Bool = false
    var messge : String?
    
    var returnParams : [String : AnyObject]?
    
    
    deinit{
        
    }
}