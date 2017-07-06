//
//  ColorValue.swift
//  Imbue
//
//  Created by Patrick Smith on 6/7/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import Foundation
import CoreGraphics


public enum ColorValue : Equatable {
	public struct Lab : Equatable {
		var l, a, b: CGFloat
		
		public static func ==(lhs: Lab, rhs: Lab) -> Bool {
			return lhs.l == rhs.l && lhs.a == rhs.a && lhs.b == rhs.b
		}
	}
	
	public struct RGB : Equatable {
		var r, g, b: CGFloat
		
		public static func ==(lhs: RGB, rhs: RGB) -> Bool {
			return lhs.r == rhs.r && lhs.g == rhs.g && lhs.b == rhs.b
		}
	}
	
	case labD50(Lab)
	case sRGB(RGB)
	
	public static func ==(lhs: ColorValue, rhs: ColorValue) -> Bool {
		switch (lhs, rhs) {
		case let (.labD50(l), .labD50(r)):
			return l == r
		case let (.sRGB(l), .sRGB(r)):
			return l == r
		default:
			return false
		}
	}
	
	fileprivate enum Kind : String {
		case labD50
		case sRGB
	}
	
	var cgColor: CGColor? {
		switch self {
		case let .labD50(lab):
			return CGColor.labD50(l: lab.l, a: lab.a, b: lab.b)
		case let .sRGB(rgb):
			return CGColor.linearSRGB(r: rgb.r, g: rgb.g, b: rgb.b)
		}
	}
	
	func toSRGB() -> RGB? {
		switch self {
		case let .sRGB(rgb):
			return rgb
		default:
			guard
				let cgColor = self.cgColor?.toLinearSRGB(),
				let components = cgColor.components
				else { return nil }
			
			return RGB(r: components[0], g: components[1], b: components[2])
		}
	}
}

extension ColorValue.Lab {
	public init?(dictionary: [String: Any]) {
		guard let l = dictionary["l"] as? CGFloat
			else { return nil }
		
		guard let a = dictionary["a"] as? CGFloat
			else { return nil }
		
		guard let b = dictionary["b"] as? CGFloat
			else { return nil }
		
		self.init(l: l, a: a, b: b)
	}
	
	public func toDictionary() -> [String: Any] {
		return [
			"l": l,
			"a": a,
			"b": b
		]
	}
}

extension ColorValue.RGB {
	public init?(dictionary: [String: Any]) {
		guard let r = dictionary["r"] as? CGFloat
			else { return nil }
		
		guard let g = dictionary["g"] as? CGFloat
			else { return nil }
		
		guard let b = dictionary["b"] as? CGFloat
			else { return nil }
		
		self.init(r: r, g: g, b: b)
	}
	
	public func toDictionary() -> [String: Any] {
		return [
			"r": r,
			"g": g,
			"b": b
		]
	}
}

extension ColorValue {
	public init?(dictionary: [String: Any]) {
		guard
			let kindRaw = dictionary["kind"] as? String,
			let kind = Kind(rawValue: kindRaw)
			else { return nil }
		
		switch kind {
		case .labD50:
			guard let lab = Lab(dictionary: dictionary)
				else { return nil }
			self = .labD50(lab)
		case .sRGB:
			guard let rgb = RGB(dictionary: dictionary)
				else { return nil }
			self = .sRGB(rgb)
		}
	}
	
	public func toDictionary() -> [String: Any] {
		switch self {
		case let .labD50(lab):
			var d = lab.toDictionary()
			d["kind"] = Kind.labD50.rawValue
			return d
		case let .sRGB(rgb):
			var d = rgb.toDictionary()
			d["kind"] = Kind.sRGB.rawValue
			return d
		}
	}
}
