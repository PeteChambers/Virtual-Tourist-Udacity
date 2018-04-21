//
//  FlickrConstants.swift
//  Virtual Tourist
//
//  Created by Pete Chambers on 13/04/2018.
//  Copyright © 2018 Pete Chambers. All rights reserved.
//

import Foundation
import UIKit

extension FlickrClient {

struct Constants {
    
    // MARK: Flickr
    struct Flickr {
        static let APIScheme = "https"
        static let APIHost = "api.flickr.com"
        static let APIPath = "/services/rest"
        
    }
    
    // MARK: Flickr Parameter Keys
    struct FlickrParameterKeys {
        static let Method = "method"
        static let APIKey = "api_key"
        static let GalleryID = "gallery_id"
        static let Extras = "extras"
        static let Format = "format"
        static let NoJSONCallback = "nojsoncallback"
        static let SafeSearch = "safe_search"
        static let Text = "text"
        static let BoundingBox = "bbox"
        static let Page = "page"
        static let Latitude = "lat"
        static let Longitude = "lon"
    }
    
    // MARK: Flickr Parameter Values
    struct FlickrParameterValues {
        static let SearchMethod = "flickr.photos.search"
        static let APIKey = "YOUR_API_KEY_HERE"
        static let Extras = "extras"
        static let ResponseFormat = "json"
        static let DisableJSONCallback = "1" /* 1 means "yes" */
        static let GalleryPhotosMethod = "flickr.galleries.getPhotos"
        static let GalleryID = "5704-72157622566655097"
        static let MediumURL = "url_m"
        static let UseSafeSearch = "1"
    }
    
    // MARK: Flickr Response Keys
    struct FlickrResponseKeys {
        static let Status = "stat"
        static let Photos = "photos"
        static let Photo = "photo"
        static let Title = "title"
        static let MediumURL = "url_m"
        static let Pages = "pages"
        static let Total = "total"
    }
    
    // MARK: Flickr Response Values
    struct FlickrResponseValues {
        static let OKStatus = "ok"
}
    struct FlickrResults: Decodable {
        let photos: FlickrPhotos
        let stat: String
    }
    
    struct FlickrPhotos: Decodable {
        let page: Int
        let pages: Int
        let perpage: Int
        let total: String
        let photo: [FlickrPhoto]
    }
    
    struct FlickrPhoto: Decodable {
        let id: String
        let owner: String
        let secret: String
        let server: String
        let farm: Int
        let title: String
        let isPublic: Int
        let isFriend: Int
        let isFamily: Int
        let url: String?
        let height: String?
        let width: String?
        
        private enum CodingKeys: String, CodingKey {
                case id, owner, secret, server, farm, title
                case isPublic = "ispublic"
                case isFriend = "isfriend"
                case isFamily = "isfamily"
                case url = "url_m"
                case height = "height_m"
                case width = "width_m"
        }
    }

}
}
