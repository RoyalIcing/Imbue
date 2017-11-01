//
//  ColorProvider.swift
//  Imbue
//
//  Created by Patrick Smith on 1/11/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import Foundation


protocol ColorProvider: class {
	var colorValue: ColorValue { get set }
	
	var defaultSRGB: ColorValue.RGB { get }
	var defaultLabD50: ColorValue.Lab { get }
}

extension ColorProvider {
	var defaultSRGB: ColorValue.RGB {
		return ColorValue.RGB(r: 0.5, g: 0.5, b: 0.5)
	}
	
	var defaultLabD50: ColorValue.Lab {
		return ColorValue.Lab(l: 50.0, a: 0.0, b: 0.0)
	}
	
	var srgb: ColorValue.RGB {
		get {
			return self.colorValue.toSRGB() ?? self.defaultSRGB
		}
		set(rgb) {
			self.colorValue = ColorValue.sRGB(rgb)
		}
	}
	
	var labD50: ColorValue.Lab {
		get {
			return self.colorValue.toLabD50() ?? self.defaultLabD50
		}
		set(lab) {
			self.colorValue = .labD50(lab)
		}
	}
}
