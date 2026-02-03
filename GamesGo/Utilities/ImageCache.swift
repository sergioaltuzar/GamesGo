//
//  ImageCache.swift
//  GamesGo
//
//  Created by Sergio Altuzar on 03/02/26.
//

import UIKit

actor ImageCache {
    static let shared = ImageCache()
    private let cache = NSCache<NSString, UIImage>()

    func image(for url: String) -> UIImage? {
        cache.object(forKey: url as NSString)
    }

    func store(_ image: UIImage, for url: String) {
        cache.setObject(image, forKey: url as NSString)
    }
}
