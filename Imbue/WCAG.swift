//
//  WCAG.swift
//  Imbue
//
//  Created by Patrick Smith on 22/5/18.
//  Copyright © 2018 Royal Icing. All rights reserved.
//

import Foundation
import CoreGraphics


struct WCAGLuminance {
	let relativeLuminance: CGFloat
	
	init(lightness: CGFloat) {
		self.relativeLuminance = lightness
	}
	
	init(sRGBRed inR: CGFloat, green inG: CGFloat, blue inB: CGFloat) {
		let r, g, b: CGFloat
		if inR <= 0.03928 {
			r = inR / 12.92
		}
		else {
			r = pow((inR + 0.055) / 1.055, 2.4)
		}
		
		if inG <= 0.03928 {
			g = inG / 12.92
		}
		else {
			g = pow((inG + 0.055) / 1.055, 2.4)
		}
		
		if inB <= 0.03928 {
			b = inB / 12.92
		}
		else {
			b = pow((inB + 0.055) / 1.055, 2.4)
		}
		
		self.relativeLuminance = 0.2126 * r + 0.7152 * g + 0.0722 * b
	}
	
	static var black = WCAGLuminance(lightness: 0.0)
	static var white = WCAGLuminance(lightness: 1.0)
	
	var value: CGFloat {
		return relativeLuminance
	}
}


extension ColorValue.RGB {
	var wcagLuminance: WCAGLuminance {
		return WCAGLuminance(sRGBRed: self.r, green: self.g, blue: self.b)
	}
}

func calculateContrastRatio(lighter: WCAGLuminance, darker: WCAGLuminance) -> CGFloat {
	return (lighter.value + 0.05) / (darker.value + 0.05)
}

func getLighterAndDarker(_ a: WCAGLuminance, _ b: WCAGLuminance) -> (WCAGLuminance, WCAGLuminance) {
	if (a.value > b.value) {
		return (a, b)
	}
	else {
		return (b, a)
	}
}
