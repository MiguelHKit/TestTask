//
//  CacheManager.swift
//  Testtask
//
//  Created by Miguel T on 21/09/24.
//

import Foundation
import UIKit

class CacheManager {
    static let shared = NSCache<NSString, UIImage>()
    
    func cacheImage(_ image: UIImage, forKey key: String) {
        CacheManager.shared.setObject(image, forKey: key as NSString)
    }
    
    func getImage(forKey key: String) -> UIImage? {
        return CacheManager.shared.object(forKey: key as NSString)
    }
    
    func removeAllCache() {
        CacheManager.shared.removeAllObjects()
    }
}
