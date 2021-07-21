//
//  Rectangle.swift
//  AppTest
//
//  Created by User on 1/6/2021.
//

import Foundation
import UIKit

struct Rectangle: Codable {
  let x: CGFloat
  let y: CGFloat
  let width: CGFloat
  let height: CGFloat
  
  var dictionary: [String: Any] {
    return (try? JSONSerialization.jsonObject(with: JSONEncoder().encode(self))) as? [String: Any] ?? [:]
  }
  
  var nsDictionary: NSDictionary {
    return self.dictionary as NSDictionary
  }
}
