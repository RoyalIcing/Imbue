//
//  ColorAdjustments.swift
//  Imbue
//
//  Created by Patrick Smith on 27/5/18.
//  Copyright © 2018 Royal Icing. All rights reserved.
//

import UIKit


extension ColorValue.RGB {
	func blended(with otherColor: ColorValue.RGB, amount: CGFloat) -> ColorValue.RGB {
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
		return self.blended(with: self.desaturated(), amount: amount)
	}
}
