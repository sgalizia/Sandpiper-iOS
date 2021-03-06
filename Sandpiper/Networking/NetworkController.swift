//
//  APIController.swift
//  Sandpiper
//
//  Created by Bob De Kort on 4/11/18.
//  Copyright © 2018 Sam Galizia. All rights reserved.
//

import Foundation
import Moya

struct NetworkController {
  var controller = MoyaProvider<APIEndpoints>()
  
  func login(email: String, password: String, completion: @escaping (Bool) -> ()) {
    controller.request(.login(email: email, password: password)) { (result) in
      switch result {
      case .success(let response):
        let data = response.data
        // Parse data into JSON
        let json = try! JSONSerialization.jsonObject(with: data, options: .mutableContainers) as? [String: Any]
        // Check if valid JSON
        if let json = json {
          if let jsonData = json["data"] as? [String: Any] {
            // Check if token is in data
            if let token = jsonData["token"] as? String {
              // Store the token in keychain
              let keychain = KeychainManager()
              keychain.setUserToken(token: token)
              // Check if user id is in data
              if let id = jsonData["user_id"] as? String {
                // Store user id in keychain
                keychain.setUserID(id: id)
                completion(true)
              } else {
                // User id is not in json
                completion(false)
              }
            } else {
              // Token was not in JSON
              completion(false)
            }
          } else {
            // Data was not in JSON
            completion(false)
          }
        } else {
          // Received JSON is not valid
          completion(false)
        }
      case .failure:
        completion(false)
      }
    }
  }
  
  func updateUser(appleMusicToken: String, countryCode: String, userID: String, bearer: String, completion: @escaping (Bool)->()) {
    controller.request(.updateUser(appleMusicToken: appleMusicToken, countryCode: countryCode, userID: userID, bearer: bearer)) { (result) in
      switch result {
      case .success:
        completion(true)
      case .failure:
        completion(false)
      }
    }
  }
  
  func getDeveloperToken(completion: @escaping (String?) -> ()) {
    if let userToken = KeychainManager().getUserToken() {
      controller.request(.generateDeveloperToken(bearer: userToken)) { (result) in
        switch result {
        case .success(let response):
          var json: [String: Any] = [:]
          // Check if valid JSON
          do {
            json = try JSONSerialization.jsonObject(with: response.data, options: .mutableContainers) as! [String: Any]
          } catch {
            completion(nil)
            return
          }
          if let jsonData = json["data"] as? [String: Any] {
            // Check if token is in data
            if let token = jsonData["token"] as? String {
              completion(token)
            } else {
              // Token was not in JSON
              completion(nil)
            }
          } else {
            // Data was not in JSON
            completion(nil)
          }
        case .failure(let error):
          // Get Developer Token failed
          completion(nil)
        }
      }
    } else {
      // No user is logged in
      completion(nil)
    }
  }
}
