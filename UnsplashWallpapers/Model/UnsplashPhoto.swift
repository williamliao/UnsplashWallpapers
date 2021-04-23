//
//  UnsplashPhoto.swift
//  Submissions
//
//  Created by Olivier Collet on 2017-04-10.
//  Copyright © 2017 Unsplash. All rights reserved.
//

import UIKit

/// A struct representing a photo from the Unsplash API.
public struct UnsplashPhoto: Codable {

    public enum URLKind: String, Codable {
        case raw
        case full
        case regular
        case small
        case thumb
    }

    public enum LinkKind: String, Codable {
        case own = "self"
        case html
        case download
        case downloadLocation = "download_location"
    }

    public let identifier: String
    public let height: Int
    public let width: Int
    public let color: UIColor?
    public let exif: UnsplashPhotoExif?
    public let user: UnsplashUser
    public let urls: [URLKind: URL]
    public let links: [LinkKind: URL]
    public let likesCount: Int
    public let downloadsCount: Int?
    public let viewsCount: Int?

    private enum CodingKeys: String, CodingKey {
        case identifier = "id"
        case height
        case width
        case color
        case exif
        case user
        case urls
        case links
        case likesCount = "likes"
        case downloadsCount = "downloads"
        case viewsCount = "views"
    }

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)
        identifier = try container.decode(String.self, forKey: .identifier)
        height = try container.decode(Int.self, forKey: .height)
        width = try container.decode(Int.self, forKey: .width)
        color = try container.decode(UIColor.self, forKey: .color)
        exif = try? container.decode(UnsplashPhotoExif.self, forKey: .exif)
        user = try container.decode(UnsplashUser.self, forKey: .user)
        urls = try container.decode([URLKind: URL].self, forKey: .urls)
        links = try container.decode([LinkKind: URL].self, forKey: .links)
        likesCount = try container.decode(Int.self, forKey: .likesCount)
        downloadsCount = try? container.decode(Int.self, forKey: .downloadsCount)
        viewsCount = try? container.decode(Int.self, forKey: .viewsCount)
    }

    public func encode(to encoder: Encoder) throws {
        var container = encoder.container(keyedBy: CodingKeys.self)
        try container.encode(identifier, forKey: .identifier)
        try container.encode(height, forKey: .height)
        try container.encode(width, forKey: .width)
        try? container.encode(color?.hexString, forKey: .color)
        try? container.encode(exif, forKey: .exif)
        try container.encode(user, forKey: .user)
        try container.encode(urls, forKey: .urls)
        try container.encode(links, forKey: .links)
//        try container.encode(urls.convert({ ($0.key.rawValue, $0.value.absoluteString) }), forKey: .urls)
//        try container.encode(links.convert({ ($0.key.rawValue, $0.value.absoluteString) }), forKey: .links)
        try container.encode(likesCount, forKey: .likesCount)
        try? container.encode(downloadsCount, forKey: .downloadsCount)
        try? container.encode(viewsCount, forKey: .viewsCount)
    }
}

extension UnsplashPhoto: Hashable, Equatable {
    public func hash(into hasher: inout Hasher) {
        hasher.combine(identifier)
        hasher.combine(height)
        hasher.combine(width)
        hasher.combine(color)
        hasher.combine(user)
        hasher.combine(urls)
        hasher.combine(links)
        hasher.combine(likesCount)
        hasher.combine(downloadsCount)
        hasher.combine(viewsCount)
    }
    
    public static func == (lhs: UnsplashPhoto, rhs: UnsplashPhoto) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}
extension UnsplashPhoto:Comparable {
    public static func < (lhs: UnsplashPhoto, rhs: UnsplashPhoto) -> Bool {
        return lhs.identifier == rhs.identifier
    }
}


extension Dictionary {
    public func convert<T, U>(_ transform: ((key: Key, value: Value)) throws -> (T, U)) rethrows -> [T: U] {
        var dictionary = [T: U]()
        for (key, value) in self {
            let transformed = try transform((key, value))
            dictionary[transformed.0] = transformed.1
        }
        return dictionary
    }
}

extension Dictionary where Key == String, Value == Any {
    func nestedValue(forKey keyToFind: String) -> Any? {
        if let value = self[keyToFind] {
            return value
        }

        for (_, value) in self {
            guard let dictionary = value as? [String: Any] else { continue }
            guard let foundValue = dictionary.nestedValue(forKey: keyToFind) else { continue }
            return foundValue
        }

        return nil
    }
}

extension UIColor {
    var redComponent: CGFloat { return cgColor.components?[0] ?? 0 }
    var greenComponent: CGFloat { return cgColor.components?[1] ?? 0 }
    var blueComponent: CGFloat { return cgColor.components?[2] ?? 0 }
    var alpha: CGFloat {
        guard let components = cgColor.components else {
            return 1
        }
        return components[cgColor.numberOfComponents-1]
    }
}

extension UIColor {
    convenience init(hexString: String) {
        var chars = Array(hexString.hasPrefix("#") ? String(hexString.dropFirst()) : hexString)
        var red: CGFloat = 0, green: CGFloat = 0, blue: CGFloat = 0, alpha: CGFloat = 1

        // swiftlint:disable fallthrough
        switch chars.count {
        case 3:
            chars = [chars[0], chars[0], chars[1], chars[1], chars[2], chars[2]]
            fallthrough
        case 6:
            chars = ["F", "F"] + chars
            fallthrough
        case 8:
            alpha = CGFloat(strtoul(String(chars[0...1]), nil, 16)) / 255
            red   = CGFloat(strtoul(String(chars[2...3]), nil, 16)) / 255
            green = CGFloat(strtoul(String(chars[4...5]), nil, 16)) / 255
            blue  = CGFloat(strtoul(String(chars[6...7]), nil, 16)) / 255
        default:
            alpha = 0
        }

        self.init(red: red, green: green, blue: blue, alpha: alpha)
    }

    var hexString: String {
        return NSString(format: "%02X%02X%02X%02X", Int(round(redComponent * 255)), Int(round(greenComponent * 255)), Int(round(blueComponent * 255)), Int(round(alpha * 255))) as String
    }
}

extension KeyedDecodingContainer {
    
    func decode(_ type: UIColor.Type, forKey key: Key) throws -> UIColor {
        let hexColor = try self.decode(String.self, forKey: key)
        return UIColor(hexString: hexColor)
    }

    func decode(_ type: [UnsplashPhoto.URLKind: URL].Type, forKey key: Key) throws -> [UnsplashPhoto.URLKind: URL] {
        let urlsDictionary = try self.decode([String: String].self, forKey: key)
        var result = [UnsplashPhoto.URLKind: URL]()
        for (key, value) in urlsDictionary {
            if let kind = UnsplashPhoto.URLKind(rawValue: key),
                let url = URL(string: value) {
                result[kind] = url
            }
        }
        return result
    }

    func decode(_ type: [UnsplashPhoto.LinkKind: URL].Type, forKey key: Key) throws -> [UnsplashPhoto.LinkKind: URL] {
        let linksDictionary = try self.decode([String: String].self, forKey: key)
        var result = [UnsplashPhoto.LinkKind: URL]()
        for (key, value) in linksDictionary {
            if let kind = UnsplashPhoto.LinkKind(rawValue: key),
                let url = URL(string: value) {
                result[kind] = url
            }
        }
        return result
    }

    func decode(_ type: [UnsplashUser.ProfileImageSize: URL].Type, forKey key: Key) throws -> [UnsplashUser.ProfileImageSize: URL] {
        let sizesDictionary = try self.decode([String: String].self, forKey: key)
        var result = [UnsplashUser.ProfileImageSize: URL]()
        for (key, value) in sizesDictionary {
            if let size = UnsplashUser.ProfileImageSize(rawValue: key),
                let url = URL(string: value) {
                result[size] = url
            }
        }
        return result
    }
}
