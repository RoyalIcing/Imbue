//
//  ColorProvider+UIKit.swift
//  Imbue
//
//  Created by Patrick Smith on 1/11/17.
//  Copyright © 2017 Burnt Caramel. All rights reserved.
//

import UIKit


extension ColorValue {
	func copy(to pb: UIPasteboard) {
		guard let srgb = self.toSRGB()
			else { return }
		pb.string = srgb.hexString
	}
	
	init?(pasteboard pb: UIPasteboard) {
		if
			let string = pb.string,
			let rgb = ColorValue.RGB(hexString: string)
		{
			self = .sRGB(rgb)
			return
		}
		
		return nil
	}
}
