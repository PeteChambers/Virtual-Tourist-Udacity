//
//  FlickrConvenience.swift
//  Virtual Tourist
//
//  Created by Pete Chambers on 17/04/2018.
//  Copyright © 2018 Pete Chambers. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {
    
    func getNewCollection(latitude: Double, longitude: Double, completionHandlerForgetNewCollection: @escaping (_ success: Bool, _ data: AnyObject?, _ errorString: String?) -> Void) {
        
        let methodParameters =
            [Constants.FlickrParameterKeys.Method: Constants.FlickrParameterValues.SearchMethod,
            Constants.FlickrParameterKeys.APIKey: Constants.FlickrParameterValues.APIKey,
            Constants.FlickrParameterKeys.Extras: Constants.FlickrParameterValues.Extras,
            Constants.FlickrParameterKeys.Format: Constants.FlickrParameterValues.ResponseFormat,
            Constants.FlickrParameterKeys.NoJSONCallback: Constants.FlickrParameterValues.DisableJSONCallback,
            Constants.FlickrParameterKeys.Latitude: String(latitude),
            Constants.FlickrParameterKeys.Longitude: String(longitude)]
        
        taskForGETMethod(methodParameters: methodParameters) { (data, error) in
            
            func sendError(_ errorMessage: String) {
                completionHandlerForgetNewCollection(false, nil, errorMessage)
            }
            
            guard error == nil else {
                sendError("Could not retrieve data")
                return
            }
            
            guard let data = data else {
                sendError("No data was retrieved")
                return
            }
            
            completionHandlerForgetNewCollection(true, data, nil)
        }
    }
    
    func parsePictures(fromResults results: Constants.FlickrResults, completionHandlerForPhoto: (_ photo: Data) -> Void) {
        var dataArray: [Data] = []
        
        for photoDetails in results.photos.photo {
            
            if dataArray.count >= 21 {
                break
            }
            
            let url = URL(string: photoDetails.url!)
            
            var data: Data
            do {
                data = try Data(contentsOf: url!)
            } catch {
                print("Could not convert url to data")
                return
            }
            
            dataArray.append(data)
            
            completionHandlerForPhoto(data)
        }
    }
}

    
  
