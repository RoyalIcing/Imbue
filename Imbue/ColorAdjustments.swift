//
//  ColorAdjustments.swift
//  Imbue
//
//  Created by Patrick Smith on 27/5/18.
//  Copyright © 2018 Royal Icing. All rights reserved.
//

import UIKit


extension ColorValue.RGB {
	private static var black = ColorValue.RGB(r: 0.0, g: 0.0, b: 0.0)
	private static var white = ColorValue.RGB(r: 1.0, g: 1.0, b: 1.0)
	
	private func alphaBlended(with otherColor: ColorValue.RGB, amount: CGFloat) -> ColorValue.RGB {
		let r = otherColor.r * amount + self.r * (1.0 - amount)
		let g = otherColor.g * amount + self.g * (1.0 - amount)
		let b = otherColor.b * amount + self.b * (1.0 - amount)
		return ColorValue.RGB(r: r, g: g, b: b)
	}
	
	func desaturated() -> ColorValue.RGB {
		let gray: CGFloat = (max(r, g, b) + min(r, g, b)) / 2.0
		return ColorValue.RGB(r: gray, g: gray, b: gray)
	}
	
	func desaturated(amount: CGFloat) -> ColorValue.RGB {
		return self.alphaBlended(with: self.desaturated(), amount: amount)
	}
	
	func lightened(amount: CGFloat) -> ColorValue.RGB {
		return self.alphaBlended(with: ColorValue.RGB.white, amount: amount)
	}
	
	func darkened(amount: CGFloat) -> ColorValue.RGB {
		return self.alphaBlended(with: ColorValue.RGB.black, amount: amount)
	}
    
    func inverted() -> ColorValue.RGB {
        let r = 1.0 - self.r
        let g = 1.0 - self.g
        let b = 1.0 - self.b
        return ColorValue.RGB(r: r, g: g, b: b)
    }
}
