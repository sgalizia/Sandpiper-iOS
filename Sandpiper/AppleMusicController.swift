//
//  AppleMusicController.swift
//  Sandpiper
//
//  Created by Bob De Kort on 4/11/18.
//  Copyright © 2018 Sam Galizia. All rights reserved.
//

import Foundation
import StoreKit

class AppleMusicController {
  let cloudServiceController = SKCloudServiceController()
  
  var currentCaller: MainViewController?
  
  // Request authorization from the user to access apple music
  func requestAuthorization(completionHandler: @escaping (SKCloudServiceAuthorizationStatus) -> ()) {
    SKCloudServiceController.requestAuthorization { (status) in
      switch status {
      case .authorized:
        completionHandler(status)
        // update loader: "Contacting Apple"
        break
      case .denied:
        print("Denied")
        break
      case .notDetermined:
        print("not determinded")
        break
      case .restricted:
        print("restricted")
        break
      }
    }
  }
  
  // Request country the user account is assosiated with
  func requestCountryCode() {
    cloudServiceController.requestStorefrontCountryCode { (countryCode, error) in
      guard error == nil else {
        print("error")
        print(error)
        return
      }
      
      if let country = countryCode {
        print("Country")
        print(country)
      }
    }
  }
  
  // Request the user to authenticate with apple music to access more user specific information
  func requestUserToken(completionHandler: @escaping (Bool)->()) {
    cloudServiceController.requestUserToken(forDeveloperToken: Constants.developerKey) { (response, error) in
      guard error == nil else {
        print(error!)
        completionHandler(false)
        return
      }
      
      if let response = response {
        completionHandler(true)
        // Update loader: "Finishing up"
        print("Apple Music Token: \(response))")
        // TODO: Send Token to api
      }
    }
  }
}